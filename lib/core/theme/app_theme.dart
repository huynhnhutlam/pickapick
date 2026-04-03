import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // High-Definition Contrast Palette
  static const Color primaryColor = Color(0xFFD4FF00); // Electric Lime
  static const Color accentColor = Color(0xFF00FFD1); // Electric Aqua
  static const Color backgroundColor =
      Color(0xFF000000); // Pure Black (Contrast King)
  static const Color surfaceColor = Color(0xFF161616); // visible Surface
  static const Color cardColor = Color(0xFF1E1E1E); // Card Surface

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        onPrimary: Colors.black,
        secondary: accentColor,
        onSecondary: Colors.black,
        surface: surfaceColor,
        onSurface: Colors.white,
        surfaceContainer: Color(0xFF121212),
        onSurfaceVariant: Colors.white, // Critical for visibility
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 34,
          letterSpacing: -1.0,
        ),
        titleLarge: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: Colors.white.withValues(alpha: 0.9), // Bright text
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white10),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.white10,
        thickness: 1,
      ),
    );
  }
}
