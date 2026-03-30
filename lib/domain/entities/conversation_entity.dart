import 'package:equatable/equatable.dart';
import 'package:multi_agent_llm/data/models/chat_message.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String? title;
  final List<ChatMessage> messages;
  final String? modelId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationEntity({
    required this.id,
    this.title,
    this.messages = const [],
    this.modelId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, messages.length, modelId];
}
