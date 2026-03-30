import 'package:equatable/equatable.dart';

class PipelineModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<PipelineStep> steps;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PipelineModel({
    required this.id,
    required this.name,
    this.description,
    required this.steps,
    required this.createdAt,
    required this.updatedAt,
  });

  PipelineModel copyWith({
    String? id,
    String? name,
    String? description,
    List<PipelineStep>? steps,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PipelineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'steps': steps.map((s) => s.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory PipelineModel.fromJson(Map<String, dynamic> json) => PipelineModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    steps: (json['steps'] as List).map((s) => PipelineStep.fromJson(s)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  @override
  List<Object?> get props => [id, name, steps];
}

class PipelineStep extends Equatable {
  final String id;
  final String agentId;
  final String agentName;
  final int order;
  final Map<String, dynamic>? config;

  const PipelineStep({
    required this.id,
    required this.agentId,
    required this.agentName,
    required this.order,
    this.config,
  });

  PipelineStep copyWith({
    String? id,
    String? agentId,
    String? agentName,
    int? order,
    Map<String, dynamic>? config,
  }) {
    return PipelineStep(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      order: order ?? this.order,
      config: config ?? this.config,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'agentId': agentId,
    'agentName': agentName,
    'order': order,
    'config': config,
  };

  factory PipelineStep.fromJson(Map<String, dynamic> json) => PipelineStep(
    id: json['id'],
    agentId: json['agentId'],
    agentName: json['agentName'],
    order: json['order'],
    config: json['config'],
  );

  @override
  List<Object?> get props => [id, agentId, order];
}
