import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VintageTheme {
  // Parchment & Vintage Colors
  static const Color parchmentLight = Color(0xFFF4EBD0);
  static const Color parchmentDark = Color(0xFFE8D8A6);
  static const Color deeperParchment = Color(0xFFD4C18D);

  // Ink Colors
  static const Color inkDark = Color(0xFF2C201A);
  static const Color inkFaded = Color(0xFF4A3B32);

  // Accents
  static const Color crimsonRed = Color(0xFF8B0000);
  static const Color vintageGold = Color(0xFFB8860B);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: crimsonRed,
      scaffoldBackgroundColor: parchmentLight,
      colorScheme: const ColorScheme.light(
        primary: crimsonRed,
        secondary: vintageGold,
        surface: parchmentLight,
        onPrimary: parchmentLight,
        onSecondary: inkDark,
        onSurface: inkDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: deeperParchment,
        foregroundColor: inkDark,
        elevation: 1,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          color: inkDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          color: inkDark,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.cinzel(
          color: inkDark,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.crimsonText(color: inkDark, fontSize: 18),
        bodyMedium: GoogleFonts.crimsonText(color: inkDark, fontSize: 16),
      ),
      cardTheme: CardThemeData(
        color: parchmentDark,
        elevation: 4,
        shadowColor: inkDark.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: deeperParchment, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: crimsonRed,
          foregroundColor: parchmentLight,
          textStyle: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
