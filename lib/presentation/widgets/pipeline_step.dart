import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/data/models/pipeline_model.dart';

class PipelineStepWidget extends StatelessWidget {
  final PipelineStep step;
  final int stepNumber;

  const PipelineStepWidget({
    super.key,
    required this.step,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
        title: Text(
          step.agentName,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Agent ID: ${step.agentId}',
          style: GoogleFonts.inter(fontSize: 12),
        ),
        trailing: stepNumber > 1
            ? Icon(Icons.arrow_downward,
                color: Theme.of(context).colorScheme.primary, size: 18)
            : null,
      ),
    );
  }
}
