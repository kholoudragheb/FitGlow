import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fit_app/core/constants.dart';
import 'package:fit_app/utils/store_styles.dart';
import '../services/chat_service.dart';
import '../logic/cubits/chat/ai_chat_cubit.dart';
import '../models/chat_model.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _suggestions = [
    'Explain in more detail',
    'Name the types of sports',
    'How does it go about its routine?',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(() {
      setState(() {});
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () => _scrollToBottom());
      }
    });
    _messageController.addListener(() {
      setState(() {});
    });
    
    // History is already loaded in main.dart, but we can refresh it here if needed
    // context.read<AIChatCubit>().loadHistory();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bottomInset = View.of(context).viewInsets.bottom;
      if (bottomInset > 0.0) {
        Future.delayed(const Duration(milliseconds: 300), () => _scrollToBottom());
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    context.read<AIChatCubit>().sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181818),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: BlocConsumer<AIChatCubit, AIChatState>(
                  listener: (context, state) {
                    if (state is AIChatSuccess) {
                      _scrollToBottom();
                      if (state.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.error!),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  builder: (context, state) {
                    if (state is AIChatInitial || state is AIChatLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(StoreColors.primary),
                        ),
                      );
                    }

                    if (state is AIChatSuccess) {
                      final messages = state.messages;
                      bool showSuggestions = messages.isEmpty && 
                                             !_focusNode.hasFocus && 
                                             _messageController.text.isEmpty;

                      return Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              itemCount: messages.length + 1, // +1 for date header
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 24),
                                      child: Text(
                                        'Historical View',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          color: Color(0xFF72777A),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return _buildMessageBubble(messages[index - 1]);
                              },
                            ),
                          ),
                          if (state.isSending)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: _buildTypingIndicator(),
                            ),
                          if (showSuggestions) _buildSuggestions(),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
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
      backgroundColor: const Color(0xFF181818),
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: SvgPicture.asset(
              AppConstants.iconBack,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StoreColors.primary, width: 1),
            ),
            child: Center(
              child: SvgPicture.asset(
                AppConstants.iconBot,
                colorFilter: const ColorFilter.mode(
                  StoreColors.primary,
                  BlendMode.srcIn,
                ),
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Coach',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: StoreColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Always active',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF72777A),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: StoreColors.primary, width: 1),
          ),
          child: Center(
            child: SvgPicture.asset(
              AppConstants.iconBot,
              colorFilter: const ColorFilter.mode(
                StoreColors.primary,
                BlendMode.srcIn,
              ),
              width: 16,
              height: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFF2C2C2C),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: StoreColors.primary)),
              SizedBox(width: 12),
              Text("Thinking...", style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Poppins')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == 'user';
    final uiFormat = message.toUIFormat();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: StoreColors.primary, width: 1),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppConstants.iconBot,
                  colorFilter: const ColorFilter.mode(
                    StoreColors.primary,
                    BlendMode.srcIn,
                  ),
                  width: 16,
                  height: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? StoreColors.primary
                          : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMessageText(message.message, isUser),
                        if (!isUser && message.sources != null && message.sources!.isNotEmpty)
                          _buildSourcesSection(message.sources!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  uiFormat['time'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF72777A),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesSection(List<String> sources) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sources & Tips:',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF72777A),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...sources.map((source) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $source',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildMessageText(String originalText, bool isUser) {
    if (isUser || !originalText.contains('[')) {
      return Text(
        originalText,
        style: TextStyle(
          fontFamily: 'Poppins',
          color: isUser ? Colors.black : Colors.white,
          fontSize: 14,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'\[([^\]]+)\]\([^\)]+\)');
    int lastMatchEnd = 0;

    for (var match in exp.allMatches(originalText)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: originalText.substring(lastMatchEnd, match.start),
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: StoreColors.primary,
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationColor: StoreColors.primary,
          ),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < originalText.length) {
      spans.add(
        TextSpan(
          text: originalText.substring(lastMatchEnd),
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'The questions below may help:',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF72777A),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          ..._suggestions.map(
            (suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _sendMessage(suggestion),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    border: Border.all(
                      color: const Color(0xFF2C2C2C),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        suggestion,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF181818),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        AppConstants.iconEmoji,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF72777A),
                          BlendMode.srcIn,
                        ),
                        width: 24,
                      ),
                      splashRadius: 20,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF72777A),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                        isDense: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.attach_file,
                        color: Color(0xFF72777A),
                        size: 22,
                      ),
                      splashRadius: 20,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, right: 2),
                    child: IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        AppConstants.iconMic,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF72777A),
                          BlendMode.srcIn,
                        ),
                        width: 22,
                      ),
                      splashRadius: 20,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: StoreColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => _sendMessage(_messageController.text),
                icon: SvgPicture.asset(
                  AppConstants.iconSend,
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.srcIn,
                  ),
                  width: 22,
                  height: 22,
                ),
                padding: EdgeInsets.zero,
                splashRadius: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

