import 'dart:convert';
import 'dart:typed_data';

enum CreativeCategory {
  offer,
  festival,
  product,
  service,
  newArrival,
  announcement,
}

extension CreativeCategoryLabel on CreativeCategory {
  String get label {
    switch (this) {
      case CreativeCategory.offer:
        return 'Offer';
      case CreativeCategory.festival:
        return 'Festival';
      case CreativeCategory.product:
        return 'Product';
      case CreativeCategory.service:
        return 'Service';
      case CreativeCategory.newArrival:
        return 'New arrival';
      case CreativeCategory.announcement:
        return 'Announcement';
    }
  }
}

enum CreativeFormat { post, story, status, poster }

extension CreativeFormatLabel on CreativeFormat {
  String get label {
    switch (this) {
      case CreativeFormat.post:
        return 'Post';
      case CreativeFormat.story:
        return 'Story';
      case CreativeFormat.status:
        return 'Status';
      case CreativeFormat.poster:
        return 'Poster';
    }
  }

  String get ratioLabel {
    switch (this) {
      case CreativeFormat.post:
        return '1:1';
      case CreativeFormat.story:
      case CreativeFormat.status:
        return '9:16';
      case CreativeFormat.poster:
        return 'A4';
    }
  }

  double get aspectRatio {
    switch (this) {
      case CreativeFormat.post:
        return 1;
      case CreativeFormat.story:
      case CreativeFormat.status:
        return 9 / 16;
      case CreativeFormat.poster:
        return 210 / 297;
    }
  }
}

class Creative {
  Creative({
    required this.category,
    required this.title,
    required this.priceText,
    required this.businessName,
    required this.phone,
    this.format = CreativeFormat.post,
    this.imageBytes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final CreativeCategory category;
  final String title;
  final String priceText;
  final String businessName;
  final String phone;
  final CreativeFormat format;

  /// The real AI-generated image, when this creative came from a real
  /// request. Null for the mock/demo entries.
  final Uint8List? imageBytes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'category': category.name,
    'title': title,
    'priceText': priceText,
    'businessName': businessName,
    'phone': phone,
    'format': format.name,
    'imageBase64': imageBytes != null ? base64Encode(imageBytes!) : null,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Creative.fromJson(Map<String, dynamic> json) {
    final base64Image = json['imageBase64'] as String?;
    return Creative(
      category: CreativeCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => CreativeCategory.offer,
      ),
      title: json['title'] as String? ?? '',
      priceText: json['priceText'] as String? ?? '',
      businessName: json['businessName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      format: CreativeFormat.values.firstWhere(
        (f) => f.name == json['format'],
        orElse: () => CreativeFormat.post,
      ),
      imageBytes: base64Image != null && base64Image.isNotEmpty
          ? base64Decode(base64Image)
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
