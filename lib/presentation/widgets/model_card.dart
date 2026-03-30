import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/core/theme/app_theme.dart';
import 'package:multi_agent_llm/core/utils/model_utils.dart';
import 'package:multi_agent_llm/data/models/llm_model.dart';

class ModelCard extends StatelessWidget {
  final LlmModel model;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ModelCard({
    super.key,
    required this.model,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildIcon(context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildBackendBadge(context),
                        if (model.sizeBytes != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            ModelUtils.formatSize(model.sizeBytes!),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.secondaryText(context),
                            ),
                          ),
                        ],
                        if (model.ollamaHost != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            model.ollamaHost!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.secondaryText(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (model.family != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        model.family!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.secondaryText(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 20,
                  ),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (model.backendType) {
      case BackendType.localGguf:
        icon = Icons.computer;
        color = Colors.green;
        break;
      case BackendType.ollamaRemote:
        icon = Icons.cloud;
        color = Colors.blue;
        break;
      case BackendType.openaiCompatible:
        icon = Icons.api;
        color = Colors.orange;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildBackendBadge(BuildContext context) {
    String label;
    Color color;

    switch (model.backendType) {
      case BackendType.localGguf:
        label = 'Local';
        color = Colors.green;
        break;
      case BackendType.ollamaRemote:
        label = 'Ollama';
        color = Colors.blue;
        break;
      case BackendType.openaiCompatible:
        label = 'OpenAI';
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
