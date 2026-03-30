import 'dart:async';
import 'package:multi_agent_llm/data/models/chat_message.dart';

/// Local LLM datasource using nobodywho package for GGUF models
class LocalLlmDatasource {
  /// Chat with a local GGUF model
  /// Returns a stream of response tokens
  /// Uses nobodywho's Chat.fromPath + chat.ask()
  Stream<String> chat({
    required String modelPath,
    required List<ChatMessage> messages,
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async* {
    try {
      // nobodywho integration:
      // final chat = Chat.fromPath(modelPath);
      // if (systemPrompt != null) {
      //   chat.setSystemPrompt(systemPrompt);
      // }
      // final response = chat.ask(messages.last.content);
      // yield* response;

      // Placeholder streaming simulation for build purposes
      // In production, this would use the nobodywho package
      final prompt = messages.last.content;
      final words = prompt.split(' ');
      for (final word in words) {
        await Future.delayed(const Duration(milliseconds: 50));
        yield '$word ';
      }
      yield '\n[Local GGUF response - nobodywho integration pending]';
    } catch (e) {
      yield 'Error: $e';
    }
  }

  /// Check if a GGUF model file is valid
  Future<bool> validateModel(String path) async {
    try {
      final file = path;
      return file.endsWith('.gguf') || file.endsWith('.GGUF');
    } catch (_) {
      return false;
    }
  }

  /// Get model info from GGUF file
  Future<Map<String, dynamic>?> getModelInfo(String path) async {
    // In production, parse GGUF metadata
    return {
      'path': path,
      'name': path.split('/').last,
      'format': 'GGUF',
    };
  }
}
