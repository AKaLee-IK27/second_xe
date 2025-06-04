class CommentModel {
  final String id;
  final String userId;
  final String targetUserId;
  final String? content;
  final int? rating;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.targetUserId,
    this.content,
    this.rating,
    required this.createdAt,
  });

  // Create CommentModel from JSON
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetUserId: json['target_user_id'] as String,
      content: json['content'] as String?,
      rating: json['rating'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert CommentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'target_user_id': targetUserId,
      'content': content,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert to JSON for database insertion (without id, created_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'target_user_id': targetUserId,
      'content': content,
      'rating': rating,
    };
  }

  // Convert to JSON for database update
  Map<String, dynamic> toUpdateJson() {
    return {'content': content, 'rating': rating};
  }

  // Copy with method for creating modified instances
  CommentModel copyWith({
    String? id,
    String? userId,
    String? targetUserId,
    String? content,
    int? rating,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetUserId: targetUserId ?? this.targetUserId,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Check if comment has rating
  bool get hasRating => rating != null;

  // Check if comment has content
  bool get hasContent => content != null && content!.trim().isNotEmpty;

  // Star rating display
  String get starRating {
    if (rating == null) return 'No rating';
    return '★' * rating! + '☆' * (5 - rating!);
  }

  // Rating value validation
  bool get isValidRating => rating != null && rating! >= 1 && rating! <= 5;

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
    return 'CommentModel(id: $id, userId: $userId, targetUserId: $targetUserId, rating: $rating, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
