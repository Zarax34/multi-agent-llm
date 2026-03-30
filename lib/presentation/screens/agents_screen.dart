import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/core/theme/app_theme.dart';
import 'package:multi_agent_llm/data/models/agent_model.dart';
import 'package:multi_agent_llm/presentation/blocs/agents_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/models_bloc.dart';
import 'package:multi_agent_llm/presentation/widgets/agent_card.dart';

class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgentsBloc, AgentsState>(
      builder: (context, state) {
        return Scaffold(
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.agents.isEmpty
                  ? _buildEmptyState(context)
                  : _buildAgentsList(context, state),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateAgentDialog(context),
            icon: const Icon(Icons.add),
            label: Text('New Agent', style: GoogleFonts.inter()),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.smart_toy_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No agents yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create an agent with a custom system prompt',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateAgentDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Agent'),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsList(BuildContext context, AgentsState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.agents.length,
      itemBuilder: (context, index) {
        final agent = state.agents[index];
        return AgentCard(
          agent: agent,
          onEdit: () => _showEditAgentDialog(context, agent),
          onDelete: () => _showDeleteConfirm(context, agent),
        );
      },
    );
  }

  void _showCreateAgentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final promptController = TextEditingController();
    final descController = TextEditingController();
    String? selectedModelId;
    double temperature = 0.7;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Create Agent', style: GoogleFonts.inter()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Agent Name',
                    hintText: 'Code Reviewer',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Reviews code for best practices',
                  ),
                ),
                const SizedBox(height: 12),
                BlocBuilder<ModelsBloc, ModelsState>(
                  builder: (context, modelsState) {
                    return DropdownButtonFormField<String>(
                      value: selectedModelId,
                      decoration: const InputDecoration(labelText: 'Model'),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      items: modelsState.models.map((m) {
                        return DropdownMenuItem(value: m.id, child: Text(m.name));
                      }).toList(),
                      onChanged: (v) => setDialogState(() => selectedModelId = v),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: promptController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'System Prompt',
                    hintText: 'You are a helpful assistant that...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Temperature: ${temperature.toStringAsFixed(1)}',
                        style: GoogleFonts.inter(fontSize: 14)),
                    Expanded(
                      child: Slider(
                        value: temperature,
                        min: 0.0,
                        max: 2.0,
                        divisions: 20,
                        onChanged: (v) => setDialogState(() => temperature = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    promptController.text.isNotEmpty &&
                    selectedModelId != null) {
                  context.read<AgentsBloc>().add(CreateAgent(
                    name: nameController.text,
                    systemPrompt: promptController.text,
                    modelId: selectedModelId!,
                    description: descController.text.isNotEmpty ? descController.text : null,
                    temperature: temperature,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAgentDialog(BuildContext context, AgentModel agent) {
    final nameController = TextEditingController(text: agent.name);
    final promptController = TextEditingController(text: agent.systemPrompt);
    final descController = TextEditingController(text: agent.description);
    String selectedModelId = agent.modelId;
    double temperature = agent.temperature;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Edit Agent', style: GoogleFonts.inter()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Agent Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                BlocBuilder<ModelsBloc, ModelsState>(
                  builder: (context, modelsState) {
                    return DropdownButtonFormField<String>(
                      value: selectedModelId,
                      decoration: const InputDecoration(labelText: 'Model'),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      items: modelsState.models.map((m) {
                        return DropdownMenuItem(value: m.id, child: Text(m.name));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedModelId = v);
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: promptController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'System Prompt',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Temperature: ${temperature.toStringAsFixed(1)}',
                        style: GoogleFonts.inter(fontSize: 14)),
                    Expanded(
                      child: Slider(
                        value: temperature,
                        min: 0.0,
                        max: 2.0,
                        divisions: 20,
                        onChanged: (v) => setDialogState(() => temperature = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AgentsBloc>().add(UpdateAgent(
                  agent.copyWith(
                    name: nameController.text,
                    systemPrompt: promptController.text,
                    description: descController.text,
                    modelId: selectedModelId,
                    temperature: temperature,
                  ),
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AgentModel agent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Delete Agent', style: GoogleFonts.inter()),
        content: Text('Are you sure you want to delete "${agent.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AgentsBloc>().add(DeleteAgent(agent.id));
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
