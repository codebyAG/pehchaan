enum CreativeCategory { offer, festival, product, service, newArrival, announcement }

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
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final CreativeCategory category;
  final String title;
  final String priceText;
  final String businessName;
  final String phone;
  final CreativeFormat format;
  final DateTime createdAt;
}
