import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:multi_agent_llm/data/models/chat_message.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/data/repositories/chat_repository.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversation extends ChatEvent {
  final String conversationId;
  const LoadConversation(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

class SendMessage extends ChatEvent {
  final String content;
  final LlmModel model;
  final String? systemPrompt;
  const SendMessage({required this.content, required this.model, this.systemPrompt});
  @override
  List<Object?> get props => [content, model, systemPrompt];
}

class NewConversation extends ChatEvent {}

class StreamChunkReceived extends ChatEvent {
  final String chunk;
  const StreamChunkReceived(this.chunk);
  @override
  List<Object?> get props => [chunk];
}

class StreamingComplete extends ChatEvent {}

class SelectModel extends ChatEvent {
  final LlmModel model;
  const SelectModel(this.model);
  @override
  List<Object?> get props => [model];
}

class ClearConversation extends ChatEvent {}

class DeleteConversation extends ChatEvent {
  final String conversationId;
  const DeleteConversation(this.conversationId);
  @override
  List<Object?> get props => [conversationId];
}

// State
class ChatState extends Equatable {
  final String? conversationId;
  final List<ChatMessage> messages;
  final LlmModel? selectedModel;
  final bool isStreaming;
  final String streamingContent;
  final String? error;
  final bool isLoading;

  const ChatState({
    this.conversationId,
    this.messages = const [],
    this.selectedModel,
    this.isStreaming = false,
    this.streamingContent = '',
    this.error,
    this.isLoading = false,
  });

  ChatState copyWith({
    String? conversationId,
    List<ChatMessage>? messages,
    LlmModel? selectedModel,
    bool? isStreaming,
    String? streamingContent,
    String? error,
    bool? isLoading,
  }) {
    return ChatState(
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      selectedModel: selectedModel ?? this.selectedModel,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingContent: streamingContent ?? this.streamingContent,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [conversationId, messages, selectedModel, isStreaming, streamingContent, error, isLoading];
}

// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  StreamSubscription<String>? _streamSubscription;

  ChatBloc(this._repository) : super(const ChatState()) {
    on<LoadConversation>(_onLoadConversation);
    on<SendMessage>(_onSendMessage);
    on<NewConversation>(_onNewConversation);
    on<StreamChunkReceived>(_onStreamChunkReceived);
    on<StreamingComplete>(_onStreamingComplete);
    on<SelectModel>(_onSelectModel);
    on<ClearConversation>(_onClearConversation);
    on<DeleteConversation>(_onDeleteConversation);
  }

  void _onLoadConversation(LoadConversation event, Emitter<ChatState> emit) {
    final messages = _repository.getMessages(event.conversationId);
    emit(state.copyWith(
      conversationId: event.conversationId,
      messages: messages,
    ));
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (state.conversationId == null) {
      final id = await _repository.newConversation();
      emit(state.copyWith(conversationId: id));
    }

    // Add user message immediately
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: state.conversationId!,
      role: MessageRole.user,
      content: event.content,
      modelId: event.model.id,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMsg];
    emit(state.copyWith(
      messages: updatedMessages,
      isStreaming: true,
      streamingContent: '',
      error: null,
    ));

    // Start streaming
    _streamSubscription?.cancel();
    _streamSubscription = _repository
        .sendMessage(
          model: event.model,
          conversationId: state.conversationId!,
          userMessage: event.content,
          systemPrompt: event.systemPrompt,
        )
        .listen(
          (chunk) => add(StreamChunkReceived(chunk)),
          onDone: () => add(StreamingComplete()),
          onError: (error) {
            emit(state.copyWith(
              isStreaming: false,
              error: error.toString(),
            ));
          },
        );
  }

  void _onNewConversation(NewConversation event, Emitter<ChatState> emit) {
    emit(const ChatState());
  }

  void _onStreamChunkReceived(StreamChunkReceived event, Emitter<ChatState> emit) {
    emit(state.copyWith(
      streamingContent: state.streamingContent + event.chunk,
    ));
  }

  void _onStreamingComplete(StreamingComplete event, Emitter<ChatState> emit) {
    if (state.streamingContent.isNotEmpty) {
      final assistantMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: state.conversationId!,
        role: MessageRole.assistant,
        content: state.streamingContent,
        modelId: state.selectedModel?.id,
        timestamp: DateTime.now(),
      );
      emit(state.copyWith(
        messages: [...state.messages, assistantMsg],
        isStreaming: false,
        streamingContent: '',
      ));
    } else {
      emit(state.copyWith(isStreaming: false));
    }
  }

  void _onSelectModel(SelectModel event, Emitter<ChatState> emit) {
    emit(state.copyWith(selectedModel: event.model));
  }

  void _onClearConversation(ClearConversation event, Emitter<ChatState> emit) {
    emit(const ChatState());
  }

  void _onDeleteConversation(DeleteConversation event, Emitter<ChatState> emit) {
    _repository.deleteConversation(event.conversationId);
    if (state.conversationId == event.conversationId) {
      emit(const ChatState());
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
