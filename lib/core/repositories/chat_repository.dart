import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';

class ChatRepository {
  final _client = Supabase.instance.client;

  Future<ChatModel?> getOrCreateChat({
    required String postId,
    required String buyerId,
    required String sellerId,
  }) async {
    // Try to find existing chat
    final response = await _client
        .from('chats')
        .select()
        .eq('post_id', postId)
        .eq('buyer_id', buyerId)
        .eq('seller_id', sellerId)
        .maybeSingle();
    if (response != null) {
      return ChatModel.fromJson(response);
    }
    // Create new chat
    final insert = await _client.from('chats').insert({
      'post_id': postId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
    }).select().single();
    return ChatModel.fromJson(insert);
  }

  Stream<List<MessageModel>> subscribeMessages(String chatId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at')
        .map((data) => data.map((e) => MessageModel.fromJson(e)).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    await _client.from('messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
    });
  }
} 