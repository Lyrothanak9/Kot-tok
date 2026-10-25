import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===========================================================================
  // Core Material 3 Palette Tokens
  // ===========================================================================
  static const Color surface = Color(0xFFFCF8FF);
  static const Color surfaceDim = Color(0xFFDBD8E7);
  static const Color surfaceBright = Color(0xFFFCF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F2FF);
  static const Color surfaceContainer = Color(0xFFEFECFB);
  static const Color surfaceContainerHigh = Color(0xFFE9E6F5);
  static const Color surfaceContainerHighest = Color(0xFFE3E1F0);
  static const Color onSurface = Color(0xFF1A1B25);
  static const Color onSurfaceVariant = Color(0xFF454557);
  static const Color inverseSurface = Color(0xFF2F2F3A);
  static const Color inverseOnSurface = Color(0xFFF2EFFE);

  static const Color outline = Color(0xFF767589);
  static const Color outlineVariant = Color(0xFFC6C4DB);
  static const Color surfaceTint = Color(0xFF3C3AFF);

  static const Color primary = Color(0xFF1400C3);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2414FD); // Electric Blue Accent
  static const Color onPrimaryContainer = Color(0xFFBBBDFF);
  static const Color inversePrimary = Color(0xFFC0C1FF);

  static const Color secondary = Color(0xFF5053B6);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF9396FF);
  static const Color onSecondaryContainer = Color(0xFF27288D);

  static const Color tertiary = Color(0xFF780400);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFA20F04);
  static const Color onTertiaryContainer = Color(0xFFFFAFA1);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color primaryFixed = Color(0xFFE1E0FF);
  static const Color primaryFixedDim = Color(0xFFC0C1FF);
  static const Color onPrimaryFixed = Color(0xFF06006C);
  static const Color onPrimaryFixedVariant = Color(0xFF1A00EB);

  static const Color secondaryFixed = Color(0xFFE1E0FF);
  static const Color secondaryFixedDim = Color(0xFFC0C1FF);
  static const Color onSecondaryFixed = Color(0xFF06006C);
  static const Color onSecondaryFixedVariant = Color(0xFF38399D);

  static const Color tertiaryFixed = Color(0xFFFFDAD4);
  static const Color tertiaryFixedDim = Color(0xFFFFB4A7);
  static const Color onTertiaryFixed = Color(0xFF400100);
  static const Color onTertiaryFixedVariant = Color(0xFF920600);

  static const Color background = Color(0xFFFCF8FF);
  static const Color onBackground = Color(0xFF1A1B25);
  static const Color surfaceVariant = Color(0xFFE3E1F0);

  // Component & Accent Aliases
  static const Color primaryElectricBlue = Color(0xFF2414FD);
  static const Color secondaryIndigo = Color(0xFF696CD1);
  static const Color surfaceMuted = Color(0xFFF1F3F4);
  static const Color borderSubtle = Color(0xFFE0E2EC);
  static const Color textHighEmphasis = Color(0xFF202124);
  static const Color textMediumEmphasis = Color(0xFF5F6368);

  // ===========================================================================
  // Dynamic Note Canvas Pastels
  // ===========================================================================
  static const List<NoteColorOption> noteColors = [
    NoteColorOption(id: 'default', name: 'Default', color: Color(0xFFFFFFFF)),
    NoteColorOption(id: 'coral', name: 'Coral', color: Color(0xFFF28B82)),
    NoteColorOption(id: 'peach', name: 'Peach', color: Color(0xFFFBBC04)),
    NoteColorOption(id: 'canary', name: 'Canary', color: Color(0xFFFFF475)),
    NoteColorOption(id: 'mint', name: 'Mint', color: Color(0xFFCCFF90)),
    NoteColorOption(id: 'teal', name: 'Teal', color: Color(0xFFA7FFEB)),
    NoteColorOption(id: 'cerulean', name: 'Cerulean', color: Color(0xFFCBF0F8)),
    NoteColorOption(id: 'lavender', name: 'Lavender', color: Color(0xFFAECBFA)),
    NoteColorOption(id: 'lilac', name: 'Lilac', color: Color(0xFFD7AEFB)),
    NoteColorOption(id: 'pink', name: 'Pink', color: Color(0xFFFDCFE8)),
    NoteColorOption(id: 'taupe', name: 'Taupe', color: Color(0xFFE6C9A8)),
    NoteColorOption(id: 'fog', name: 'Fog Grey', color: Color(0xFFE8EAED)),
  ];

  static Color getNoteColor(String? colorId) {
    return noteColors
        .firstWhere((opt) => opt.id == colorId, orElse: () => noteColors.first)
        .color;
  }
}

class NoteColorOption {
  final String id;
  final String name;
  final Color color;

  const NoteColorOption({
    required this.id,
    required this.name,
    required this.color,
  });
}