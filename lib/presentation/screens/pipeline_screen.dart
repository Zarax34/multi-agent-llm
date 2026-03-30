import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/core/theme/app_theme.dart';
import 'package:multi_agent_llm/data/models/pipeline_model.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/presentation/blocs/pipeline_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/agents_bloc.dart';
import 'package:multi_agent_llm/presentation/blocs/models_bloc.dart';
import 'package:multi_agent_llm/presentation/widgets/pipeline_step.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  final TextEditingController _inputController = TextEditingController();
  String? _selectedPipelineId;

  @override
  void initState() {
    super.initState();
    context.read<PipelineBloc>().add(LoadPipelines());
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PipelineBloc, PipelineState>(
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              // Pipeline selector and actions
              _buildHeader(context, state),

              // Pipeline steps or empty state
              Expanded(
                child: _selectedPipelineId != null
                    ? _buildPipelineDetail(context, state)
                    : state.pipelines.isEmpty
                        ? _buildEmptyState(context)
                        : _buildPipelineList(context, state),
              ),

              // Run section
              if (_selectedPipelineId != null) _buildRunSection(context, state),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreatePipelineDialog(context),
            icon: const Icon(Icons.add),
            label: Text('New Pipeline', style: GoogleFonts.inter()),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PipelineState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.account_tree, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedPipelineId,
                hint: Text('Select a pipeline', style: GoogleFonts.inter()),
                dropdownColor: Theme.of(context).colorScheme.surface,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Pipelines'),
                  ),
                  ...state.pipelines.map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name),
                  )),
                ],
                onChanged: (v) => setState(() => _selectedPipelineId = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_tree_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No pipelines yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a pipeline to chain agents together',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineList(BuildContext context, PipelineState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.pipelines.length,
      itemBuilder: (context, index) {
        final pipeline = state.pipelines[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.account_tree,
                color: Theme.of(context).colorScheme.primary),
            title: Text(pipeline.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${pipeline.steps.length} steps',
              style: GoogleFonts.inter(color: AppTheme.secondaryText(context)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                context.read<PipelineBloc>().add(DeletePipeline(pipeline.id));
              },
            ),
            onTap: () => setState(() => _selectedPipelineId = pipeline.id),
          ),
        );
      },
    );
  }

  Widget _buildPipelineDetail(BuildContext context, PipelineState state) {
    final pipeline = state.pipelines.firstWhere(
      (p) => p.id == _selectedPipelineId,
      orElse: () => state.pipelines.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedPipelineId = null),
              ),
              const SizedBox(width: 8),
              Text(
                pipeline.name,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: pipeline.steps.length,
            onReorder: (oldIndex, newIndex) {
              context.read<PipelineBloc>().add(ReorderSteps(
                pipelineId: pipeline.id,
                oldIndex: oldIndex,
                newIndex: newIndex,
              ));
            },
            itemBuilder: (context, index) {
              final step = pipeline.steps[index];
              return PipelineStepWidget(
                key: ValueKey(step.id),
                step: step,
                stepNumber: index + 1,
              );
            },
          ),
        ),
        // Output area
        if (state.output.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Output:',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(state.output,
                        style: GoogleFonts.inter(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRunSection(BuildContext context, PipelineState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: 'Enter input for pipeline...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: state.isRunning ? null : () => _runPipeline(context),
              icon: state.isRunning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(state.isRunning ? 'Running...' : 'Run'),
            ),
          ],
        ),
      ),
    );
  }

  void _runPipeline(BuildContext context) {
    if (_inputController.text.isEmpty || _selectedPipelineId == null) return;

    final modelsState = context.read<ModelsBloc>().state;
    final pipelineState = context.read<PipelineBloc>().state;
    final pipeline = pipelineState.pipelines.firstWhere(
      (p) => p.id == _selectedPipelineId,
    );

    final models = pipeline.steps.map((step) {
      return modelsState.models.firstWhere(
        (m) => m.id == step.agentId,
        orElse: () => modelsState.models.isNotEmpty
            ? modelsState.models.first
            : LlmModel(
                id: 'default',
                name: 'default',
                backendType: BackendType.localGguf,
                createdAt: DateTime.now(),
              ),
      );
    }).toList();

    context.read<PipelineBloc>().add(RunPipeline(
      pipelineId: _selectedPipelineId!,
      input: _inputController.text,
      models: models,
    ));
  }

  void _showCreatePipelineDialog(BuildContext context) {
    final nameController = TextEditingController();
    final agentsState = context.read<AgentsBloc>().state;
    final selectedAgentIds = <String>[];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text('Create Pipeline', style: GoogleFonts.inter()),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pipeline Name',
                    hintText: 'My Pipeline',
                  ),
                ),
                const SizedBox(height: 16),
                Text('Select agents (in order):',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: agentsState.agents.length,
                    itemBuilder: (context, index) {
                      final agent = agentsState.agents[index];
                      final selected = selectedAgentIds.contains(agent.id);
                      return CheckboxListTile(
                        value: selected,
                        title: Text(agent.name),
                        subtitle: Text(agent.systemPrompt.substring(
                            0, agent.systemPrompt.length.clamp(0, 50))),
                        onChanged: (v) {
                          setDialogState(() {
                            if (v == true) {
                              selectedAgentIds.add(agent.id);
                            } else {
                              selectedAgentIds.remove(agent.id);
                            }
                          });
                        },
                      );
                    },
                  ),
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
                if (nameController.text.isNotEmpty && selectedAgentIds.isNotEmpty) {
                  final steps = selectedAgentIds.asMap().entries.map((entry) {
                    final agent = agentsState.agents.firstWhere((a) => a.id == entry.value);
                    return PipelineStep(
                      id: 'step_${entry.key}',
                      agentId: entry.value,
                      agentName: agent.name,
                      order: entry.key,
                    );
                  }).toList();

                  context.read<PipelineBloc>().add(CreatePipeline(
                    name: nameController.text,
                    steps: steps,
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
}
