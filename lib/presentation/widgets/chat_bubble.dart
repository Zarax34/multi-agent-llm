import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/data/models/chat_message.dart';

/// Clean Ollama-style chat bubble
class ChatBubble extends StatelessWidget {
  final MessageRole role;
  final Widget child;

  const ChatBubble({
    super.key,
    required this.role,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role label
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isUser
                        ? (isDark ? const Color(0xFF262626) : Colors.grey.shade200)
                        : (isDark ? const Color(0xFF171717) : Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    isUser ? Icons.person_outline : Icons.auto_awesome,
                    size: 12,
                    color: isUser
                        ? (isDark ? const Color(0xFF737373) : Colors.grey.shade600)
                        : (isDark ? const Color(0xFFA3A3A3) : Colors.blue),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isUser ? 'You' : 'Assistant',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF737373) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Message content — no bubble background, just text
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: child,
          ),
        ],
      ),
    );
  }
}
