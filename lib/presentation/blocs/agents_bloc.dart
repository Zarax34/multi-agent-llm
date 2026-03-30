import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:multi_agent_llm/data/models/agent_model.dart';
import 'package:multi_agent_llm/data/repositories/agent_repository.dart';

// Events
abstract class AgentsEvent extends Equatable {
  const AgentsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAgents extends AgentsEvent {}

class CreateAgent extends AgentsEvent {
  final String name;
  final String systemPrompt;
  final String modelId;
  final String? description;
  final double temperature;
  final int maxTokens;
  const CreateAgent({
    required this.name,
    required this.systemPrompt,
    required this.modelId,
    this.description,
    this.temperature = 0.7,
    this.maxTokens = 2048,
  });
  @override
  List<Object?> get props => [name, systemPrompt, modelId];
}

class UpdateAgent extends AgentsEvent {
  final AgentModel agent;
  const UpdateAgent(this.agent);
  @override
  List<Object?> get props => [agent];
}

class DeleteAgent extends AgentsEvent {
  final String id;
  const DeleteAgent(this.id);
  @override
  List<Object?> get props => [id];
}

// State
class AgentsState extends Equatable {
  final List<AgentModel> agents;
  final bool isLoading;
  final String? error;

  const AgentsState({
    this.agents = const [],
    this.isLoading = false,
    this.error,
  });

  AgentsState copyWith({
    List<AgentModel>? agents,
    bool? isLoading,
    String? error,
  }) {
    return AgentsState(
      agents: agents ?? this.agents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [agents, isLoading, error];
}

// BLoC
class AgentsBloc extends Bloc<AgentsEvent, AgentsState> {
  final AgentRepository _repository;

  AgentsBloc(this._repository) : super(const AgentsState()) {
    on<LoadAgents>(_onLoadAgents);
    on<CreateAgent>(_onCreateAgent);
    on<UpdateAgent>(_onUpdateAgent);
    on<DeleteAgent>(_onDeleteAgent);
  }

  void _onLoadAgents(LoadAgents event, Emitter<AgentsState> emit) {
    emit(state.copyWith(isLoading: true));
    final agents = _repository.getAgents();
    emit(state.copyWith(agents: agents, isLoading: false));
  }

  void _onCreateAgent(CreateAgent event, Emitter<AgentsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repository.createAgent(
        name: event.name,
        systemPrompt: event.systemPrompt,
        modelId: event.modelId,
        description: event.description,
        temperature: event.temperature,
        maxTokens: event.maxTokens,
      );
      final agents = _repository.getAgents();
      emit(state.copyWith(agents: agents, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onUpdateAgent(UpdateAgent event, Emitter<AgentsState> emit) async {
    await _repository.updateAgent(event.agent);
    final agents = _repository.getAgents();
    emit(state.copyWith(agents: agents));
  }

  void _onDeleteAgent(DeleteAgent event, Emitter<AgentsState> emit) async {
    await _repository.deleteAgent(event.id);
    final agents = _repository.getAgents();
    emit(state.copyWith(agents: agents));
  }
}
