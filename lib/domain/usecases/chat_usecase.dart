import 'dart:async';
import 'package:multi_agent_llm/data/models/chat_message.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/data/repositories/chat_repository.dart';

class ChatUseCase {
  final ChatRepository _repository;

  ChatUseCase(this._repository);

  /// Send a message and stream the response
  Stream<String> sendMessage({
    required LlmModel model,
    required String conversationId,
    required String userMessage,
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) {
    return _repository.sendMessage(
      model: model,
      conversationId: conversationId,
      userMessage: userMessage,
      systemPrompt: systemPrompt,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  /// Get messages for a conversation
  List<ChatMessage> getMessages(String conversationId) {
    return _repository.getMessages(conversationId);
  }

  /// Create new conversation
  Future<String> newConversation() {
    return _repository.newConversation();
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) {
    return _repository.deleteConversation(conversationId);
  }

  /// Get all conversation IDs
  List<String> getConversationIds() {
    return _repository.getConversationIds();
  }
}
