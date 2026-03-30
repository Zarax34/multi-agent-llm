import 'package:equatable/equatable.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';

class ApiConfig extends Equatable {
  final String id;
  final String name;
  final BackendType backendType;
  final String baseUrl;
  final String? apiKey;
  final Map<String, String>? headers;
  final int connectTimeout;
  final int receiveTimeout;
  final bool isActive;

  const ApiConfig({
    required this.id,
    required this.name,
    required this.backendType,
    required this.baseUrl,
    this.apiKey,
    this.headers,
    this.connectTimeout = 10,
    this.receiveTimeout = 30,
    this.isActive = true,
  });

  ApiConfig copyWith({
    String? id,
    String? name,
    BackendType? backendType,
    String? baseUrl,
    String? apiKey,
    Map<String, String>? headers,
    int? connectTimeout,
    int? receiveTimeout,
    bool? isActive,
  }) {
    return ApiConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      backendType: backendType ?? this.backendType,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      headers: headers ?? this.headers,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'backendType': backendType.index,
    'baseUrl': baseUrl,
    'apiKey': apiKey,
    'headers': headers,
    'connectTimeout': connectTimeout,
    'receiveTimeout': receiveTimeout,
    'isActive': isActive,
  };

  factory ApiConfig.fromJson(Map<String, dynamic> json) => ApiConfig(
    id: json['id'],
    name: json['name'],
    backendType: BackendType.values[json['backendType'] ?? 0],
    baseUrl: json['baseUrl'],
    apiKey: json['apiKey'],
    headers: json['headers'] != null ? Map<String, String>.from(json['headers']) : null,
    connectTimeout: json['connectTimeout'] ?? 10,
    receiveTimeout: json['receiveTimeout'] ?? 30,
    isActive: json['isActive'] ?? true,
  );

  /// Create Ollama config
  factory ApiConfig.ollama({
    required String id,
    required String host,
    int port = 11434,
  }) {
    return ApiConfig(
      id: id,
      name: 'Ollama ($host)',
      backendType: BackendType.ollamaRemote,
      baseUrl: 'http://$host:$port',
    );
  }

  /// Create OpenAI-compatible config
  factory ApiConfig.openai({
    required String id,
    required String baseUrl,
    String? apiKey,
  }) {
    return ApiConfig(
      id: id,
      name: 'OpenAI Compatible',
      backendType: BackendType.openaiCompatible,
      baseUrl: baseUrl,
      apiKey: apiKey,
      headers: apiKey != null ? {'Authorization': 'Bearer $apiKey'} : null,
    );
  }

  @override
  List<Object?> get props => [id, backendType, baseUrl, isActive];
}
