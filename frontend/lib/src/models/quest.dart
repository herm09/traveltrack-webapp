enum QuestStatus { available, inProgress, completed }

enum QuestCategory { histoire, gastro, social, sport, nature, culture, all }

extension QuestCategoryX on QuestCategory {
  String get label {
    switch (this) {
      case QuestCategory.histoire:
        return 'Histoire';
      case QuestCategory.gastro:
        return 'Gastro';
      case QuestCategory.social:
        return 'Social';
      case QuestCategory.sport:
        return 'Sport';
      case QuestCategory.nature:
        return 'Nature';
      case QuestCategory.culture:
        return 'Culture';
      case QuestCategory.all:
        return 'Toutes';
    }
  }
}

class Quest {
  final String id;
  final String title;
  final QuestCategory category;
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
