import 'dart:async';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/data/models/ollama_instance.dart';
import 'package:multi_agent_llm/data/datasources/ollama_datasource.dart';
import 'package:multi_agent_llm/data/datasources/local_llm_datasource.dart';
import 'package:multi_agent_llm/services/hive_service.dart';
import 'package:uuid/uuid.dart';

class ModelRepository {
  final OllamaDatasource _ollamaDatasource = OllamaDatasource();
  final LocalLlmDatasource _localLlmDatasource = LocalLlmDatasource();
  final HiveService _hiveService = HiveService();
  final _uuid = const Uuid();

  /// Get all saved models
  List<LlmModel> getModels() {
    return _hiveService.getModels();
  }

  /// Add a local GGUF model
  Future<LlmModel> addLocalModel(String filePath, {String? name}) async {
    final model = LlmModel(
      id: _uuid.v4(),
      name: name ?? filePath.split('/').last.replaceAll('.gguf', ''),
      backendType: BackendType.localGguf,
      filePath: filePath,
      createdAt: DateTime.now(),
    );
    await _hiveService.saveModel(model);
    return model;
  }

  /// Add an Ollama remote model
  Future<LlmModel> addOllamaModel({
    required String name,
    required String host,
    int port = 11434,
  }) async {
    final model = LlmModel(
      id: _uuid.v4(),
      name: name,
      backendType: BackendType.ollamaRemote,
      ollamaHost: host,
      ollamaPort: port,
      createdAt: DateTime.now(),
    );
    await _hiveService.saveModel(model);
    return model;
  }

  /// Add an OpenAI-compatible model
  Future<LlmModel> addOpenaiModel({
    required String name,
    required String baseUrl,
    String? apiKey,
  }) async {
    final model = LlmModel(
      id: _uuid.v4(),
      name: name,
      backendType: BackendType.openaiCompatible,
      ollamaHost: baseUrl,
      createdAt: DateTime.now(),
    );
    await _hiveService.saveModel(model);
    return model;
  }

  /// Fetch models from an Ollama instance
  Future<List<Map<String, dynamic>>> fetchOllamaModels(String baseUrl) async {
    return await _ollamaDatasource.listModels(baseUrl);
  }

  /// Delete a model
  Future<void> deleteModel(String id) async {
    await _hiveService.deleteModel(id);
  }

  /// Update a model
  Future<void> updateModel(LlmModel model) async {
    await _hiveService.saveModel(model);
  }

  /// Import models from Ollama instance
  Future<List<LlmModel>> importFromOllama(String host, int port) async {
    final baseUrl = 'http://$host:$port';
    final models = await _ollamaDatasource.listModels(baseUrl);
    final imported = <LlmModel>[];

    for (final m in models) {
      final model = LlmModel(
        id: _uuid.v4(),
        name: m['name'] ?? 'unknown',
        backendType: BackendType.ollamaRemote,
        ollamaHost: host,
        ollamaPort: port,
        sizeBytes: m['size'],
        createdAt: DateTime.now(),
      );
      await _hiveService.saveModel(model);
      imported.add(model);
    }
    return imported;
  }
}
