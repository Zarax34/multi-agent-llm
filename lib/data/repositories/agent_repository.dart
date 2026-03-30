import 'package:multi_agent_llm/data/models/agent_model.dart';
import 'package:multi_agent_llm/services/hive_service.dart';
import 'package:uuid/uuid.dart';

class AgentRepository {
  final HiveService _hiveService = HiveService();
  final _uuid = const Uuid();

  /// Get all agents
  List<AgentModel> getAgents() {
    return _hiveService.getAgents();
  }

  /// Get agent by ID
  AgentModel? getAgent(String id) {
    return _hiveService.getAgent(id);
  }

  /// Create a new agent
  Future<AgentModel> createAgent({
    required String name,
    required String systemPrompt,
    required String modelId,
    String? description,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    final now = DateTime.now();
    final agent = AgentModel(
      id: _uuid.v4(),
      name: name,
      systemPrompt: systemPrompt,
      modelId: modelId,
      description: description,
      temperature: temperature,
      maxTokens: maxTokens,
      createdAt: now,
      updatedAt: now,
    );
    await _hiveService.saveAgent(agent);
    return agent;
  }

  /// Update an agent
  Future<AgentModel> updateAgent(AgentModel agent) async {
    final updated = agent.copyWith(updatedAt: DateTime.now());
    await _hiveService.saveAgent(updated);
    return updated;
  }

  /// Delete an agent
  Future<void> deleteAgent(String id) async {
    await _hiveService.deleteAgent(id);
  }
}
