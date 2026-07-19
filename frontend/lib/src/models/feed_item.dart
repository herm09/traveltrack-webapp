class FeedItem {
  final String id;
  final String userName;
  final String userAvatarUrl;
  final String questTitle;
  final String imageUrl;
  final String description;
  final DateTime timestamp;
  final int likes;
  final int comments;

  const FeedItem({
    required this.id,
    required this.userName,
    required this.userAvatarUrl,
    required this.questTitle,
    required this.imageUrl,
    required this.description,
    required this.timestamp,
    this.likes = 0,
    this.comments = 0,
  });
}
