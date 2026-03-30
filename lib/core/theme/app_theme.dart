import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ollama dark colors
  static const Color _darkBackground = Color(0xFF1E1E2E);
  static const Color _darkSurface = Color(0xFF2A2A3E);
  static const Color _darkPrimary = Color(0xFF7C6FE0);
  static const Color _darkText = Color(0xFFE0E0E0);
  static const Color _darkChatUserBubble = Color(0xFF3A3A5E);
  static const Color _darkChatAssistantBubble = Color(0xFF2A2A3E);
  static const Color _darkSecondaryText = Color(0xFF9E9E9E);
  static const Color _darkDivider = Color(0xFF3A3A5E);
  static const Color _darkError = Color(0xFFFF6B6B);
  static const Color _darkSuccess = Color(0xFF69DB7C);

  // Light colors
  static const Color _lightBackground = Color(0xFFF5F5F5);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightPrimary = Color(0xFF6C5CE7);
  static const Color _lightText = Color(0xFF2D3436);
  static const Color _lightChatUserBubble = Color(0xFF6C5CE7);
  static const Color _lightChatAssistantBubble = Color(0xFFF0F0F0);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkPrimary,
        surface: _darkSurface,
        error: _darkError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _darkText,
        onError: Colors.white,
      ),
      textTheme: textTheme.apply(
        bodyColor: _darkText,
        displayColor: _darkText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: _darkText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        hintStyle: TextStyle(color: _darkSecondaryText),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _darkPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconTheme: const IconThemeData(color: _darkText, size: 22),
      dividerTheme: const DividerThemeData(
        color: _darkDivider,
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: _darkText,
        iconColor: _darkText,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _darkSurface,
        selectedIconTheme: const IconThemeData(color: _darkPrimary),
        unselectedIconTheme: const IconThemeData(color: _darkSecondaryText),
        selectedLabelTextStyle: GoogleFonts.inter(color: _darkPrimary, fontSize: 12),
        unselectedLabelTextStyle: GoogleFonts.inter(color: _darkSecondaryText, fontSize: 12),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: _darkSurface,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurface,
        selectedColor: _darkPrimary.withOpacity(0.3),
        labelStyle: GoogleFonts.inter(color: _darkText),
        side: const BorderSide(color: _darkDivider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _darkPrimary;
          return _darkSecondaryText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _darkPrimary.withOpacity(0.3);
          }
          return _darkDivider;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: _darkSecondaryText,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightPrimary,
        surface: _lightSurface,
        error: Color(0xFFFF6B6B),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightText,
        onError: Colors.white,
      ),
      textTheme: textTheme.apply(
        bodyColor: _lightText,
        displayColor: _lightText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: _lightText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Custom colors accessible from anywhere
  static Color chatUserBubble(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkChatUserBubble
          : _lightChatUserBubble;

  static Color chatAssistantBubble(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkChatAssistantBubble
          : _lightChatAssistantBubble;

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkSecondaryText
          : Colors.grey.shade600;
}
