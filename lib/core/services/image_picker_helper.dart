import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Opens the device gallery and returns the picked image's bytes, or null
/// if the user cancelled. Shared by every "upload a photo" spot in the
/// app (business logo, shop photos) so they all behave the same way.
Future<Uint8List?> pickImageFromGallery({int maxDimension = 1600}) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: maxDimension.toDouble(),
    maxHeight: maxDimension.toDouble(),
    imageQuality: 85,
  );
  if (file == null) return null;
  return file.readAsBytes();
}
