import 'package:flutter/material.dart';

/// Design tokens and semantic color definitions for Chronova.
class AppColors {
  // Primary Brand & Accents
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryContainer = Color(0xFFEEF2FF);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF4F7FE);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8FAFC);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFF0F9FF);

  // Dynamic Category Accents (Examples of custom user categories)
  static const Color catViolet = Color(0xFF7C3AED);
  static const Color catAmber = Color(0xFFD97706);
  static const Color catEmerald = Color(0xFF059669);
  static const Color catRose = Color(0xFFE11D48);
  static const Color catSky = Color(0xFF0284C7);
}
