import 'package:flutter/material.dart';

// Milky theme color palette
const Color _milkyWhite = Color(0xFFFFFEFB);
const Color _creamyWhite = Color(0xFFFFF8F0);
const Color _warmIvory = Color(0xFFFFF5E6);
const Color _softBeige = Color(0xFFF5F0E8);
const Color _lightCream = Color(0xFFF8F4E6);
const Color _milkyBlue = Color(0xFFE8F4F8);
const Color _softLavender = Color(0xFFF0F0F8);
const Color _warmGray = Color(0xFF8B8680);
const Color _milkyBrown = Color(0xFF6B5B73);
const Color _deepCream = Color(0xFFE6D7C3);

final ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _milkyBrown,
  onPrimary: _milkyWhite,
  primaryContainer: _lightCream,
  onPrimaryContainer: _milkyBrown,
  secondary: _warmGray,
  onSecondary: _milkyWhite,
  secondaryContainer: _milkyBlue,
  onSecondaryContainer: _milkyBrown,
  tertiary: _softLavender,
  onTertiary: _milkyBrown,
  tertiaryContainer: _softBeige,
  onTertiaryContainer: _milkyBrown,
  error: const Color(0xFFD4A574),
  onError: _milkyWhite,
  errorContainer: const Color(0xFFF2E7D5),
  onErrorContainer: const Color(0xFF8B6914),
  surface: _milkyWhite,
  onSurface: _milkyBrown,
  onSurfaceVariant: _warmGray,
  outline: _deepCream,
  outlineVariant: _softBeige,
  shadow: Colors.black26,
  scrim: Colors.black54,
  inverseSurface: _milkyBrown,
  onInverseSurface: _milkyWhite,
  inversePrimary: _lightCream,
  surfaceTint: _milkyBrown,
);

final ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: _lightCream,
  onPrimary: _milkyBrown,
  primaryContainer: const Color(0xFF4A3D47),
  onPrimaryContainer: _lightCream,
  secondary: _milkyBlue,
  onSecondary: _milkyBrown,
  secondaryContainer: const Color(0xFF3D4A47),
  onSecondaryContainer: _milkyBlue,
  tertiary: _softBeige,
  onTertiary: _milkyBrown,
  tertiaryContainer: const Color(0xFF47453D),
  onTertiaryContainer: _softBeige,
  error: const Color(0xFFE6C2A6),
  onError: const Color(0xFF5C3A0A),
  errorContainer: const Color(0xFF7A4F12),
  onErrorContainer: const Color(0xFFF2E7D5),
  surface: const Color(0xFF1A1617),
  onSurface: _creamyWhite,
  onSurfaceVariant: _deepCream,
  outline: const Color(0xFF8B8680),
  outlineVariant: const Color(0xFF4A453F),
  shadow: Colors.black,
  scrim: Colors.black,
  inverseSurface: _creamyWhite,
  onInverseSurface: const Color(0xFF1A1617),
  inversePrimary: _milkyBrown,
  surfaceTint: _lightCream,
);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  scaffoldBackgroundColor: _milkyWhite,
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: _creamyWhite,
    shadowColor: Colors.black12,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: _warmIvory,
    foregroundColor: _milkyBrown,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightCream,
      foregroundColor: _milkyBrown,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: _milkyBrown, fontSize: 16),
    bodyMedium: TextStyle(color: _milkyBrown, fontSize: 14),
    titleLarge: TextStyle(color: _milkyBrown, fontWeight: FontWeight.w600),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
  scaffoldBackgroundColor: const Color(0xFF1A1617),
  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: const Color(0xFF2A2327),
    shadowColor: Colors.black54,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2A2327),
    foregroundColor: _creamyWhite,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4A3D47),
      foregroundColor: _creamyWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: _creamyWhite, fontSize: 16),
    bodyMedium: TextStyle(color: _creamyWhite, fontSize: 14),
    titleLarge: TextStyle(color: _creamyWhite, fontWeight: FontWeight.w600),
  ),
);