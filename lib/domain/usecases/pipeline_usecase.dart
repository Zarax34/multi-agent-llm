import 'dart:async';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/data/repositories/chat_repository.dart';

class PipelineUseCase {
  final ChatRepository _repository;

  PipelineUseCase(this._repository);

  /// Run a pipeline of models
  Stream<String> runPipeline({
    required List<LlmModel> models,
    required List<String> systemPrompts,
    required String conversationId,
    required String input,
    double temperature = 0.7,
  }) {
    return _repository.runPipeline(
      models: models,
      systemPrompts: systemPrompts,
      conversationId: conversationId,
      input: input,
      temperature: temperature,
    );
  }
}
