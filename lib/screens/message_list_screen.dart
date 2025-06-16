import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:second_xe/core/repositories/chat_repository.dart';
import 'package:second_xe/core/repositories/user_repository.dart';
import 'package:second_xe/models/chat_model.dart';
import 'package:second_xe/models/user_model.dart';
import 'package:second_xe/models/message_model.dart';
import 'package:second_xe/screens/chat_screen.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({Key? key}) : super(key: key);

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final ChatRepository _chatRepo = ChatRepository();
  final UserRepository _userRepo = UserRepository();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
  }

  Stream<List<Map<String, dynamic>>> _chatsStream() async* {
    if (_currentUserId == null) yield [];
    while (true) {
      yield await _fetchChats();
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Poll every 2s for demo
    }
  }

  Future<List<Map<String, dynamic>>> _fetchChats() async {
    if (_currentUserId == null) return [];
    // Get all chats where user is buyer or seller
    final chats = await Supabase.instance.client
        .from('chats')
        .select()
        .or('buyer_id.eq.$_currentUserId,seller_id.eq.$_currentUserId')
        .order('created_at', ascending: false);
    // For each chat, get the other user and last message
    List<Map<String, dynamic>> result = [];
    for (final chatJson in chats) {
      final chat = ChatModel.fromJson(chatJson);
      final isBuyer = chat.buyerId == _currentUserId;
      final otherUserId = isBuyer ? chat.sellerId : chat.buyerId;
      final user = await _userRepo.getUserById(otherUserId);
      // Get last message
      final messages = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('chat_id', chat.id)
          .order('created_at', ascending: false)
          .limit(1);
      MessageModel? lastMessage;
      if (messages.isNotEmpty) {
        lastMessage = MessageModel.fromJson(messages.first);
      }
      result.add({'chat': chat, 'user': user, 'lastMessage': lastMessage});
    }
    return result;
  }

  Future<void> _deleteChat(ChatModel chat) async {
    await Supabase.instance.client.from('chats').delete().eq('id', chat.id);
    setState(() {}); // Refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body:
          _currentUserId == null
              ? const Center(child: Text('Not logged in'))
              : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _chatsStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final chats = snapshot.data!;
                  if (chats.isEmpty) {
                    return const Center(child: Text('No messages yet.'));
                  }
                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index]['chat'] as ChatModel;
                      final user = chats[index]['user'] as UserModel?;
                      final lastMessage =
                          chats[index]['lastMessage'] as MessageModel?;
                      final isUnread =
                          lastMessage != null &&
                          lastMessage.senderId != _currentUserId;
                      return Dismissible(
                        key: ValueKey(chat.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Delete Chat'),
                                  content: const Text(
                                    'Are you sure you want to delete this chat?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        onDismissed: (_) => _deleteChat(chat),
                        child: ListTile(
                          leading:
                              user?.avatarUrl != null &&
                                      user!.avatarUrl!.isNotEmpty
                                  ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      user.avatarUrl!,
                                    ),
                                  )
                                  : const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user?.displayName ?? 'Unknown',
                                  style:
                                      isUnread
                                          ? const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )
                                          : null,
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(left: 6),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle:
                              lastMessage != null
                                  ? Text(
                                    lastMessage.content,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        isUnread
                                            ? const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            )
                                            : null,
                                  )
                                  : const Text('No messages yet.'),
                          trailing:
                              lastMessage != null
                                  ? Text(_formatTime(lastMessage.createdAt))
                                  : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChatScreen(
                                      chat: chat,
                                      currentUserId: _currentUserId!,
                                      sellerName:
                                          user?.displayName ?? 'Unknown',
                                      sellerAvatarUrl: user?.avatarUrl,
                                    ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}
