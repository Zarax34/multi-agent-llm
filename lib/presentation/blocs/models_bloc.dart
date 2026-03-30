import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/data/repositories/model_repository.dart';

// Events
abstract class ModelsEvent extends Equatable {
  const ModelsEvent();
  @override
  List<Object?> get props => [];
}

class LoadModels extends ModelsEvent {}

class AddLocalModel extends ModelsEvent {
  final String filePath;
  final String? name;
  const AddLocalModel({required this.filePath, this.name});
  @override
  List<Object?> get props => [filePath, name];
}

class AddOllamaModel extends ModelsEvent {
  final String name;
  final String host;
  final int port;
  const AddOllamaModel({required this.name, required this.host, this.port = 11434});
  @override
  List<Object?> get props => [name, host, port];
}

class AddOpenaiModel extends ModelsEvent {
  final String name;
  final String baseUrl;
  final String? apiKey;
  const AddOpenaiModel({required this.name, required this.baseUrl, this.apiKey});
  @override
  List<Object?> get props => [name, baseUrl, apiKey];
}

class DeleteModel extends ModelsEvent {
  final String id;
  const DeleteModel(this.id);
  @override
  List<Object?> get props => [id];
}

class ImportFromOllama extends ModelsEvent {
  final String host;
  final int port;
  const ImportFromOllama({required this.host, this.port = 11434});
  @override
  List<Object?> get props => [host, port];
}

class FetchOllamaModels extends ModelsEvent {
  final String baseUrl;
  const FetchOllamaModels(this.baseUrl);
  @override
  List<Object?> get props => [baseUrl];
}

// State
class ModelsState extends Equatable {
  final List<LlmModel> models;
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> remoteModels;

  const ModelsState({
    this.models = const [],
    this.isLoading = false,
    this.error,
    this.remoteModels = const [],
  });

  ModelsState copyWith({
    List<LlmModel>? models,
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? remoteModels,
  }) {
    return ModelsState(
      models: models ?? this.models,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      remoteModels: remoteModels ?? this.remoteModels,
    );
  }

  @override
  List<Object?> get props => [models, isLoading, error, remoteModels];
}

// BLoC
class ModelsBloc extends Bloc<ModelsEvent, ModelsState> {
  final ModelRepository _repository;

  ModelsBloc(this._repository) : super(const ModelsState()) {
    on<LoadModels>(_onLoadModels);
    on<AddLocalModel>(_onAddLocalModel);
    on<AddOllamaModel>(_onAddOllamaModel);
    on<AddOpenaiModel>(_onAddOpenaiModel);
    on<DeleteModel>(_onDeleteModel);
    on<ImportFromOllama>(_onImportFromOllama);
    on<FetchOllamaModels>(_onFetchOllamaModels);
  }

  void _onLoadModels(LoadModels event, Emitter<ModelsState> emit) {
    emit(state.copyWith(isLoading: true));
    final models = _repository.getModels();
    emit(state.copyWith(models: models, isLoading: false));
  }

  void _onAddLocalModel(AddLocalModel event, Emitter<ModelsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repository.addLocalModel(event.filePath, name: event.name);
      final models = _repository.getModels();
      emit(state.copyWith(models: models, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onAddOllamaModel(AddOllamaModel event, Emitter<ModelsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repository.addOllamaModel(
        name: event.name,
        host: event.host,
        port: event.port,
      );
      final models = _repository.getModels();
      emit(state.copyWith(models: models, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onAddOpenaiModel(AddOpenaiModel event, Emitter<ModelsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repository.addOpenaiModel(
        name: event.name,
        baseUrl: event.baseUrl,
        apiKey: event.apiKey,
      );
      final models = _repository.getModels();
      emit(state.copyWith(models: models, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onDeleteModel(DeleteModel event, Emitter<ModelsState> emit) async {
    await _repository.deleteModel(event.id);
    final models = _repository.getModels();
    emit(state.copyWith(models: models));
  }

  void _onImportFromOllama(ImportFromOllama event, Emitter<ModelsState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await _repository.importFromOllama(event.host, event.port);
      final models = _repository.getModels();
      emit(state.copyWith(models: models, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onFetchOllamaModels(FetchOllamaModels event, Emitter<ModelsState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final remoteModels = await _repository.fetchOllamaModels(event.baseUrl);
      emit(state.copyWith(remoteModels: remoteModels, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
