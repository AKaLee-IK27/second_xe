class LogEntryModel {
  final String id;
  final String userId;
  final String action;
  final String? target;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  LogEntryModel({
    required this.id,
    required this.userId,
    required this.action,
    this.target,
    this.metadata,
    required this.timestamp,
  });

  // Create LogEntryModel from JSON
  factory LogEntryModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? metadata;
    if (json['metadata'] != null) {
      if (json['metadata'] is Map<String, dynamic>) {
        metadata = json['metadata'] as Map<String, dynamic>;
      } else if (json['metadata'] is String) {
        // Handle JSON string case - you might want to parse it
        try {
          metadata = Map<String, dynamic>.from(json['metadata']);
        } catch (e) {
          metadata = {'raw': json['metadata']};
        }
      }
    }

    return LogEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      action: json['action'] as String,
      target: json['target'] as String?,
      metadata: metadata,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  // Convert LogEntryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'action': action,
      'target': target,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Convert to JSON for database insertion (without id, timestamp)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'action': action,
      'target': target,
      'metadata': metadata,
    };
  }

  // Copy with method for creating modified instances
  LogEntryModel copyWith({
    String? id,
    String? userId,
    String? action,
    String? target,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) {
    return LogEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      action: action ?? this.action,
      target: target ?? this.target,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Check if log entry has target
  bool get hasTarget => target != null && target!.trim().isNotEmpty;

  // Check if log entry has metadata
  bool get hasMetadata => metadata != null && metadata!.isNotEmpty;

  // Get metadata value by key
  dynamic getMetadataValue(String key) {
    return metadata?[key];
  }

  // Get metadata as formatted string
  String get metadataString {
    if (!hasMetadata) return 'No metadata';
    return metadata!.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  // Time ago display
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  // Formatted timestamp
  String get formattedTimestamp {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  // Action display with emoji
  String get actionDisplay {
    switch (action.toLowerCase()) {
      case 'create':
      case 'created':
        return '➕ $action';
      case 'update':
      case 'updated':
        return '✏️ $action';
      case 'delete':
      case 'deleted':
        return '🗑️ $action';
      case 'login':
      case 'signin':
        return '🔐 $action';
      case 'logout':
      case 'signout':
        return '🚪 $action';
      case 'view':
      case 'viewed':
        return '👁️ $action';
      case 'search':
      case 'searched':
        return '🔍 $action';
      default:
        return '📝 $action';
    }
  }

  // Summary for display
  String get summary {
    final parts = <String>[actionDisplay];
    if (hasTarget) {
      parts.add(target!);
    }
    return parts.join(' ');
  }

  // Check if this is a critical action
  bool get isCriticalAction {
    final criticalActions = [
      'delete',
      'deleted',
      'ban',
      'banned',
      'suspend',
      'suspended',
    ];
    return criticalActions.contains(action.toLowerCase());
  }

  // Check if this is a user action
  bool get isUserAction {
    final userActions = [
      'login',
      'logout',
      'signin',
      'signout',
      'register',
      'signup',
    ];
    return userActions.contains(action.toLowerCase());
  }

  @override
  String toString() {
    return 'LogEntryModel(id: $id, userId: $userId, action: $action, target: $target, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LogEntryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
