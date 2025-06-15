import 'package:meta/meta.dart';

class ChatModel {
  final String id;
  final String postId;
  final String buyerId;
  final String sellerId;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.postId,
    required this.buyerId,
    required this.sellerId,
    required this.createdAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 