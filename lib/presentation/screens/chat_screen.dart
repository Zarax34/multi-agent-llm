import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/core/theme/app_theme.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/data/models/chat_message.dart';
import 'package:multi_agent_llm/presentation/blocs/chat_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/models_bloc.dart';
import 'package:multi_agent_llm/presentation/widgets/chat_bubble.dart';
import 'package:multi_agent_llm/presentation/widgets/streaming_text.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final chatState = context.read<ChatBloc>().state;
    if (chatState.selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a model first')),
      );
      return;
    }

    context.read<ChatBloc>().add(SendMessage(
      content: content,
      model: chatState.selectedModel!,
    ));

    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, chatState) {
        return Column(
          children: [
            // Model selector
            _buildModelSelector(chatState),

            // Messages
            Expanded(child: _buildMessagesList(chatState)),

            // Input bar
            _buildInputBar(chatState),
          ],
        );
      },
    );
  }

  Widget _buildModelSelector(ChatState chatState) {
    return BlocBuilder<ModelsBloc, ModelsState>(
      builder: (context, modelsState) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.model_training, size: 18,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: chatState.selectedModel?.id,
                    hint: Text('Select a model',
                        style: GoogleFonts.inter(fontSize: 14)),
                    isExpanded: true,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    items: modelsState.models.map((model) {
                      return DropdownMenuItem(
                        value: model.id,
                        child: Row(
                          children: [
                            _buildBackendIcon(model.backendType),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(model.name,
                                  style: GoogleFonts.inter(fontSize: 14)),
                            ),
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
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => context.read<ChatBloc>().add(NewConversation()),
                tooltip: 'New chat',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackendIcon(BackendType type) {
    IconData icon;
    Color color;
    switch (type) {
      case BackendType.localGguf:
        icon = Icons.computer;
        color = Colors.green;
        break;
      case BackendType.ollamaRemote:
        icon = Icons.cloud;
        color = Colors.blue;
        break;
      case BackendType.openaiCompatible:
        icon = Icons.api;
        color = Colors.orange;
        break;
    }
    return Icon(icon, size: 16, color: color);
  }

  Widget _buildMessagesList(ChatState chatState) {
    if (chatState.messages.isEmpty && chatState.streamingContent.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppTheme.secondaryText(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a model and type a message',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: chatState.messages.length + (chatState.isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatState.messages.length && chatState.isStreaming) {
          return ChatBubble(
            role: MessageRole.assistant,
            child: StreamingText(text: chatState.streamingContent),
          );
        }

        final message = chatState.messages[index];
        return ChatBubble(
          role: message.role,
          child: SelectableText(
            message.content,
            style: GoogleFonts.inter(fontSize: 14),
          ),
        );
      },
    );
  }

  Widget _buildInputBar(ChatState chatState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.inter(
                    color: AppTheme.secondaryText(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: chatState.isStreaming
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: chatState.isStreaming ? null : _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
