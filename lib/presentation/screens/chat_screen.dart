import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/data/models/chat_message.dart';
import 'package:multi_agent_llm/presentation/blocs/chat_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/models_bloc.dart';
import 'package:multi_agent_llm/presentation/widgets/chat_bubble.dart';
import 'package:multi_agent_llm/presentation/widgets/streaming_text.dart';

/// Clean Ollama-style chat screen
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final state = context.read<ChatBloc>().state;
    if (state.selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Select a model first', style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF171717),
        ),
      );
      return;
    }

    context.read<ChatBloc>().add(SendMessage(
      content: text,
      model: state.selectedModel!,
    ));

    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Column(
          children: [
            // Model selector — thin top bar
            _topBar(state),

            // Chat area
            Expanded(
              child: state.messages.isEmpty && !state.isStreaming
                  ? _emptyState()
                  : _messagesList(state),
            ),

            // Input
            _inputBar(state),
          ],
        );
      },
    );
  }

  Widget _topBar(ChatState chatState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedCol = isDark ? const Color(0xFF737373) : Colors.grey.shade600;

    return BlocBuilder<ModelsBloc, ModelsState>(
      builder: (context, modelsState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Model dropdown — clean
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: chatState.selectedModel?.id,
                    hint: Text(
                      'Select a model',
                      style: GoogleFonts.inter(fontSize: 13, color: mutedCol),
                    ),
                    isDense: true,
                    dropdownColor: isDark ? const Color(0xFF171717) : Colors.white,
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFE5E5E5)),
                    icon: Icon(Icons.expand_more, size: 18, color: mutedCol),
                    items: modelsState.models.map((m) {
                      return DropdownMenuItem(
                        value: m.id,
                        child: Row(
                          children: [
                            _backendDot(m.backendType),
                            const SizedBox(width: 8),
                            Text(m.name, style: GoogleFonts.inter(fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (id) {
                      if (id != null) {
                        final model = modelsState.models.firstWhere((m) => m.id == id);
                        context.read<ChatBloc>().add(SelectModel(model));
                      }
                    },
                  ),
                ),
              ),

              // New chat icon
              IconButton(
                icon: Icon(Icons.edit_square, size: 18, color: mutedCol),
                onPressed: () => context.read<ChatBloc>().add(NewConversation()),
                tooltip: 'New chat',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _backendDot(dynamic type) {
    Color c;
    // Handle BackendType enum
    c = Colors.green; // default local
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }

  Widget _emptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedCol = isDark ? const Color(0xFF525252) : Colors.grey.shade400;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'How can I help you today?',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFA3A3A3) : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a model and start chatting',
            style: GoogleFonts.inter(fontSize: 13, color: mutedCol),
          ),
        ],
      ),
    );
  }

  Widget _messagesList(ChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: state.messages.length + (state.isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length && state.isStreaming) {
          return ChatBubble(
            role: MessageRole.assistant,
            child: StreamingText(text: state.streamingContent),
          );
        }

        final msg = state.messages[index];
        return ChatBubble(
          role: msg.role,
          child: SelectableText(
            msg.content,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
            ),
          ),
        );
      },
    );
  }

  Widget _inputBar(ChatState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFAFAFA);
    final borderCol = isDark ? const Color(0xFF262626) : Colors.grey.shade300;
    final mutedCol = isDark ? const Color(0xFF737373) : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: bgCol,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171717) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderCol),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Send a message',
                    hintStyle: GoogleFonts.inter(color: mutedCol, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 6),
                child: state.isStreaming
                    ? SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: mutedCol,
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.arrow_upward, size: 18, color: mutedCol),
                        onPressed: _send,
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? const Color(0xFF262626)
                              : Colors.grey.shade200,
                          minimumSize: const Size(28, 28),
                          padding: EdgeInsets.zero,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
