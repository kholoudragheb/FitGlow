import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String contactName;
  final String contactImage;
  final bool isOnline;
  final bool isAI;

  const ChatScreen({
    super.key,
    required this.contactName,
    required this.contactImage,
    this.isOnline = false,
    this.isAI = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hey Alex! Great job on yesterday\'s workout. I saw you completed all sets with perfect form! 💪',
      'isMe': false,
      'time': '9:15 AM',
    },
    {
      'text': 'Thanks ! I\'m really feeling the difference. Ready for today\'s session!',
      'isMe': true,
      'time': '9:15 AM',
      'read': true,
    },
    {
      'text': 'Thanks ! I\'m really feeling the difference. Ready for today\'s session!',
      'isMe': true,
      'time': '9:15 AM',
      'read': true,
    },
    {
      'text': 'Hey Alex! Great job on yesterday\'s workout. I saw you completed all sets with perfect form! 💪',
      'isMe': false,
      'time': '9:15 AM',
    },
  ];

  // AI suggestion prompts
  final List<String> _aiSuggestions = [
    'Explain in more detail',
    'Name the types of sports',
    'How does it go about its routine?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
            child: const Icon(Icons.arrow_back_ios_new, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: widget.isAI ? const Color(0xFF1C1C1E) : null,
                  backgroundImage: widget.isAI ? null : AssetImage(widget.contactImage),
                  child: widget.isAI
                      ? const Icon(
                          Icons.smart_toy_outlined,
                          color: Color(0xFFD4FF00),
                          size: 24,
                        )
                      : null,
                ),
                if (widget.isOnline || widget.isAI)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4FF00),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0D0D0D),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Name and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contactName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.isAI ? 'Always active' : (widget.isOnline ? 'Online' : 'Offline'),
                  style: TextStyle(
                    color: widget.isOnline || widget.isAI
                        ? const Color(0xFFD4FF00)
                        : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Date indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Wed 8:21 AM',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length + (widget.isAI ? 1 : 0),
              itemBuilder: (context, index) {
                if (widget.isAI && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          // AI Suggestions (only for AI chat)
          if (widget.isAI) _buildAISuggestions(),
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['isMe'] as bool;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: widget.isAI ? const Color(0xFF1C1C1E) : null,
              backgroundImage: widget.isAI ? null : AssetImage(widget.contactImage),
              child: widget.isAI
                  ? const Icon(
                      Icons.smart_toy_outlined,
                      color: Color(0xFFD4FF00),
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFFD4FF00)
                        : const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      color: isMe ? Colors.black : Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message['time'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                    if (isMe && message['read'] == true) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage(widget.contactImage),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The questions below may help:',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ...(_aiSuggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                _messageController.text = suggestion;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      suggestion,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ))),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Emoji button
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: Colors.grey[500],
            ),
          ),
          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type message...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Voice button
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.mic_none,
              color: Colors.grey[500],
            ),
          ),
          // Attachment button
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.attach_file,
              color: Colors.grey[500],
            ),
          ),
          // Send button
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFD4FF00),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  setState(() {
                    _messages.add({
                      'text': _messageController.text,
                      'isMe': true,
                      'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} AM',
                      'read': false,
                    });
                    _messageController.clear();
                  });
                }
              },
              icon: const Icon(
                Icons.send,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
