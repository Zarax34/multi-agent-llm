import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/data/models/ollama_instance.dart';

/// Shows connection status card for an Ollama instance
class ConnectionStatusCard extends StatelessWidget {
  final OllamaInstance instance;
  final VoidCallback? onRemove;
  final VoidCallback? onTest;

  const ConnectionStatusCard({
    super.key,
    required this.instance,
    this.onRemove,
    this.onTest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: instance.isOnline ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          instance.name ?? instance.ip,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${instance.ip}:${instance.port}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onTest != null)
              IconButton(
                icon: const Icon(Icons.wifi_tethering, size: 20),
                onPressed: onTest,
                tooltip: 'Test connection',
              ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                onPressed: onRemove,
                tooltip: 'Remove',
              ),
          ],
        ),
      ),
    );
  }
}
