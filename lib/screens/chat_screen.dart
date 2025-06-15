import 'package:flutter/material.dart';
import 'package:second_xe/models/chat_model.dart';
import 'package:second_xe/models/message_model.dart';
import 'package:second_xe/core/repositories/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel chat;
  final String currentUserId;
  final String sellerName;
  final String? sellerAvatarUrl;

  const ChatScreen({
    Key? key,
    required this.chat,
    required this.currentUserId,
    required this.sellerName,
    this.sellerAvatarUrl,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository _chatRepo = ChatRepository();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageModel> _pendingMessages = [];

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final pending = MessageModel(
      id: UniqueKey().toString(),
      chatId: widget.chat.id,
      senderId: widget.currentUserId,
      content: text,
      createdAt: DateTime.now(),
    );
    setState(() {
      _pendingMessages.add(pending);
    });
    _controller.clear();
    _scrollToBottom();
    await _chatRepo.sendMessage(
      chatId: widget.chat.id,
      senderId: widget.currentUserId,
      content: text,
    );
    // No need to remove from _pendingMessages here; will be handled in StreamBuilder
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.sellerAvatarUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.sellerAvatarUrl!),
              ),
            if (widget.sellerAvatarUrl != null) const SizedBox(width: 8),
            Text(widget.sellerName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatRepo.subscribeMessages(widget.chat.id),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                // Remove any pending messages that now exist in the stream
                final confirmedIds = messages.map((m) => m.id).toSet();
                _pendingMessages.removeWhere((m) => confirmedIds.contains(m.id) || (
                  // Remove if same content, sender, and createdAt within 2 seconds
                  messages.any((msg) =>
                    msg.content == m.content &&
                    msg.senderId == m.senderId &&
                    (msg.createdAt.difference(m.createdAt).inSeconds).abs() < 2
                  )
                ));
                // Combine messages and pending
                final allMessages = [...messages, ..._pendingMessages];
                allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: allMessages.length,
                  reverse: false,
                  itemBuilder: (context, index) {
                    final msg = allMessages[index];
                    final isMe = msg.senderId == widget.currentUserId;
                    final isPending = _pendingMessages.contains(msg);
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Opacity(
                        opacity: isPending ? 0.5 : 1.0,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg.content),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 