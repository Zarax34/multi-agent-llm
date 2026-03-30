import 'package:equatable/equatable.dart';

class AgentModel extends Equatable {
  final String id;
  final String name;
  final String systemPrompt;
  final String modelId;
  final String? description;
  final double temperature;
  final int maxTokens;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgentModel({
    required this.id,
    required this.name,
    required this.systemPrompt,
    required this.modelId,
    this.description,
    this.temperature = 0.7,
    this.maxTokens = 2048,
    required this.createdAt,
    required this.updatedAt,
  });

  AgentModel copyWith({
    String? id,
    String? name,
    String? systemPrompt,
    String? modelId,
    String? description,
    double? temperature,
    int? maxTokens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      modelId: modelId ?? this.modelId,
      description: description ?? this.description,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'systemPrompt': systemPrompt,
    'modelId': modelId,
    'description': description,
    'temperature': temperature,
    'maxTokens': maxTokens,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory AgentModel.fromJson(Map<String, dynamic> json) => AgentModel(
    id: json['id'],
    name: json['name'],
    systemPrompt: json['systemPrompt'],
    modelId: json['modelId'],
    description: json['description'],
    temperature: (json['temperature'] ?? 0.7).toDouble(),
    maxTokens: json['maxTokens'] ?? 2048,
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  @override
  List<Object?> get props => [id, name, systemPrompt, modelId, temperature, maxTokens];
}
