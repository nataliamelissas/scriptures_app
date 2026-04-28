import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _seed = Color(0xFF2C5F6E); // Deep teal — calm, scholarly

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFFCFAF7), // warm parchment
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        backgroundColor: const Color(0xFFFCFAF7),
        titleTextStyle: GoogleFonts.merriweather(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: scheme.outlineVariant.withAlpha(80)),
        ),
        color: Colors.white,
      ),
      textTheme: _textTheme(scheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    return TextTheme(
      // Used for volume/book titles
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      headlineSmall: GoogleFonts.merriweather(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      // Used for chapter titles
      titleLarge: GoogleFonts.merriweather(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      // Scripture body text — optimized for extended reading
      bodyLarge: GoogleFonts.sourceSerif4(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: const Color(0xFF2D2D2D),
      ),
      bodyMedium: GoogleFonts.lato(
        fontSize: 14,
        height: 1.5,
        color: scheme.onSurfaceVariant,
      ),
      bodySmall: GoogleFonts.lato(
        fontSize: 12,
        color: scheme.onSurfaceVariant,
      ),
      // Verse numbers
      labelSmall: GoogleFonts.lato(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: scheme.primary.withAlpha(180),
      ),
    );
  }
}

/// Highlight color palette for notes.
class HighlightColors {
  static const yellow = Color(0x66FFEB3B);
  static const green = Color(0x664CAF50);
  static const blue = Color(0x6642A5F5);
  static const pink = Color(0x66EC407A);
  static const orange = Color(0x66FF9800);

  static const all = [yellow, green, blue, pink, orange];
}
