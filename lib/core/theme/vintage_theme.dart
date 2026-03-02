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

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: vintageGold,
      scaffoldBackgroundColor: inkDark,
      colorScheme: const ColorScheme.dark(
        primary: vintageGold,
        secondary: parchmentLight,
        surface: inkDark,
        onPrimary: inkDark,
        onSecondary: inkDark,
        onSurface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: inkDark,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 28),
        titleTextStyle: GoogleFonts.cinzel(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 28),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.cinzel(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.crimsonText(color: Colors.white, fontSize: 22),
        bodyMedium: GoogleFonts.crimsonText(color: Colors.white, fontSize: 20),
      ),
      cardTheme: CardThemeData(
        color: inkFaded,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: deeperParchment, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: vintageGold,
          foregroundColor: inkDark,
          textStyle: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
