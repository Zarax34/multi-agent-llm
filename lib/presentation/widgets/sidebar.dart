import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Minimal Ollama-style sidebar
class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textCol = isDark ? const Color(0xFFE5E5E5) : Colors.black;
    final mutedCol = isDark ? const Color(0xFF737373) : Colors.grey.shade600;
    final bgCol = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFFAFAFA);
    final hoverCol = isDark ? const Color(0xFF171717) : Colors.grey.shade100;
    final borderCol = isDark ? const Color(0xFF262626) : Colors.grey.shade300;

    return Container(
      width: 260,
      color: bgCol,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo header — minimal
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              children: [
                Text(
                  'ollama',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textCol,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                Icon(Icons.add, size: 18, color: mutedCol),
              ],
            ),
          ),

          Divider(color: borderCol, height: 1),

          const SizedBox(height: 8),

          // Main nav items
          _item(context, Icons.chat_bubble_outline, 'New chat', -1, textCol, mutedCol, hoverCol),

          const SizedBox(height: 16),

          // Section label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Navigation',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: mutedCol,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 4),

          _item(context, Icons.chat_bubble_outline, 'Chat', 0, textCol, mutedCol, hoverCol),
          _item(context, Icons.storage_outlined, 'Models', 1, textCol, mutedCol, hoverCol),
          _item(context, Icons.smart_toy_outlined, 'Agents', 2, textCol, mutedCol, hoverCol),
          _item(context, Icons.account_tree_outlined, 'Pipeline', 3, textCol, mutedCol, hoverCol),
          _item(context, Icons.wifi_find_outlined, 'Ollama', 4, textCol, mutedCol, hoverCol),

          const Spacer(),

          Divider(color: borderCol, height: 1),

          _item(context, Icons.settings_outlined, 'Settings', 5, textCol, mutedCol, hoverCol),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    Color textCol,
    Color mutedCol,
    Color hoverCol,
  ) {
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: isSelected ? hoverCol : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: isSelected ? textCol : mutedCol),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected ? textCol : mutedCol,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
