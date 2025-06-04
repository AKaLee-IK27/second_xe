enum ReportStatus {
  pending('pending'),
  reviewed('reviewed'),
  resolved('resolved');

  const ReportStatus(this.value);
  final String value;

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

class ReportModel {
  final String id;
  final String userId;
  final String postId;
  final String? reason;
  final ReportStatus status;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.userId,
    required this.postId,
    this.reason,
    this.status = ReportStatus.pending,
    required this.createdAt,
  });

  // Create ReportModel from JSON
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
      reason: json['reason'] as String?,
      status: ReportStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Convert ReportModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'reason': reason,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Convert to JSON for database insertion (without id, created_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'reason': reason,
      'status': status.value,
    };
  }

  // Convert to JSON for database update
  Map<String, dynamic> toUpdateJson() {
    return {'reason': reason, 'status': status.value};
  }

  // Copy with method for creating modified instances
  ReportModel copyWith({
    String? id,
    String? userId,
    String? postId,
    String? reason,
    ReportStatus? status,
    DateTime? createdAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Status display with color indicator
  String get statusDisplay {
    switch (status) {
      case ReportStatus.pending:
        return '⏳ Pending';
      case ReportStatus.reviewed:
        return '👁️ Reviewed';
      case ReportStatus.resolved:
        return '✅ Resolved';
    }
  }

  // Check if report is pending
  bool get isPending => status == ReportStatus.pending;

  // Check if report is reviewed
  bool get isReviewed => status == ReportStatus.reviewed;

  // Check if report is resolved
  bool get isResolved => status == ReportStatus.resolved;

  // Check if report needs attention
  bool get needsAttention => status == ReportStatus.pending;

  // Check if report has reason
  bool get hasReason => reason != null && reason!.trim().isNotEmpty;

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

  // Summary for display
  String get summary {
    if (hasReason) {
      return reason!.length > 50 ? '${reason!.substring(0, 50)}...' : reason!;
    }
    return 'No reason provided';
  }

  @override
  String toString() {
    return 'ReportModel(id: $id, userId: $userId, postId: $postId, reason: $reason, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
