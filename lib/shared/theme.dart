import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    const primary = Color(0xFF00E676); // vivid green
    const surface = Color(0xFF1A1A2E);
    const card = Color(0xFF16213E);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: const Color(0xFF40C4FF),
        surface: surface,
        surfaceContainer: card,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
      ),
      scaffoldBackgroundColor: surface,
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: primary.withOpacity(0.2),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: Colors.white70),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primary, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: Colors.white54);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: primary.withOpacity(0.2),
        labelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
