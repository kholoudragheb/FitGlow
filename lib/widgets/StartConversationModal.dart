import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants.dart';
import '../../logic/cubits/chat/start_conversation_cubit.dart';
import '../../screens/coach/chats/ChatDetailScreen.dart';
import '../../utils/token_storage.dart';

class StartConversationModal extends StatefulWidget {
  final String recipientId;
  final String recipientName;

  const StartConversationModal({
    super.key,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  State<StartConversationModal> createState() => _StartConversationModalState();
}

class _StartConversationModalState extends State<StartConversationModal> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onStartChat(BuildContext context) {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<StartConversationCubit>().startNewConversation(
          recipientId: widget.recipientId,
          initialMessage: message,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StartConversationCubit, StartConversationState>(
      listener: (context, state) async {
        if (state is StartConversationSuccess) {
          Navigator.pop(context); // Close modal
          
          final currentUserId = await TokenStorage.getUserId();
          final otherUser = state.conversation.getOtherParticipant(currentUserId ?? '');

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Conversation started successfully"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            if (otherUser != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(
                    conversationId: state.conversation.id,
                    otherUser: otherUser,
                  ),
                ),
              );
            }
          }
        } else if (state is StartConversationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Start Conversation",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Send a message to ${widget.recipientName} to start chatting.",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Type your first message...",
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<StartConversationCubit, StartConversationState>(
              builder: (context, state) {
                final isLoading = state is StartConversationLoading;

                return ElevatedButton(
                  onPressed: isLoading ? null : () => _onStartChat(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppConstants.primaryColor.withValues(alpha: 0.5),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Start Chat",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
