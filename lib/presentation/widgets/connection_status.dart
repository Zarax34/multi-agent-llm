import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shows connection status indicator
class ConnectionStatus extends StatelessWidget {
  final bool isConnected;
  final String? label;

  const ConnectionStatus({
    super.key,
    required this.isConnected,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? Colors.green : Colors.red,
          ),
        ),
        if (label != null) ...[
          const SizedBox(width: 6),
          Text(
            label!,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}
