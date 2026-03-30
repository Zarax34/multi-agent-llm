import 'dart:async';
import 'package:multi_agent_llm/data/models/chat_message.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/data/datasources/ollama_datasource.dart';
import 'package:multi_agent_llm/data/datasources/openai_datasource.dart';
import 'package:multi_agent_llm/data/datasources/local_llm_datasource.dart';
import 'package:multi_agent_llm/services/hive_service.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final OllamaDatasource _ollamaDatasource = OllamaDatasource();
  final OpenaiDatasource _openaiDatasource = OpenaiDatasource();
  final LocalLlmDatasource _localLlmDatasource = LocalLlmDatasource();
  final HiveService _hiveService = HiveService();
  final _uuid = const Uuid();

  /// Get all conversations
  List<String> getConversationIds() {
    return _hiveService.getConversationIds();
  }

  /// Get messages for a conversation
  List<ChatMessage> getMessages(String conversationId) {
    return _hiveService.getMessages(conversationId);
  }

  /// Send a message and get streaming response
  Stream<String> sendMessage({
    required LlmModel model,
    required String conversationId,
    required String userMessage,
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async* {
    // Save user message
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      role: MessageRole.user,
      content: userMessage,
      modelId: model.id,
      timestamp: DateTime.now(),
    );
    await _hiveService.saveMessage(conversationId, userMsg);

    // Get conversation history
    final history = _hiveService.getMessages(conversationId);

    // Route to appropriate datasource
    final Stream<String> responseStream;
    switch (model.backendType) {
      case BackendType.localGguf:
        responseStream = _localLlmDatasource.chat(
          modelPath: model.filePath!,
          messages: history,
          systemPrompt: systemPrompt,
          temperature: temperature,
          maxTokens: maxTokens,
        );
        break;
      case BackendType.ollamaRemote:
        final baseUrl = 'http://${model.ollamaHost}:${model.ollamaPort}';
        responseStream = _ollamaDatasource.chatStream(
          baseUrl: baseUrl,
          model: model.name,
          messages: history,
          systemPrompt: systemPrompt,
          temperature: temperature,
          maxTokens: maxTokens,
        );
        break;
      case BackendType.openaiCompatible:
        responseStream = _openaiDatasource.chatStream(
          baseUrl: model.ollamaHost ?? '',
          model: model.name,
          messages: history,
          temperature: temperature,
          maxTokens: maxTokens,
        );
        break;
    }

    // Stream and accumulate response
    final buffer = StringBuffer();
    await for (final chunk in responseStream) {
      buffer.write(chunk);
      yield chunk;
    }

    // Save assistant message
    final assistantMsg = ChatMessage(
      id: _uuid.v4(),
      conversationId: conversationId,
      role: MessageRole.assistant,
      content: buffer.toString(),
      modelId: model.id,
      timestamp: DateTime.now(),
      tokenCount: buffer.length ~/ 4,
    );
    await _hiveService.saveMessage(conversationId, assistantMsg);
  }

  /// Run pipeline: pass output of each agent to the next
  Stream<String> runPipeline({
    required List<LlmModel> models,
    required List<String> systemPrompts,
    required String conversationId,
    required String input,
    double temperature = 0.7,
  }) async* {
    String currentInput = input;

    for (int i = 0; i < models.length; i++) {
      final model = models[i];
      final systemPrompt = i < systemPrompts.length ? systemPrompts[i] : null;
      final buffer = StringBuffer();

      final stream = sendMessage(
        model: model,
        conversationId: '$conversationId-pipeline-$i',
        userMessage: currentInput,
        systemPrompt: systemPrompt,
        temperature: temperature,
      );

      await for (final chunk in stream) {
        buffer.write(chunk);
        if (i == models.length - 1) {
          // Only yield final agent's output
          yield chunk;
        }
      }

      currentInput = buffer.toString();
    }
  }

  /// Create new conversation
  Future<String> newConversation() async {
    final id = _uuid.v4();
    return id;
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    await _hiveService.deleteConversation(conversationId);
  }

  /// Clear all conversations
  Future<void> clearAllConversations() async {
    await _hiveService.clearAllConversations();
  }
}
