import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multi_agent_llm/app.dart';
import 'package:multi_agent_llm/services/hive_service.dart';
import 'package:multi_agent_llm/data/repositories/chat_repository.dart';
import 'package:multi_agent_llm/data/repositories/model_repository.dart';
import 'package:multi_agent_llm/data/repositories/agent_repository.dart';
import 'package:multi_agent_llm/presentation/blocs/chat_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/models_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/agents_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/pipeline_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/discovery_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveService.init();

  final chatRepository = ChatRepository();
  final modelRepository = ModelRepository();
  final agentRepository = AgentRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: chatRepository),
        RepositoryProvider.value(value: modelRepository),
        RepositoryProvider.value(value: agentRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ChatBloc(chatRepository)),
          BlocProvider(create: (_) => ModelsBloc(modelRepository)),
          BlocProvider(create: (_) => AgentsBloc(agentRepository)),
          BlocProvider(create: (_) => PipelineBloc(chatRepository)),
          BlocProvider(create: (_) => DiscoveryBloc()),
        ],
        child: const MultiAgentLLMApp(),
      ),
    ),
  );
}
