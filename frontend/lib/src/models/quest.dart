enum QuestStatus { available, inProgress, completed }

class Quest {
  final String id;
  final String title;
  final String category; // ex: "Culture", "Nature", "Gastronomie"
  final String description;
  final double distanceKm;
  final int xp;
  final String imageUrl;
  final double lat;
  final double lng;
  final QuestStatus status;

  const Quest({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.distanceKm,
    required this.xp,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    this.status = QuestStatus.available,
  });
}
