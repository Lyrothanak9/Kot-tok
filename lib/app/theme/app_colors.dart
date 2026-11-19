import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF4A34B8); // Your Kot Tok active color
  static const Color primaryDark = Color(0xFF1E0B99); // Deep blue for destructive/primary actions

  // Background & Surfaces (Google Keep Style)
  static const Color background = Colors.white;
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F4); // Keep's search bar & chip background

  // Text Colors (Google Standard)
  static const Color textPrimary = Color(0xFF202124); // Almost black for high readability
  static const Color textSecondary = Color(0xFF5F6368); // Grey for labels and descriptions
  static const Color textHint = Color(0xFF80868B);

  // Backward compatibility aliases
  static const Color textTitleColor = textPrimary;
  static const Color textPrimaryColor = textSecondary;
  static const Color onSurface = textPrimary;
  static const Color onSurfaceVariant = textSecondary;
  static const Color secondary = primary;

  // Borders & Dividers
  static const Color border = Color(0xFFE0E0E0); // Keep's signature card outline color

  // Status Colors
  static const Color error = Color(0xFFD93025);
  static const Color success = Color(0xFF1E8E3E);
}