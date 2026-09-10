import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

const _logoAsset = 'assets/pehchaan_logo_horizontal.png';

/// Stamps the Pehchaan logo — on its own soft rounded white chip, so it
/// stays legible against any generated background — onto the bottom-right
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
  final radius = (chipHeight * 0.32).round();

  final margin = (base.width * 0.035).round().clamp(10, 48);
  final chipX = base.width - chipWidth - margin;
  final chipY = base.height - chipHeight - margin;

  // A soft shadow peeking out beneath the chip gives it a light
  // neumorphic "lifted card" feel instead of sitting flat on the photo.
  final shadowOffset = (chipHeight * 0.06).round().clamp(2, 6);
  _fillRoundedRect(
    base,
    x: chipX,
    y: chipY + shadowOffset,
    width: chipWidth,
    height: chipHeight,
    radius: radius,
    color: img.ColorRgba8(20, 10, 40, 70),
  );

  _fillRoundedRect(
    base,
    x: chipX,
    y: chipY,
    width: chipWidth,
    height: chipHeight,
    radius: radius,
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

/// Fills a rounded rectangle pixel-by-pixel (the `image` package has no
/// rounded-rect primitive), cutting each corner to a quarter-circle and
/// alpha-blending onto whatever is already there via [img.drawPixel].
void _fillRoundedRect(
  img.Image image, {
  required int x,
  required int y,
  required int width,
  required int height,
  required int radius,
  required img.Color color,
}) {
  final r = radius.clamp(0, (width < height ? width : height) ~/ 2);
  final r2 = r * r;

  for (var j = 0; j < height; j++) {
    final py = y + j;
    if (py < 0 || py >= image.height) continue;
    for (var i = 0; i < width; i++) {
      final px = x + i;
      if (px < 0 || px >= image.width) continue;

      final inTopBand = j < r;
      final inBottomBand = j >= height - r;
      final inLeftBand = i < r;
      final inRightBand = i >= width - r;

      var inside = true;
      if ((inTopBand || inBottomBand) && (inLeftBand || inRightBand)) {
        final cx = inLeftBand ? r : width - r - 1;
        final cy = inTopBand ? r : height - r - 1;
        final dx = i - cx;
        final dy = j - cy;
        inside = (dx * dx + dy * dy) <= r2;
      }

      if (inside) {
        img.drawPixel(image, px, py, color, blend: img.BlendMode.alpha);
      }
    }
  }
}
