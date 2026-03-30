import 'package:hive_flutter/hive_flutter.dart';
import 'package:multi_agent_llm/data/models/chat_message.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/data/models/agent_model.dart';
import 'package:multi_agent_llm/data/models/pipeline_model.dart';
import 'package:multi_agent_llm/data/models/ollama_instance.dart';

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

  Future<void> saveAgent(AgentModel agent) async {
    await _agentsBox.put(agent.id, agent.toJson());
  }

  List<AgentModel> getAgents() {
    return _agentsBox.values
        .map((data) => AgentModel.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  AgentModel? getAgent(String id) {
    final data = _agentsBox.get(id);
    if (data == null) return null;
    return AgentModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> deleteAgent(String agentId) async {
    await _agentsBox.delete(agentId);
  }

  // ─── Pipelines ───────────────────────────────────────

  Future<void> savePipeline(PipelineModel pipeline) async {
    await _pipelinesBox.put(pipeline.id, pipeline.toJson());
  }

  List<PipelineModel> getPipelines() {
    return _pipelinesBox.values
        .map((data) => PipelineModel.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<void> deletePipeline(String pipelineId) async {
    await _pipelinesBox.delete(pipelineId);
  }

  // ─── Ollama Instances ────────────────────────────────

  Future<void> saveOllamaInstance(OllamaInstance instance) async {
    await _settingsBox.put('ollama_${instance.ip}', instance.toJson());
  }

  List<OllamaInstance> getOllamaInstances() {
    return _settingsBox.keys
        .where((key) => key.toString().startsWith('ollama_'))
        .map((key) => _settingsBox.get(key))
        .where((data) => data != null)
        .map((data) => OllamaInstance.fromJson(Map<String, dynamic>.from(data as Map)))
        .toList();
  }

  Future<void> deleteOllamaInstance(String ip) async {
    await _settingsBox.delete('ollama_$ip');
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
