import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

void main() {
  final base = img.decodeImage(File('assets/banners/banner-1-festival.png').readAsBytesSync())!;
  final logo = img.decodeImage(File('assets/pehchaan_logo_horizontal.png').readAsBytesSync())!;

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

  final shadowOffset = (chipHeight * 0.06).round().clamp(2, 6);
  fillRoundedRect(base, x: chipX, y: chipY + shadowOffset, width: chipWidth, height: chipHeight, radius: radius, color: img.ColorRgba8(20, 10, 40, 70));
  fillRoundedRect(base, x: chipX, y: chipY, width: chipWidth, height: chipHeight, radius: radius, color: img.ColorRgba8(255, 255, 255, 235));

  img.compositeImage(base, resizedLogo, dstX: chipX + padX, dstY: chipY + padY);

  File('watermark_test_output.png').writeAsBytesSync(Uint8List.fromList(img.encodePng(base)));
  // ignore: avoid_print
  print('done');
}

void fillRoundedRect(img.Image image, {required int x, required int y, required int width, required int height, required int radius, required img.Color color}) {
  final r = radius.clamp(0, (width < height ? width : height) ~/ 2);
  img.fillRect(image, x1: x + r, y1: y, x2: x + width - r - 1, y2: y + height - 1, color: color);
  img.fillRect(image, x1: x, y1: y + r, x2: x + r - 1, y2: y + height - r - 1, color: color);
  img.fillRect(image, x1: x + width - r, y1: y + r, x2: x + width - 1, y2: y + height - r - 1, color: color);
  img.fillCircle(image, x: x + r, y: y + r, radius: r, color: color);
  img.fillCircle(image, x: x + width - r - 1, y: y + r, radius: r, color: color);
  img.fillCircle(image, x: x + r, y: y + height - r - 1, radius: r, color: color);
  img.fillCircle(image, x: x + width - r - 1, y: y + height - r - 1, radius: r, color: color);
}
