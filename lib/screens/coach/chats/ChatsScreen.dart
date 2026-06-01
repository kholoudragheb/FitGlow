import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../logic/cubits/chat/conversations_cubit.dart';
import '../../../models/conversation_model.dart';
import '../../../services/chat_service.dart';
import '../../../services/user_service.dart';
import '../../../models/user_model.dart';
import 'ChatDetailScreen.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationsCubit(ChatService())..fetchConversations(),
      child: const _ChatsView(),
    );
  }
}

class _ChatsView extends StatefulWidget {
  const _ChatsView();

  @override
  State<_ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<_ChatsView> {
  String _searchQuery = '';
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final user = await UserService().getProfile();
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      debugPrint('Error fetching current user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Center(
            child: Text(
              'Chats',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 24),
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
                    final name = other.fullName.toLowerCase();
                    return name.contains(_searchQuery.toLowerCase());
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildConversationsList(filtered);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey, size: 20),
        ),
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
              Container(width: 52, height: 52, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<ConversationsCubit>().fetchConversations(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD0FD3E)),
              child: const Text('Retry', style: TextStyle(color: Colors.black)),
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
          Icon(Icons.chat_bubble_outline, color: Colors.white.withValues(alpha: 0.1), size: 64),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No conversations yet' : 'No results found',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(List<ConversationModel> conversations) {
    return RefreshIndicator(
      onRefresh: () => context.read<ConversationsCubit>().fetchConversations(),
      color: const Color(0xFFD0FD3E),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: conversations.length,
        separatorBuilder: (context, index) => Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.05),
          margin: const EdgeInsets.only(left: 64, top: 12, bottom: 12),
        ),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
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
            child: Row(
              children: [
                _buildAvatar(other.profileImage),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            other.fullName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            _formatTime(conversation.lastMessageTime ?? conversation.updatedAt),
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage?.text ?? 'No messages yet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: conversation.unreadCount > 0 ? Colors.white : Colors.white54,
                                fontWeight: conversation.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (conversation.unreadCount > 0)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: Color(0xFFD0FD3E), shape: BoxShape.circle),
                              child: Text(
                                conversation.unreadCount.toString(),
                                style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.person, color: Colors.white54),
              )
            : const Icon(Icons.person, color: Colors.white54),
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
