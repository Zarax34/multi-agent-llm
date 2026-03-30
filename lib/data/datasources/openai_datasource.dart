import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:multi_agent_llm/core/constants/api_constants.dart';
import 'package:multi_agent_llm/data/models/chat_message.dart';

/// OpenAI-compatible API datasource
class OpenaiDatasource {
  late final Dio _dio;

  OpenaiDatasource() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(seconds: ApiConstants.streamTimeout),
    ));
  }

  /// List available models
  Future<List<Map<String, dynamic>>> listModels({
    required String baseUrl,
    String? apiKey,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/v1/models',
        options: Options(
          headers: {
            if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      throw Exception('Failed to list models: $e');
    }
    return [];
  }

  /// Chat completion with streaming
  Stream<String> chatStream({
    required String baseUrl,
    required String model,
    required List<ChatMessage> messages,
    String? apiKey,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async* {
    final requestBody = {
      'model': model,
      'messages': messages.map((m) => {
        'role': m.role.name,
        'content': m.content,
      }).toList(),
      'stream': true,
      'temperature': temperature,
      'max_tokens': maxTokens,
    };

    try {
      final response = await _dio.post(
        '$baseUrl/v1/chat/completions',
        data: requestBody,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Content-Type': 'application/json',
            if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          },
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || !trimmed.startsWith('data: ')) continue;
          final data = trimmed.substring(6);
          if (data == '[DONE]') return;

          try {
            final json = jsonDecode(data);
            final delta = json['choices']?[0]?['delta'];
            final content = delta?['content'];
            if (content != null) {
              yield content as String;
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  /// Non-streaming chat completion
  Future<String> chat({
    required String baseUrl,
    required String model,
    required List<ChatMessage> messages,
    String? apiKey,
    double temperature = 0.7,
  }) async {
    final requestBody = {
      'model': model,
      'messages': messages.map((m) => {
        'role': m.role.name,
        'content': m.content,
      }).toList(),
      'stream': false,
      'temperature': temperature,
    };

    try {
      final response = await _dio.post(
        '$baseUrl/v1/chat/completions',
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          },
        ),
      );
      return response.data['choices'][0]['message']['content'] ?? '';
    } catch (e) {
      throw Exception('Chat failed: $e');
    }
  }
}
