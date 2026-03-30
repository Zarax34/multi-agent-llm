import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:multi_agent_llm/data/models/pipeline_model.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/data/repositories/chat_repository.dart';
import 'package:multi_agent_llm/services/hive_service.dart';
import 'package:uuid/uuid.dart';

// Events
abstract class PipelineEvent extends Equatable {
  const PipelineEvent();
  @override
  List<Object?> get props => [];
}

class LoadPipelines extends PipelineEvent {}

class CreatePipeline extends PipelineEvent {
  final String name;
  final List<PipelineStep> steps;
  final String? description;
  const CreatePipeline({required this.name, required this.steps, this.description});
  @override
  List<Object?> get props => [name, steps, description];
}

class UpdatePipeline extends PipelineEvent {
  final PipelineModel pipeline;
  const UpdatePipeline(this.pipeline);
  @override
  List<Object?> get props => [pipeline];
}

class DeletePipeline extends PipelineEvent {
  final String id;
  const DeletePipeline(this.id);
  @override
  List<Object?> get props => [id];
}

class RunPipeline extends PipelineEvent {
  final String pipelineId;
  final String input;
  final List<LlmModel> models;
  const RunPipeline({required this.pipelineId, required this.input, required this.models});
  @override
  List<Object?> get props => [pipelineId, input, models];
}

class PipelineChunkReceived extends PipelineEvent {
  final String chunk;
  const PipelineChunkReceived(this.chunk);
  @override
  List<Object?> get props => [chunk];
}

class PipelineComplete extends PipelineEvent {}

class ReorderSteps extends PipelineEvent {
  final String pipelineId;
  final int oldIndex;
  final int newIndex;
  const ReorderSteps({required this.pipelineId, required this.oldIndex, required this.newIndex});
  @override
  List<Object?> get props => [pipelineId, oldIndex, newIndex];
}

// State
class PipelineState extends Equatable {
  final List<PipelineModel> pipelines;
  final bool isRunning;
  final String output;
  final int currentStep;
  final bool isLoading;
  final String? error;

  const PipelineState({
    this.pipelines = const [],
    this.isRunning = false,
    this.output = '',
    this.currentStep = 0,
    this.isLoading = false,
    this.error,
  });

  PipelineState copyWith({
    List<PipelineModel>? pipelines,
    bool? isRunning,
    String? output,
    int? currentStep,
    bool? isLoading,
    String? error,
  }) {
    return PipelineState(
      pipelines: pipelines ?? this.pipelines,
      isRunning: isRunning ?? this.isRunning,
      output: output ?? this.output,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [pipelines, isRunning, output, currentStep, isLoading, error];
}

// BLoC
class PipelineBloc extends Bloc<PipelineEvent, PipelineState> {
  final ChatRepository _chatRepository;
  final HiveService _hiveService = HiveService();
  final _uuid = const Uuid();
  StreamSubscription<String>? _streamSubscription;

  PipelineBloc(this._chatRepository) : super(const PipelineState()) {
    on<LoadPipelines>(_onLoadPipelines);
    on<CreatePipeline>(_onCreatePipeline);
    on<UpdatePipeline>(_onUpdatePipeline);
    on<DeletePipeline>(_onDeletePipeline);
    on<RunPipeline>(_onRunPipeline);
    on<PipelineChunkReceived>(_onPipelineChunkReceived);
    on<PipelineComplete>(_onPipelineComplete);
    on<ReorderSteps>(_onReorderSteps);
  }

  void _onLoadPipelines(LoadPipelines event, Emitter<PipelineState> emit) {
    emit(state.copyWith(isLoading: true));
    final pipelines = _hiveService.getPipelines();
    emit(state.copyWith(pipelines: pipelines, isLoading: false));
  }

  void _onCreatePipeline(CreatePipeline event, Emitter<PipelineState> emit) async {
    final pipeline = PipelineModel(
      id: _uuid.v4(),
      name: event.name,
      description: event.description,
      steps: event.steps,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _hiveService.savePipeline(pipeline);
    final pipelines = _hiveService.getPipelines();
    emit(state.copyWith(pipelines: pipelines));
  }

  void _onUpdatePipeline(UpdatePipeline event, Emitter<PipelineState> emit) async {
    final updated = event.pipeline.copyWith(updatedAt: DateTime.now());
    await _hiveService.savePipeline(updated);
    final pipelines = _hiveService.getPipelines();
    emit(state.copyWith(pipelines: pipelines));
  }

  void _onDeletePipeline(DeletePipeline event, Emitter<PipelineState> emit) async {
    await _hiveService.deletePipeline(event.id);
    final pipelines = _hiveService.getPipelines();
    emit(state.copyWith(pipelines: pipelines));
  }

  void _onRunPipeline(RunPipeline event, Emitter<PipelineState> emit) async {
    emit(state.copyWith(isRunning: true, output: '', currentStep: 0, error: null));

    final systemPrompts = event.models.map((m) => '').toList();

    _streamSubscription?.cancel();
    _streamSubscription = _chatRepository
        .runPipeline(
          models: event.models,
          systemPrompts: systemPrompts,
          conversationId: event.pipelineId,
          input: event.input,
        )
        .listen(
          (chunk) => add(PipelineChunkReceived(chunk)),
          onDone: () => add(PipelineComplete()),
          onError: (error) {
            emit(state.copyWith(isRunning: false, error: error.toString()));
          },
        );
  }

  void _onPipelineChunkReceived(PipelineChunkReceived event, Emitter<PipelineState> emit) {
    emit(state.copyWith(output: state.output + event.chunk));
  }

  void _onPipelineComplete(PipelineComplete event, Emitter<PipelineState> emit) {
    emit(state.copyWith(isRunning: false));
  }

  void _onReorderSteps(ReorderSteps event, Emitter<PipelineState> emit) async {
    final pipeline = state.pipelines.firstWhere((p) => p.id == event.pipelineId);
    final steps = List<PipelineStep>.from(pipeline.steps);

    if (event.oldIndex < event.newIndex) {
      final item = steps.removeAt(event.oldIndex);
      steps.insert(event.newIndex - 1, item);
    } else {
      final item = steps.removeAt(event.oldIndex);
      steps.insert(event.newIndex, item);
    }

    // Update order
    for (int i = 0; i < steps.length; i++) {
      steps[i] = steps[i].copyWith(order: i);
    }

    final updated = pipeline.copyWith(steps: steps, updatedAt: DateTime.now());
    await _hiveService.savePipeline(updated);
    final pipelines = _hiveService.getPipelines();
    emit(state.copyWith(pipelines: pipelines));
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
