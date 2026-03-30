import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated streaming text widget for real-time LLM responses
class StreamingText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const StreamingText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<StreamingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SelectableText(
            widget.text,
            style: widget.style ?? GoogleFonts.inter(fontSize: 14),
          ),
        ),
        FadeTransition(
          opacity: _cursorController,
          child: Container(
            width: 2,
            height: 16,
            margin: const EdgeInsets.only(left: 2, top: 3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }
}
