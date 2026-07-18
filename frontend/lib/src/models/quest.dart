class Quest {
  final String id;
  final String title;
  final String category;
  final String? description;
  final int xp;
  final String? imageUrl;
  final double lat;
  final double lng;
  final String status;

  const Quest({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.xp,
    this.imageUrl,
    required this.lat,
    required this.lng,
    required this.status,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      status: json['status'] as String? ?? 'available',
    );
  }
}
