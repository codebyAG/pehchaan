class Business {
  const Business({
    required this.name,
    required this.category,
    required this.phone,
    this.city = '',
    this.area = '',
    this.address = '',
    this.photos = const [],
  });

  final String name;
  final String category;
  final String phone;
  final String city;
  final String area;
  final String address;
  final List<String> photos;

  String get location => [area, city].where((s) => s.isNotEmpty).join(', ');

  Business copyWith({
    String? name,
    String? category,
    String? phone,
    String? city,
    String? area,
    String? address,
    List<String>? photos,
  }) {
    return Business(
      name: name ?? this.name,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      area: area ?? this.area,
      address: address ?? this.address,
      photos: photos ?? this.photos,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'phone': phone,
    'city': city,
    'area': area,
    'address': address,
    'photos': photos,
  };

  factory Business.fromJson(Map<String, dynamic> json) => Business(
    name: json['name'] as String? ?? '',
    category: json['category'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    city: json['city'] as String? ?? '',
    area: json['area'] as String? ?? '',
    address: json['address'] as String? ?? '',
    photos: (json['photos'] as List?)?.cast<String>() ?? const [],
  );
}
