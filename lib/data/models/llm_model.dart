import 'package:equatable/equatable.dart';

enum BackendType { localGguf, ollamaRemote, openaiCompatible }

class LlmModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final BackendType backendType;
  final String? filePath; // For local GGUF
  final String? ollamaHost; // For Ollama remote
  final int? ollamaPort;
  final int? sizeBytes;
  final String? family;
  final String? parameterSize;
  final bool isLoaded;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const LlmModel({
    required this.id,
    required this.name,
    this.description,
    required this.backendType,
    this.filePath,
    this.ollamaHost,
    this.ollamaPort,
    this.sizeBytes,
    this.family,
    this.parameterSize,
    this.isLoaded = false,
    required this.createdAt,
    this.metadata,
  });

  LlmModel copyWith({
    String? id,
    String? name,
    String? description,
    BackendType? backendType,
    String? filePath,
    String? ollamaHost,
    int? ollamaPort,
    int? sizeBytes,
    String? family,
    String? parameterSize,
    bool? isLoaded,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return LlmModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      backendType: backendType ?? this.backendType,
      filePath: filePath ?? this.filePath,
      ollamaHost: ollamaHost ?? this.ollamaHost,
      ollamaPort: ollamaPort ?? this.ollamaPort,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      family: family ?? this.family,
      parameterSize: parameterSize ?? this.parameterSize,
      isLoaded: isLoaded ?? this.isLoaded,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'backendType': backendType.index,
    'filePath': filePath,
    'ollamaHost': ollamaHost,
    'ollamaPort': ollamaPort,
    'sizeBytes': sizeBytes,
    'family': family,
    'parameterSize': parameterSize,
    'isLoaded': isLoaded,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };

  factory LlmModel.fromJson(Map<String, dynamic> json) => LlmModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    backendType: BackendType.values[json['backendType'] ?? 0],
    filePath: json['filePath'],
    ollamaHost: json['ollamaHost'],
    ollamaPort: json['ollamaPort'],
    sizeBytes: json['sizeBytes'],
    family: json['family'],
    parameterSize: json['parameterSize'],
    isLoaded: json['isLoaded'] ?? false,
    createdAt: DateTime.parse(json['createdAt']),
    metadata: json['metadata'],
  );

  @override
  List<Object?> get props => [id, name, backendType, filePath, ollamaHost, ollamaPort, isLoaded];
}
