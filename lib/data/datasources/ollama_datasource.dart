import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:multi_agent_llm/core/constants/api_constants.dart';
import 'package:multi_agent_llm/data/models/chat_message.dart';

/// Ollama API datasource with NDJSON streaming support
class OllamaDatasource {
  late final Dio _dio;

  OllamaDatasource() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(seconds: ApiConstants.streamTimeout),
    ));
  }

  /// Set the base URL for requests
  void setBaseUrl(String host, {int port = 11434}) {
    _dio.options.baseUrl = 'http://$host:$port';
  }

  /// GET /api/tags — list available models
  Future<List<Map<String, dynamic>>> listModels(String baseUrl) async {
    try {
      final response = await _dio.get('$baseUrl/api/tags');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('models')) {
          return List<Map<String, dynamic>>.from(data['models']);
        }
      }
    } catch (e) {
      throw Exception('Failed to list Ollama models: $e');
    }
    return [];
  }

  /// POST /api/chat — chat with streaming (NDJSON)
  Stream<String> chatStream({
    required String baseUrl,
    required String model,
    required List<ChatMessage> messages,
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 2048,
    Map<String, dynamic>? options,
  }) async* {
    final requestBody = {
      'model': model,
      'messages': messages.map((m) => m.toOllamaMessage()).toList(),
      'stream': true,
      if (systemPrompt != null) 'system': systemPrompt,
      'options': {
        'temperature': temperature,
        'num_predict': maxTokens,
        ...?options,
      },
    };

    try {
      final response = await _dio.post(
        '$baseUrl/api/chat',
        data: requestBody,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // Keep incomplete line in buffer

        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          try {
            final json = jsonDecode(line);
            if (json['done'] == true) return;
            final content = json['message']?['content'];
            if (content != null) {
              yield content as String;
            }
          } catch (_) {
            // Skip malformed JSON lines
          }
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }

  /// POST /api/chat — non-streaming chat
  Future<String> chat({
    required String baseUrl,
    required String model,
    required List<ChatMessage> messages,
    String? systemPrompt,
    double temperature = 0.7,
  }) async {
    final stream = chatStream(
      baseUrl: baseUrl,
      model: model,
      messages: messages,
      systemPrompt: systemPrompt,
      temperature: temperature,
    );
    final buffer = StringBuffer();
    await for (final chunk in stream) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  /// GET /api/ps — list running models
  Future<List<Map<String, dynamic>>> listRunningModels(String baseUrl) async {
    try {
      final response = await _dio.get('$baseUrl/api/ps');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('models')) {
          return List<Map<String, dynamic>>.from(data['models']);
        }
      }
    } catch (e) {
      throw Exception('Failed to list running models: $e');
    }
    return [];
  }

  /// POST /api/pull — pull a model
  Stream<Map<String, dynamic>> pullModel({
    required String baseUrl,
    required String model,
  }) async* {
    try {
      final response = await _dio.post(
        '$baseUrl/api/pull',
        data: {'name': model, 'stream': true},
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          try {
            final json = jsonDecode(line);
            yield json;
          } catch (_) {}
        }
      }
    } catch (e) {
      yield {'error': e.toString()};
    }
  }

  /// POST /api/show — show model info
  Future<Map<String, dynamic>> showModel(String baseUrl, String model) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/show',
        data: {'name': model},
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Failed to show model info: $e');
    }
  }

  /// POST /api/delete — delete a model
  Future<bool> deleteModel(String baseUrl, String model) async {
    try {
      final response = await _dio.delete(
        '$baseUrl/api/delete',
        data: {'name': model},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Generate completion (non-chat)
  Stream<String> generateStream({
    required String baseUrl,
    required String model,
    required String prompt,
    String? systemPrompt,
    double temperature = 0.7,
  }) async* {
    final requestBody = {
      'model': model,
      'prompt': prompt,
      'stream': true,
      if (systemPrompt != null) 'system': systemPrompt,
      'options': {'temperature': temperature},
    };

    try {
      final response = await _dio.post(
        '$baseUrl/api/generate',
        data: requestBody,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          try {
            final json = jsonDecode(line);
            if (json['done'] == true) return;
            final response_text = json['response'];
            if (response_text != null) {
              yield response_text as String;
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      yield 'Error: $e';
    }
  }
}
