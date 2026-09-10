import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

const _watermarkAsset = 'assets/watermark.png';

/// Stamps the Pehchaan watermark badge onto the bottom-right corner of
/// every AI-generated image. Baked into the pixels so it stays on the
/// picture through download/share, not just an on-screen overlay. Runs
/// off the UI thread since decoding/encoding a full-size PNG isn't instant.
Future<Uint8List> addWatermark(Uint8List sourcePngBytes) async {
  final data = await rootBundle.load(_watermarkAsset);
  final watermarkBytes = data.buffer.asUint8List(
    data.offsetInBytes,
    data.lengthInBytes,
  );
  return compute(_stampWatermark, _WatermarkArgs(sourcePngBytes, watermarkBytes));
}

class _WatermarkArgs {
  const _WatermarkArgs(this.source, this.watermark);
  final Uint8List source;
  final Uint8List watermark;
}

Uint8List _stampWatermark(_WatermarkArgs args) {
  final base = img.decodeImage(args.source);
  final watermark = img.decodeImage(args.watermark);
  if (base == null || watermark == null) return args.source;

  final targetWidth = (base.width * 0.18).round().clamp(48, base.width - 24);
  final scale = targetWidth / watermark.width;
  final targetHeight = (watermark.height * scale).round().clamp(1, base.height - 24);
  final resized = img.copyResize(
    watermark,
    width: targetWidth,
    height: targetHeight,
    interpolation: img.Interpolation.average,
  );

  final margin = (base.width * 0.03).round().clamp(8, 40);
  final dstX = base.width - resized.width - margin;
  final dstY = base.height - resized.height - margin;

  img.compositeImage(base, resized, dstX: dstX, dstY: dstY);

  // Flatten to RGB (no alpha channel) so the exported photo is always
  // fully solid — no chance of a stray transparent/checkered patch.
  final flattened = base.convert(numChannels: 3);
  return Uint8List.fromList(img.encodePng(flattened));
}
