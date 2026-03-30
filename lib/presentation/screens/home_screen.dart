import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  final List<String> _titles = [
    'Chat',
    'Models',
    'Agents',
    'Pipeline',
    'Ollama Discovery',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<ModelsBloc>().add(LoadModels());
    context.read<AgentsBloc>().add(LoadAgents());
    context.read<DiscoveryBloc>().add(LoadSavedInstances());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        if (isWide) {
          return _buildWideLayout();
        }
        return _buildNarrowLayout();
      },
    );
  }

  Widget _buildWideLayout() {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) => setState(() => _selectedIndex = index),
          ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(_titles[_selectedIndex]),
                  automaticallyImplyLeading: false,
                ),
                Expanded(child: _screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout() {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      drawer: Drawer(
        child: Sidebar(
          selectedIndex: _selectedIndex,
          onItemSelected: (index) {
            setState(() => _selectedIndex = index);
            Navigator.pop(context);
          },
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex.clamp(0, 4),
        onDestinationSelected: (index) {
          if (index < 5) setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.model_training_outlined),
            selectedIcon: Icon(Icons.model_training),
            label: 'Models',
          ),
          NavigationDestination(
            icon: Icon(Icons.smart_toy_outlined),
            selectedIcon: Icon(Icons.smart_toy),
            label: 'Agents',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree),
            label: 'Pipeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.wifi_find_outlined),
            selectedIcon: Icon(Icons.wifi_find),
            label: 'Discover',
          ),
        ],
      ),
    );
  }
}
