import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:multi_agent_llm/core/theme/app_theme.dart';

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
    return Container(
      width: 260,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multi-Agent',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'LLM System',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Navigation items
          _buildNavItem(
            context,
            icon: Icons.chat_bubble_outline,
            selectedIcon: Icons.chat_bubble,
            label: 'Chat',
            index: 0,
          ),
          _buildNavItem(
            context,
            icon: Icons.model_training_outlined,
            selectedIcon: Icons.model_training,
            label: 'Models',
            index: 1,
          ),
          _buildNavItem(
            context,
            icon: Icons.smart_toy_outlined,
            selectedIcon: Icons.smart_toy,
            label: 'Agents',
            index: 2,
          ),
          _buildNavItem(
            context,
            icon: Icons.account_tree_outlined,
            selectedIcon: Icons.account_tree,
            label: 'Pipeline',
            index: 3,
          ),
          _buildNavItem(
            context,
            icon: Icons.wifi_find_outlined,
            selectedIcon: Icons.wifi_find,
            label: 'Ollama Discovery',
            index: 4,
          ),

          const Spacer(),

          const Divider(height: 1),

          _buildNavItem(
            context,
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: 'Settings',
            index: 5,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => onItemSelected(index),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : AppTheme.secondaryText(context),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : AppTheme.secondaryText(context),
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
