import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/app.dart';
import 'package:multi_agent_llm/core/theme/app_theme.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';
import 'package:multi_agent_llm/presentation/blocs/models_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  String _language = 'ar';
  BackendType? _defaultBackend;

  @override
  void initState() {
    super.initState();
    final app = MultiAgentLLMApp.of(context);
    if (app != null) {
      _darkMode = app.themeMode == ThemeMode.dark;
      _language = app.locale.languageCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Appearance
        _buildSectionHeader(context, 'Appearance', Icons.palette),
        _buildThemeToggle(context),
        const SizedBox(height: 8),
        _buildLanguageSelector(context),
        const SizedBox(height: 24),

        // Default Backend
        _buildSectionHeader(context, 'Default Backend', Icons.settings_input_component),
        _buildBackendSelector(context),
        const SizedBox(height: 24),

        // About
        _buildSectionHeader(context, 'About', Icons.info_outline),
        _buildInfoTile(context, 'Version', '1.0.0+1'),
        _buildInfoTile(context, 'Multi-Agent LLM', 'Run models locally or connect to Ollama'),
        const SizedBox(height: 24),

        // Danger Zone
        _buildSectionHeader(context, 'Data', Icons.storage),
        _buildDangerTile(
          context,
          'Clear All Conversations',
          'Delete all chat history',
          Icons.delete_forever,
          () => _showClearConfirm(context),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text('Dark Mode', style: GoogleFonts.inter()),
        subtitle: Text(
          _darkMode ? 'Ollama dark theme' : 'Light theme',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.secondaryText(context),
          ),
        ),
        secondary: Icon(
          _darkMode ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).colorScheme.primary,
        ),
        value: _darkMode,
        onChanged: (value) {
          setState(() => _darkMode = value);
          final app = MultiAgentLLMApp.of(context);
          app?.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
        },
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
        title: Text('Language', style: GoogleFonts.inter()),
        subtitle: Text(
          _language == 'ar' ? 'العربية' : 'English',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.secondaryText(context),
          ),
        ),
        trailing: DropdownButton<String>(
          value: _language,
          dropdownColor: Theme.of(context).colorScheme.surface,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'ar', child: Text('العربية')),
            DropdownMenuItem(value: 'en', child: Text('English')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _language = value);
              final app = MultiAgentLLMApp.of(context);
              app?.setLocale(Locale(value));
            }
          },
        ),
      ),
    );
  }

  Widget _buildBackendSelector(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioListTile<BackendType>(
              title: Text('Local GGUF', style: GoogleFonts.inter()),
              subtitle: Text('Run models on device',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.secondaryText(context))),
              value: BackendType.localGguf,
              groupValue: _defaultBackend,
              onChanged: (v) => setState(() => _defaultBackend = v),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            RadioListTile<BackendType>(
              title: Text('Ollama Remote', style: GoogleFonts.inter()),
              subtitle: Text('Connect to Ollama on LAN',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.secondaryText(context))),
              value: BackendType.ollamaRemote,
              groupValue: _defaultBackend,
              onChanged: (v) => setState(() => _defaultBackend = v),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            RadioListTile<BackendType>(
              title: Text('OpenAI-Compatible', style: GoogleFonts.inter()),
              subtitle: Text('Any OpenAI-compatible API',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.secondaryText(context))),
              value: BackendType.openaiCompatible,
              groupValue: _defaultBackend,
              onChanged: (v) => setState(() => _defaultBackend = v),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title, style: GoogleFonts.inter()),
        subtitle: Text(value,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppTheme.secondaryText(context))),
      ),
    );
  }

  Widget _buildDangerTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: GoogleFonts.inter(color: Colors.red)),
        subtitle: Text(subtitle,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppTheme.secondaryText(context))),
        onTap: onTap,
      ),
    );
  }

  void _showClearConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Clear All Data', style: GoogleFonts.inter()),
        content: const Text('This will delete all conversations. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Clear all conversations
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All conversations cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
