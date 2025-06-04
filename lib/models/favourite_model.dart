class FavouriteModel {
  final String id;
  final String userId;
  final String postId;
  final DateTime createdAt;

  FavouriteModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
  });

  // Create FavouriteModel from JSON
  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    return FavouriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert FavouriteModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert to JSON for database insertion (without id, created_at)
  Map<String, dynamic> toInsertJson() {
    return {'user_id': userId, 'post_id': postId};
  }

  // Copy with method for creating modified instances
  FavouriteModel copyWith({
    String? id,
    String? userId,
    String? postId,
    DateTime? createdAt,
  }) {
    return FavouriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Time ago display
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() {
    return 'FavouriteModel(id: $id, userId: $userId, postId: $postId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavouriteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
