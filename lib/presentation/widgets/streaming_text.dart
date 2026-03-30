import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Minimal streaming text with subtle cursor
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
  late AnimationController _cursor;

  @override
  void initState() {
    super.initState();
    _cursor = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SelectableText(
      widget.text,
      style: widget.style ?? GoogleFonts.inter(
        fontSize: 14,
        height: 1.6,
      ),
    );
  }
}
