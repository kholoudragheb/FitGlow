import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../logic/cubits/chat/conversations_cubit.dart';
import '../models/conversation_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'coach/chats/ChatDetailScreen.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchProfileAndConversations();
  }

  Future<void> _fetchProfileAndConversations() async {
    try {
      final user = await UserService().getProfile();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
        context.read<ConversationsCubit>().fetchConversations();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Message',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search Message...',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          // Conversations List
          Expanded(
            child: BlocBuilder<ConversationsCubit, ConversationsState>(
              builder: (context, state) {
                if (state is ConversationsLoading || _currentUser == null) {
                  return _buildLoadingState();
                } else if (state is ConversationsError) {
                  return _buildErrorState(state.message);
                } else if (state is ConversationsSuccess) {
                  final filtered = state.conversations.where((c) {
                    final other = c.getOtherParticipant(_currentUser!.id);
                    if (other == null) return false;
                    return other.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: () => context.read<ConversationsCubit>().fetchConversations(),
                    color: const Color(0xFFD4FF00),
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _buildConversationTile(filtered[index]);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: const Color(0xFF1E1E1E),
        highlightColor: const Color(0xFF2C2C2C),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Container(width: 56, height: 56, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: Colors.black),
                    const SizedBox(height: 8),
                    Container(width: double.infinity, height: 12, color: Colors.black),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final bool is500 = message.contains('500');
    final String displayMessage = is500
        ? 'Your account has legacy chat records from an older version that cannot be loaded. Please log out and log in with a clean account, or start a new conversation to reset your chat session.'
        : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              displayMessage, 
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<ConversationsCubit>().fetchConversations(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4FF00)),
                  child: const Text('Retry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                if (is500) ...[
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                    child: const Text('Start New Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No messages yet' : 'No results found',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile(ConversationModel conversation) {
    final other = conversation.getOtherParticipant(_currentUser!.id);
    if (other == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              conversationId: conversation.id,
              otherUser: other,
            ),
          ),
        );
        if (mounted) context.read<ConversationsCubit>().fetchConversations();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ClipOval(
                child: other.profileImage != null && other.profileImage!.isNotEmpty
                    ? Image.network(
                        other.profileImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(Icons.person, color: Colors.white24),
                      )
                    : const Icon(Icons.person, color: Colors.white24),
              ),
            ),
            const SizedBox(width: 12),
            // Name and message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    other.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation.lastMessage?.text ?? 'No messages yet',
                    style: TextStyle(
                      color: conversation.unreadCount > 0 ? Colors.white : Colors.grey[500],
                      fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Time and unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(conversation.lastMessageTime ?? conversation.updatedAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (conversation.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4FF00),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      conversation.unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return DateFormat.jm().format(date);
      } else if (diff.inDays < 7) {
        return DateFormat.E().format(date);
      } else {
        return DateFormat.Md().format(date);
      }
    } catch (_) {
      return '';
    }
  }
}
