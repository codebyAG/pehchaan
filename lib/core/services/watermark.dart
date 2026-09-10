import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

const _logoAsset = 'assets/pehchaan_logo_horizontal.png';

/// Stamps the Pehchaan logo onto the bottom-right corner of every
/// AI-generated image, so it stays on the picture through download/share
/// (not just an on-screen overlay). Runs the actual pixel work off the
/// UI thread since decoding/encoding a full-size PNG isn't instant.
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

  final targetLogoWidth = (base.width * 0.18).round().clamp(48, base.width - 16);
  final scale = targetLogoWidth / logo.width;
  final targetLogoHeight = (logo.height * scale).round().clamp(1, base.height - 16);
  final resizedLogo = img.copyResize(
    logo,
    width: targetLogoWidth,
    height: targetLogoHeight,
    interpolation: img.Interpolation.average,
  );

  final margin = (base.width * 0.035).round().clamp(10, 48);
  final dstX = base.width - resizedLogo.width - margin;
  final dstY = base.height - resizedLogo.height - margin;

  img.compositeImage(base, resizedLogo, dstX: dstX, dstY: dstY);

  return Uint8List.fromList(img.encodePng(base));
}
