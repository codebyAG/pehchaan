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
}
