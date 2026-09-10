import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

const _logoAsset = 'assets/pehchaan_logo_horizontal.png';

/// Stamps the Pehchaan logo — on a simple light-white background, so it
/// stays legible against any generated photo — onto the bottom-right
/// corner of every AI-generated image. Baked into the pixels so it stays
/// on the picture through download/share, not just an on-screen overlay.
/// Runs off the UI thread since decoding/encoding a full-size PNG isn't
/// instant.
Future<Uint8List> addWatermark(Uint8List sourcePngBytes) async {
  final logoData = await rootBundle.load(_logoAsset);
  final logoBytes = logoData.buffer.asUint8List(
    logoData.offsetInBytes,
    logoData.lengthInBytes,
  );
  return compute(_stampWatermark, _WatermarkArgs(sourcePngBytes, logoBytes));
}

class _WatermarkArgs {
  const _WatermarkArgs(this.source, this.logo);
  final Uint8List source;
  final Uint8List logo;
}

Uint8List _stampWatermark(_WatermarkArgs args) {
  final base = img.decodeImage(args.source);
  final logo = img.decodeImage(args.logo);
  if (base == null || logo == null) return args.source;

  final targetLogoWidth = (base.width * 0.16).round().clamp(40, base.width - 32);
  final scale = targetLogoWidth / logo.width;
  final targetLogoHeight = (logo.height * scale).round().clamp(1, base.height - 32);
  final resizedLogo = img.copyResize(
    logo,
    width: targetLogoWidth,
    height: targetLogoHeight,
    interpolation: img.Interpolation.average,
  );

  final padX = (resizedLogo.width * 0.22).round();
  final padY = (resizedLogo.height * 0.38).round();
  final chipWidth = resizedLogo.width + padX * 2;
  final chipHeight = resizedLogo.height + padY * 2;

  final margin = (base.width * 0.035).round().clamp(10, 48);
  final chipX = base.width - chipWidth - margin;
  final chipY = base.height - chipHeight - margin;

  img.fillRect(
    base,
    x1: chipX,
    y1: chipY,
    x2: chipX + chipWidth - 1,
    y2: chipY + chipHeight - 1,
    color: img.ColorRgba8(255, 255, 255, 235),
  );

  img.compositeImage(
    base,
    resizedLogo,
    dstX: chipX + padX,
    dstY: chipY + padY,
  );

  return Uint8List.fromList(img.encodePng(base));
}
