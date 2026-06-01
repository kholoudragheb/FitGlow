import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../models/conversation_model.dart';
import '../../../models/message_model.dart';
import '../../../logic/cubits/chat/chat_detail_cubit.dart';
import '../../../services/chat_service.dart';
import '../../../utils/token_storage.dart';
import '../../../logic/cubits/chat/unread_count_cubit.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final ParticipantModel otherUser;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.otherUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _currentUserId;
  late ChatDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserId();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadUserId() async {
    final id = await TokenStorage.getUserId();
    if (mounted) {
      setState(() {
        _currentUserId = id;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.markAsRead();
      context.read<UnreadCountCubit>().fetchUnreadCount(silent: true);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _cubit.loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showDeleteOptions(MessageModel message) {
    if (message.senderId != _currentUserId) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                title: const Text('Delete Message', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _confirmDelete(message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.white70),
                title: const Text('Copy Text', style: TextStyle(color: Colors.white70)),
                onTap: () {
                  // Future: Copy to clipboard
                  Navigator.pop(bottomSheetContext);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(MessageModel message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Message?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await _cubit.deleteMessage(message.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Message deleted' : 'Failed to delete message'),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        _cubit = ChatDetailCubit(ChatService(), widget.conversationId)..fetchConversation();
        return _cubit;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatDetailCubit, ChatDetailState>(
                builder: (context, state) {
                  if (state is ChatDetailLoading) {
                    return _buildShimmerLoading();
                  } else if (state is ChatDetailError) {
                    return _buildErrorState(state.message, context);
                  } else if (state is ChatDetailSuccess) {
                    final messages = state.conversation.messages.reversed.toList();
                    
                    if (messages.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      reverse: true,
                      itemCount: messages.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD0FD3E)),
                            ),
                          );
                        }
                        
                        final message = messages[index];
                        final isMe = message.senderId == _currentUserId;
                        final isDeleting = state.deletingMessageId == message.id;
                        
                        return _buildMessageBubble(message, isMe, isDeleting);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _buildAvatar(widget.otherUser.profileImage),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.fullName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  widget.otherUser.role.toUpperCase(),
                  style: const TextStyle(color: Color(0xFFD0FD3E), fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe, bool isDeleting) {
    final timeStr = DateFormat('h:mm a').format(message.createdAt);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Opacity(
        opacity: isDeleting ? 0.5 : 1.0,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onLongPress: isDeleting ? null : () => _showDeleteOptions(message),
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFFD0FD3E) : const Color(0xFF222222),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                    bottomLeft: const Radius.circular(20),
                    bottomRight: isMe ? const Radius.circular(20) : const Radius.circular(0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? Colors.black : Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    if (isDeleting)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildStatusIcon(message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'sending':
        return const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white38));
      case 'sent':
        return const Icon(Icons.done, size: 14, color: Colors.white38);
      case 'delivered':
        return const Icon(Icons.done_all, size: 14, color: Colors.white38);
      case 'read':
        return const Icon(Icons.done_all, size: 14, color: Color(0xFFFFC107));
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMessageInput() {
    return BlocConsumer<ChatDetailCubit, ChatDetailState>(
      listener: (context, state) {
        if (state is ChatDetailSuccess && !state.isSending) {
           Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }
      },
      builder: (context, state) {
        final isSending = state is ChatDetailSuccess && state.isSending;
        
        return Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white70),
                onPressed: () {},
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'Type message...',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isSending ? null : () {
                  final text = _messageController.text;
                  if (text.trim().isNotEmpty) {
                    context.read<ChatDetailCubit>().sendMessage(text);
                    _messageController.clear();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSending ? Colors.white10 : const Color(0xFFD0FD3E),
                    shape: BoxShape.circle,
                  ),
                  child: isSending 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send, color: Colors.black, size: 20),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Shimmer.fromColors(
              baseColor: Colors.white.withValues(alpha: 0.05),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          const Text(
            "No messages yet",
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<ChatDetailCubit>().fetchConversation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD0FD3E),
                foregroundColor: Colors.black,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.person, color: Colors.white54))
            : const Icon(Icons.person, color: Colors.white54),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (mounted) {
      context.read<UnreadCountCubit>().fetchUnreadCount(silent: true);
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
