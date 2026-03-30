import 'package:hive_flutter/hive_flutter.dart';
import 'package:multi_agent_llm/data/models/chat_message.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';

/// Hive-based local storage service
class HiveService {
  static late Box<Map> _modelsBox;
  static late Box<Map> _agentsBox;
  static late Box<Map> _pipelinesBox;
  static late Box<Map> _settingsBox;
  static late Box<Map> _conversationsBox;

  static Future<void> init() async {
    _modelsBox = await Hive.openBox<Map>('models');
    _agentsBox = await Hive.openBox<Map>('agents');
    _pipelinesBox = await Hive.openBox<Map>('pipelines');
    _settingsBox = await Hive.openBox<Map>('settings');
    _conversationsBox = await Hive.openBox<Map>('conversations');
  }

  // ─── Models ──────────────────────────────────────────

  Future<void> saveModel(LlmModel model) async {
    await _modelsBox.put(model.id, model.toJson());
  }

  List<LlmModel> getModels() {
    return _modelsBox.values
        .map((data) => LlmModel.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<void> deleteModel(String modelId) async {
    await _modelsBox.delete(modelId);
  }

  // ─── Agents ──────────────────────────────────────────

  Future<void> saveAgent(Map<String, dynamic> agent) async {
    await _agentsBox.put(agent['id'], agent);
  }

  List<Map<String, dynamic>> getAgents() {
    return _agentsBox.values
        .map((data) => Map<String, dynamic>.from(data))
        .toList();
  }

  Future<void> deleteAgent(String agentId) async {
    await _agentsBox.delete(agentId);
  }

  // ─── Pipelines ───────────────────────────────────────

  Future<void> savePipeline(Map<String, dynamic> pipeline) async {
    await _pipelinesBox.put(pipeline['id'], pipeline);
  }

  List<Map<String, dynamic>> getPipelines() {
    return _pipelinesBox.values
        .map((data) => Map<String, dynamic>.from(data))
        .toList();
  }

  Future<void> deletePipeline(String pipelineId) async {
    await _pipelinesBox.delete(pipelineId);
  }

  // ─── Conversations ───────────────────────────────────

  List<String> getConversationIds() {
    return _conversationsBox.keys.cast<String>().toList();
  }

  Future<void> saveMessage(String conversationId, ChatMessage message) async {
    final key = '${conversationId}_${message.id}';
    await _conversationsBox.put(key, message.toJson());
  }

  List<ChatMessage> getMessages(String conversationId) {
    return _conversationsBox.values
        .where((data) {
          final msg = Map<String, dynamic>.from(data);
          return msg['conversationId'] == conversationId;
        })
        .map((data) => ChatMessage.fromJson(Map<String, dynamic>.from(data)))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> deleteConversation(String conversationId) async {
    final keysToDelete = _conversationsBox.keys.where((key) {
      final data = _conversationsBox.get(key);
      if (data == null) return false;
      return (data as Map)['conversationId'] == conversationId;
    }).toList();

    for (final key in keysToDelete) {
      await _conversationsBox.delete(key);
    }
  }

  Future<void> clearAllConversations() async {
    await _conversationsBox.clear();
  }

  // ─── Ollama Instances ────────────────────────────────

  Future<void> saveOllamaInstance(dynamic instance) async {
    final data = {
      'ip': instance.ip,
      'port': instance.port,
      'isOnline': instance.isOnline,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'modelName': instance.modelName,
    };
    await _settingsBox.put('ollama_${instance.ip}', data);
  }

  List<dynamic> getOllamaInstances() {
    return _settingsBox.keys
        .where((key) => key.toString().startsWith('ollama_'))
        .map((key) => _settingsBox.get(key))
        .where((data) => data != null)
        .map((data) => Map<String, dynamic>.from(data as Map))
        .toList();
  }

  Future<void> deleteOllamaInstance(String ip) async {
    await _settingsBox.delete('ollama_$ip');
  }

  // ─── Settings ────────────────────────────────────────

  Future<void> saveSetting(String key, Map<String, dynamic> value) async {
    await _settingsBox.put(key, value);
  }

  Map<String, dynamic>? getSetting(String key) {
    final data = _settingsBox.get(key);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }
}
