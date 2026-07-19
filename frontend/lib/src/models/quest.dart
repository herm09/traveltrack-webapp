// path: lib/src/models/quest.dart
enum QuestStatus { available, inProgress, completed }

enum QuestCategory { histoire, gastro, social, sport, nature }

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
    }
  }

  static QuestCategory fromString(String? value) {
    switch (value) {
      case 'gastro':
        return QuestCategory.gastro;
      case 'social':
        return QuestCategory.social;
      case 'sport':
        return QuestCategory.sport;
      case 'nature':
        return QuestCategory.nature;
      case 'histoire':
      default:
        return QuestCategory.histoire;
    }
  }
}

extension QuestStatusX on QuestStatus {
  static QuestStatus fromString(String? value) {
    switch (value) {
      case 'in_progress':
      case 'inProgress':
        return QuestStatus.inProgress;
      case 'completed':
        return QuestStatus.completed;
      case 'available':
      default:
        return QuestStatus.available;
    }
  }
}

class Quest {
  final String id;
  final String title;
  final QuestCategory category;
  final String description;
  // Distance from the user's current position. Not stored in Supabase (it
  // depends on where the user is standing), so this defaults to 0 and is
  // meant to be computed on the fly wherever a live position is available
  // (see map_screen.dart). Mock data sets it explicitly for screens that
  // don't (yet) compute it live.
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
    this.distanceKm = 0,
    required this.xp,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    this.status = QuestStatus.available,
  });

  // Quests come from the `quests` table in Supabase (see
  // backend/src/routes/quests.js), where category/status are plain strings —
  // parsed into enums here so filters/icons/UI can work with typed values.
  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      category: QuestCategoryX.fromString(json['category'] as String?),
      description: json['description'] as String? ?? '',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      status: QuestStatusX.fromString(json['status'] as String?),
    );
  }

  Quest copyWith({double? distanceKm}) {
    return Quest(
      id: id,
      title: title,
      category: category,
      description: description,
      distanceKm: distanceKm ?? this.distanceKm,
      xp: xp,
      imageUrl: imageUrl,
      lat: lat,
      lng: lng,
      status: status,
    );
  }
}
