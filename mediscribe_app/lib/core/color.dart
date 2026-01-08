import 'package:flutter/material.dart';

class AppColors {
  // ========== Light Theme Colors ==========

  // Primary brand color (Mediscribe blue)
  static const Color primary = Color(0xFF1E3A8A);

  // Background
  static const Color background = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  // UI elements
  static const Color button = Color(0xFF1E40AF);
  static const Color border = Color(0xFFE5E7EB);

  // ========== Dark Theme Colors ==========

  // Primary brand color for dark mode (lighter blue for better contrast)
  static const Color darkPrimary = Color(0xFF60A5FA);

  // Background
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);

  // Text
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // UI elements
  static const Color darkButton = Color(0xFF3B82F6);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkCardBackground = Color(0xFF1E293B);

  // ========== Login Screen Colors (Indian Theme) ==========

  // Warm backgrounds (4x darker)
  static const Color loginBackground = Color(0xFF8BA3B8); // Darker blue-gray
  static const Color loginBackgroundDark = Color(0xFF040A12); // Very deep navy

  // Brand accent colors (matching new AI heart logo)
  static const Color saffron = Color(0xFF5DB3E8); // Primary light blue
  static const Color saffronLight =
      Color(0xFF8ECDF5); // Lighter blue for accents
  static const Color saffronDark =
      Color(0xFF3A9AD9); // Darker blue for pressed states
  static const Color earthy = Color(0xFF6B8CAE); // Muted blue-gray
  static const Color softGreen = Color(0xFF4A9EC7); // Teal-blue
  static const Color warmGold = Color(0xFF7AC4E8); // Soft cyan

  // Namaste text colors
  static const Color namastePrimary =
      Color(0xFF2D3436); // Deep charcoal for light mode
  static const Color namastePrimaryDark =
      Color(0xFFF5F0EB); // Cream for dark mode
  static const Color subtitleText =
      Color(0xFF636E72); // Muted gray for subtitles
  static const Color subtitleTextDark =
      Color(0xFFB2BEC3); // Light gray for dark mode
}
