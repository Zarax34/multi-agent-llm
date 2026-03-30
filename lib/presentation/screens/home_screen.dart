import 'package:flutter/material.dart';
import 'package:multi_agent_llm/presentation/screens/chat_screen.dart';
import 'package:multi_agent_llm/presentation/screens/models_screen.dart';
import 'package:multi_agent_llm/presentation/screens/agents_screen.dart';
import 'package:multi_agent_llm/presentation/screens/pipeline_screen.dart';
import 'package:multi_agent_llm/presentation/screens/settings_screen.dart';
import 'package:multi_agent_llm/presentation/screens/ollama_discover_screen.dart';
import 'package:multi_agent_llm/presentation/widgets/sidebar.dart';
import 'package:multi_agent_llm/presentation/blocs/models_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/agents_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/discovery_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ChatScreen(),
    ModelsScreen(),
    AgentsScreen(),
    PipelineScreen(),
    OllamaDiscoverScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<ModelsBloc>().add(LoadModels());
    context.read<AgentsBloc>().add(LoadAgents());
    context.read<DiscoveryBloc>().add(LoadSavedInstances());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                Sidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (i) => setState(() => _selectedIndex = i),
                ),
                // Subtle border
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          );
        }

        // Mobile layout — bottom nav
        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex.clamp(0, 4),
            onDestinationSelected: (i) {
              if (i < 5) setState(() => _selectedIndex = i);
            },
            height: 56,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline, size: 20),
                selectedIcon: Icon(Icons.chat_bubble, size: 20),
                label: 'Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.storage_outlined, size: 20),
                selectedIcon: Icon(Icons.storage, size: 20),
                label: 'Models',
              ),
              NavigationDestination(
                icon: Icon(Icons.smart_toy_outlined, size: 20),
                selectedIcon: Icon(Icons.smart_toy, size: 20),
                label: 'Agents',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_tree_outlined, size: 20),
                selectedIcon: Icon(Icons.account_tree, size: 20),
                label: 'Pipeline',
              ),
              NavigationDestination(
                icon: Icon(Icons.wifi_find_outlined, size: 20),
                selectedIcon: Icon(Icons.wifi_find, size: 20),
                label: 'Ollama',
              ),
            ],
          ),
        );
      },
    );
  }
}
