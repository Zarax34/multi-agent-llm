import 'package:equatable/equatable.dart';
import 'package:multi_agent_llm/data/models/agent_model.dart';

class AgentEntity extends Equatable {
  final String id;
  final String name;
  final String systemPrompt;
  final String modelId;
  final String? description;

  const AgentEntity({
    required this.id,
    required this.name,
    required this.systemPrompt,
    required this.modelId,
    this.description,
  });

  factory AgentEntity.fromModel(AgentModel model) {
    return AgentEntity(
      id: model.id,
      name: model.name,
      systemPrompt: model.systemPrompt,
      modelId: model.modelId,
      description: model.description,
    );
  }

  @override
  List<Object?> get props => [id, name, modelId];
}
