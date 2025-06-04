enum PaymentStatus {
  pending('pending'),
  paid('paid'),
  failed('failed');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.pending,
    );
  }
}

class PostPaymentModel {
  final String id;
  final String postId;
  final String userId;
  final int? displayDuration;
  final double? totalPrice;
  final PaymentStatus status;

  PostPaymentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.displayDuration,
    this.totalPrice,
    this.status = PaymentStatus.pending,
  });

  // Create PostPaymentModel from JSON
  factory PostPaymentModel.fromJson(Map<String, dynamic> json) {
    return PostPaymentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      displayDuration: json['display_duration'] as int?,
      totalPrice: json['total_price']?.toDouble(),
      status: PaymentStatus.fromString(json['status'] as String? ?? 'pending'),
    );
  }

  // Convert PostPaymentModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'display_duration': displayDuration,
      'total_price': totalPrice,
      'status': status.value,
    };
  }

  // Convert to JSON for database insertion (without id)
  Map<String, dynamic> toInsertJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'display_duration': displayDuration,
      'total_price': totalPrice,
      'status': status.value,
    };
  }

  // Convert to JSON for database update
  Map<String, dynamic> toUpdateJson() {
    return {
      'display_duration': displayDuration,
      'total_price': totalPrice,
      'status': status.value,
    };
  }

  // Copy with method for creating modified instances
  PostPaymentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    int? displayDuration,
    double? totalPrice,
    PaymentStatus? status,
  }) {
    return PostPaymentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      displayDuration: displayDuration ?? this.displayDuration,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
    );
  }

  // Formatted price string
  String get formattedPrice {
    if (totalPrice == null) return 'Price not specified';
    return '\$${totalPrice!.toStringAsFixed(2)}';
  }

  // Duration display
  String get durationDisplay {
    if (displayDuration == null) return 'Duration not specified';
    return '$displayDuration day${displayDuration == 1 ? '' : 's'}';
  }

  // Status display with color indicator
  String get statusDisplay {
    switch (status) {
      case PaymentStatus.pending:
        return '⏳ Pending';
      case PaymentStatus.paid:
        return '✅ Paid';
      case PaymentStatus.failed:
        return '❌ Failed';
    }
  }

  // Check if payment is successful
  bool get isPaid => status == PaymentStatus.paid;

  // Check if payment is pending
  bool get isPending => status == PaymentStatus.pending;

  // Check if payment failed
  bool get isFailed => status == PaymentStatus.failed;

  // Calculate price per day
  double? get pricePerDay {
    if (totalPrice == null || displayDuration == null || displayDuration == 0) {
      return null;
    }
    return totalPrice! / displayDuration!;
  }

  @override
  String toString() {
    return 'PostPaymentModel(id: $id, postId: $postId, userId: $userId, duration: $displayDuration, price: $totalPrice, status: ${status.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostPaymentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
