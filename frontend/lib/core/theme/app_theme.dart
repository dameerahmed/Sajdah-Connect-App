import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary - Metallic Gold (Image Match)
  static const Color primary = Color(0xFFD4AF37); 
  static const Color primaryDark = Color(0xFFB8860B);
  static const Color primaryLight = Color(0xFFF3E5AB); // Silk Gold

  // Background - Deep Obsidian (Image Match)
  static const Color background = Color(0xFF050505); 
  static const Color surface = Color(0xFF0F0F0F);
  static const Color surfaceVariant = Color(0xFF1A1A1A);

  // Accents - Emerald Green (Image Match)
  static const Color emerald = Color(0xFF006442);
  static const Color emeraldLight = Color(0xFF00A86B);

  // Text
  static const Color textPrimary = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textGold = Color(0xFFD4AF37);
  static const Color textHint = Color(0xFF64748B);

  // Status Colors
  static const Color rejected = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Surface Colors
  static const Color primarySurface = Color(0xFF1E1E1E);

  // High-End Gradients
  static const LinearGradient primaryGradient = goldGradient;
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF3E5AB), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient obsidianGradient = LinearGradient(
    colors: [Color(0xFF050505), Color(0xFF121212)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 32, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 28, color: AppColors.textPrimary),
        headlineLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 24, color: AppColors.textPrimary),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.textPrimary),
        headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: Colors.black,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 32, color: AppColors.textPrimary, letterSpacing: -1.0),
        displayMedium: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.textPrimary, letterSpacing: -0.8),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 20, color: AppColors.textGold),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.textSecondary),
        labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary, letterSpacing: 1.0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.textGold, fontFamily: 'Inter', letterSpacing: 2.0),
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), 
          side: BorderSide(color: Colors.white.withOpacity(0.04))
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Color(0xFF475569),
        elevation: 0,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: AppColors.primary),
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2.0),
        ),
      ),
    );
  }
}
