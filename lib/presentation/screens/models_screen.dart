import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:multi_agent_llm/core/theme/app_theme.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/presentation/blocs/models_bloc.dart';
import 'package:multi_agent_llm/presentation/widgets/model_card.dart';

class ModelsScreen extends StatelessWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModelsBloc, ModelsState>(
      builder: (context, state) {
        return Scaffold(
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.models.isEmpty
                  ? _buildEmptyState(context)
                  : _buildModelsList(context, state),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddModelDialog(context),
            icon: const Icon(Icons.add),
            label: Text('Add Model', style: GoogleFonts.inter()),
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
          Icon(Icons.model_training_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No models yet',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Import a GGUF model or connect to Ollama',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddModelDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Model'),
          ),
        ],
      ),
    );
  }

  Widget _buildModelsList(BuildContext context, ModelsState state) {
    // Group models by backend type
    final localModels = state.models.where((m) => m.backendType == BackendType.localGguf).toList();
    final ollamaModels = state.models.where((m) => m.backendType == BackendType.ollamaRemote).toList();
    final openaiModels = state.models.where((m) => m.backendType == BackendType.openaiCompatible).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (localModels.isNotEmpty) ...[
          _buildSectionHeader(context, 'Local GGUF Models', Icons.computer, localModels.length),
          const SizedBox(height: 8),
          ...localModels.map((m) => ModelCard(
            model: m,
            onDelete: () => context.read<ModelsBloc>().add(DeleteModel(m.id)),
          )),
          const SizedBox(height: 24),
        ],
        if (ollamaModels.isNotEmpty) ...[
          _buildSectionHeader(context, 'Ollama Remote Models', Icons.cloud, ollamaModels.length),
          const SizedBox(height: 8),
          ...ollamaModels.map((m) => ModelCard(
            model: m,
            onDelete: () => context.read<ModelsBloc>().add(DeleteModel(m.id)),
          )),
          const SizedBox(height: 24),
        ],
        if (openaiModels.isNotEmpty) ...[
          _buildSectionHeader(context, 'OpenAI-Compatible Models', Icons.api, openaiModels.length),
          const SizedBox(height: 8),
          ...openaiModels.map((m) => ModelCard(
            model: m,
            onDelete: () => context.read<ModelsBloc>().add(DeleteModel(m.id)),
          )),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  void _showAddModelDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Model',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              context,
              icon: Icons.folder_open,
              title: 'Import GGUF File',
              subtitle: 'Run models locally on device',
              color: Colors.green,
              onTap: () {
                Navigator.pop(ctx);
                _importGgufFile(context);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context,
              icon: Icons.cloud,
              title: 'Connect Ollama Server',
              subtitle: 'Connect to Ollama on LAN',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(ctx);
                _showOllamaDialog(context);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              context,
              icon: Icons.api,
              title: 'OpenAI-Compatible API',
              subtitle: 'Any OpenAI-compatible endpoint',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(ctx);
                _showOpenaiDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.secondaryText(context))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.secondaryText(context)),
          ],
        ),
      ),
    );
  }

  Future<void> _importGgufFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gguf'],
      );

      if (result != null && result.files.single.path != null) {
        context.read<ModelsBloc>().add(AddLocalModel(
          filePath: result.files.single.path!,
          name: result.files.single.name.replaceAll('.gguf', ''),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  void _showOllamaDialog(BuildContext context) {
    final nameController = TextEditingController();
    final hostController = TextEditingController();
    final portController = TextEditingController(text: '11434');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Connect Ollama Server', style: GoogleFonts.inter()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'My Ollama Server',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: hostController,
              decoration: const InputDecoration(
                labelText: 'Host IP',
                hintText: '192.168.1.100',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '11434',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (hostController.text.isNotEmpty) {
                context.read<ModelsBloc>().add(AddOllamaModel(
                  name: nameController.text.isNotEmpty
                      ? nameController.text
                      : hostController.text,
                  host: hostController.text,
                  port: int.tryParse(portController.text) ?? 11434,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showOpenaiDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    final apiKeyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('OpenAI-Compatible API', style: GoogleFonts.inter()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'My API',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'https://api.example.com',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key (optional)',
                hintText: 'sk-...',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                context.read<ModelsBloc>().add(AddOpenaiModel(
                  name: nameController.text.isNotEmpty
                      ? nameController.text
                      : 'OpenAI Compatible',
                  baseUrl: urlController.text,
                  apiKey: apiKeyController.text.isNotEmpty
                      ? apiKeyController.text
                      : null,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
