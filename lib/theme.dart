import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GcmpColors {
  static const bg = Color(0xFF0E0E1C);
  static const surface = Color(0xFF13131F);
  static const card = Color(0xFF16162A);
  static const border = Color(0xFF1F1F35);
  static const green = Color(0xFF00FF94);
  static const greenDim = Color(0xFF00CC76);
  static const greenFaint = Color(0xFF003D24);
  static const red = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFE8F0FF);
  static const textSecondary = Color(0xFF7D92B8);
  static const textMuted = Color(0xFF4A5E7A);
  static const kMobile = 768.0;
}

class GcmpTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: GcmpColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: GcmpColors.green,
      surface: GcmpColors.surface,
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.inter(
        color: GcmpColors.textPrimary,
        fontSize: 58,
        fontWeight: FontWeight.w900,
        letterSpacing: -2.5,
        height: 1.05,
      ),
      displayMedium: GoogleFonts.inter(
        color: GcmpColors.textPrimary,
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      headlineLarge: GoogleFonts.inter(
        color: GcmpColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineMedium: GoogleFonts.inter(
        color: GcmpColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.inter(
        color: GcmpColors.textSecondary,
        fontSize: 17,
        height: 1.75,
      ),
      bodyMedium: GoogleFonts.inter(
        color: GcmpColors.textSecondary,
        fontSize: 14,
        height: 1.65,
      ),
      labelLarge: GoogleFonts.inter(
        color: GcmpColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: GoogleFonts.inter(
        color: GcmpColors.green,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.5,
      ),
    ),
  );
}
