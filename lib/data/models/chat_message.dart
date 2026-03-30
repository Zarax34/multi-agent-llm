import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant, system }

class ChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final String? modelId;
  final DateTime timestamp;
  final int? tokenCount;
  final bool isStreaming;
  final Map<String, dynamic>? metadata;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.modelId,
    required this.timestamp,
    this.tokenCount,
    this.isStreaming = false,
    this.metadata,
  });

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    MessageRole? role,
    String? content,
    String? modelId,
    DateTime? timestamp,
    int? tokenCount,
    bool? isStreaming,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      modelId: modelId ?? this.modelId,
      timestamp: timestamp ?? this.timestamp,
      tokenCount: tokenCount ?? this.tokenCount,
      isStreaming: isStreaming ?? this.isStreaming,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'conversationId': conversationId,
    'role': role.name,
    'content': content,
    'modelId': modelId,
    'timestamp': timestamp.toIso8601String(),
    'tokenCount': tokenCount,
    'isStreaming': isStreaming,
    'metadata': metadata,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    conversationId: json['conversationId'],
    role: MessageRole.values.byName(json['role']),
    content: json['content'],
    modelId: json['modelId'],
    timestamp: DateTime.parse(json['timestamp']),
    tokenCount: json['tokenCount'],
    isStreaming: json['isStreaming'] ?? false,
    metadata: json['metadata'],
  );

  /// Convert to Ollama API format
  Map<String, dynamic> toOllamaMessage() => {
    'role': role.name,
    'content': content,
  };

  @override
  List<Object?> get props => [id, conversationId, role, content, timestamp, isStreaming];
}
