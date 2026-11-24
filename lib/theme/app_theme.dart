// Tema pixel P&B — Capi-Bank
// Traduz o visual do SemUmReal-mobile (React Native, pixel art P&B,
// fonte Press Start 2P) para Flutter, sem copiar o codigo dele.
// Paleta: so preto, branco e cinza. Bordas grossas, cantos retos,
// espacamento em multiplos de 8.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color paper = Color(0xFFFAFAFA); // fundo claro
  static const Color ink = Color(0xFF111111); // preto principal
  static const Color panel = Color(0xFF3A3A3A); // cartao cinza escuro (tokens)
  static const Color panelText = Color(0xFFFAFAFA); // texto sobre preto
  static const Color muted = Color(0xFF6B6B6B);
  static const Color stage = Color(0xFFCFCFCF); // cinza das montanhas
  static const Color line = Color(0xFF111111);
  static const Color error = Color(0xFFB00020);
  static const Color loginSky = Color(0xFFE3E3E3); // ceu da arte do login
  // Dourado so do efeito de riscar: sol vira moedinha dourada.
  static const Color gold = Color(0xFFFFC107);
  static const Color goldDark = Color(0xFFB8860B);
  // Verde so do efeito de riscar: o dinheirinho carrega junto com o sol.
  static const Color moneyGreen = Color(0xFF43A047);
  static const Color moneyGreenDark = Color(0xFF2E7D32);
}

/// Medidas de layout do SemUmReal original.
class AppLayout {
  static const double tabBarHeight = 72;
}

class AppSpacing {
  static const double s1 = 8;
  static const double s2 = 16;
  static const double s3 = 24;
  static const double s4 = 32;
  static const double s6 = 48;
}

class AppText {
  static TextStyle pixel(double size, {Color color = AppColors.ink}) =>
      GoogleFonts.pressStart2p(fontSize: size, color: color, height: 1.5);

  static TextStyle title({Color color = AppColors.ink}) => pixel(16, color: color);
  static TextStyle subtitle({Color color = AppColors.muted}) => pixel(10, color: color);
  static TextStyle label({Color color = AppColors.ink}) => pixel(10, color: color);
  static TextStyle value({Color color = AppColors.ink}) => pixel(14, color: color);
  static TextStyle body({Color color = AppColors.ink}) =>
      TextStyle(fontSize: 14, color: color, height: 1.5);
}

ThemeData capiBankTheme() {
  const borderSide = BorderSide(color: AppColors.ink, width: 3);
  final inputBorder = OutlineInputBorder(
    borderSide: borderSide,
    borderRadius: BorderRadius.zero,
  );

  return ThemeData(
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: const ColorScheme.light(
      primary: AppColors.ink,
      onPrimary: AppColors.paper,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      error: AppColors.error,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.ink,
      foregroundColor: AppColors.paper,
      centerTitle: true,
      titleTextStyle: GoogleFonts.pressStart2p(
        fontSize: 14,
        color: AppColors.paper,
      ),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.paper,
        textStyle: GoogleFonts.pressStart2p(fontSize: 12),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s2,
          horizontal: AppSpacing.s2,
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: borderSide,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        textStyle: GoogleFonts.pressStart2p(fontSize: 12),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s2,
          horizontal: AppSpacing.s2,
        ),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: borderSide,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.ink,
        textStyle: GoogleFonts.pressStart2p(fontSize: 10),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.paper,
      labelStyle: GoogleFonts.pressStart2p(fontSize: 10, color: AppColors.ink),
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.muted),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder,
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.error, width: 3),
        borderRadius: BorderRadius.zero,
      ),
      contentPadding: const EdgeInsets.all(AppSpacing.s2),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppColors.ink, width: 3),
      ),
    ),
  );
}
