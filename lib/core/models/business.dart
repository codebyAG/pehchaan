import 'dart:convert';
import 'dart:typed_data';

class Business {
  const Business({
    required this.name,
    required this.category,
    required this.phone,
    this.city = '',
    this.area = '',
    this.address = '',
    this.photos = const [],
    this.logoBytes,
  });

  final String name;
  final String category;
  final String phone;
  final String city;
  final String area;
  final String address;

  /// Real photos the owner uploaded (gallery/camera), not placeholders.
  final List<Uint8List> photos;

  /// The business logo, composited onto generated creatives — AI image
  /// models can't reliably render a specific real logo, so this is the
  /// actual uploaded image, not something GPT draws.
  final Uint8List? logoBytes;

  String get location => [area, city].where((s) => s.isNotEmpty).join(', ');

  /// Minimum details needed before we'll let the user spend an AI
  /// generation — without these, GPT has nothing real to work with.
  bool get isProfileComplete =>
      name.trim().isNotEmpty &&
      category.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      area.trim().isNotEmpty;

  Business copyWith({
    String? name,
    String? category,
    String? phone,
    String? city,
    String? area,
    String? address,
    List<Uint8List>? photos,
    Uint8List? logoBytes,
    bool clearLogo = false,
  }) {
    return Business(
      name: name ?? this.name,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      area: area ?? this.area,
      address: address ?? this.address,
      photos: photos ?? this.photos,
      logoBytes: clearLogo ? null : (logoBytes ?? this.logoBytes),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'phone': phone,
    'city': city,
    'area': area,
    'address': address,
    'photos': photos.map(base64Encode).toList(),
    'logo': logoBytes != null ? base64Encode(logoBytes!) : null,
  };

  factory Business.fromJson(Map<String, dynamic> json) {
    final logo = json['logo'] as String?;
    return Business(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      area: json['area'] as String? ?? '',
      address: json['address'] as String? ?? '',
      photos: (json['photos'] as List?)
              ?.cast<String>()
              .map(base64Decode)
              .toList() ??
          const [],
      logoBytes: logo != null && logo.isNotEmpty ? base64Decode(logo) : null,
    );
  }
}
