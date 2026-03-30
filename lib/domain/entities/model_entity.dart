import 'package:equatable/equatable.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';

class ModelEntity extends Equatable {
  final String id;
  final String name;
  final BackendType backendType;
  final String? description;
  final bool isAvailable;

  const ModelEntity({
    required this.id,
    required this.name,
    required this.backendType,
    this.description,
    this.isAvailable = true,
  });

  factory ModelEntity.fromModel(LlmModel model) {
    return ModelEntity(
      id: model.id,
      name: model.name,
      backendType: model.backendType,
      description: model.description,
      isAvailable: true,
    );
  }

  @override
  List<Object?> get props => [id, name, backendType];
}
