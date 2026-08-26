import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeType {
  neonDark,
  neonLight,
  classicMinimal,
  warmColdDual,
}

class AppThemes {
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.neonDark:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF0A84FF), // iOS Vivid Blue
          secondary: const Color(0xFFFF375F), // iOS Vivid Pink
          background: const Color(0xFF000000), // Pure OLED iOS Black
          surface: const Color(0xFF1C1C1E), // iOS Dark Grouped Secondary
          surfaceVariant: const Color(0xFF2C2C2E), // iOS Dark Grouped Tertiary
          onPrimary: Colors.white,
          onBackground: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFFF2F2F7),
          accentColor: const Color(0xFF30D158), // iOS Vivid Green
          accentCyan: const Color(0xFF64D2FF), // iOS Vivid Cyan
        );

      case AppThemeType.neonLight:
        return _buildTheme(
          brightness: Brightness.light,
          primary: const Color(0xFF007AFF), // Apple System Blue
          secondary: const Color(0xFFFF2D55), // Apple System Pink
          background: const Color(0xFFF2F2F7), // iOS Grouped Background Light
          surface: const Color(0xFFFFFFFF), // iOS Pure Card Surface
          surfaceVariant: const Color(0xFFE5E5EA), // iOS Light Separator/Variant
          onPrimary: Colors.white,
          onBackground: const Color(0xFF000000),
          onSurface: const Color(0xFF1C1C1E),
          accentColor: const Color(0xFF34C759), // Apple System Green
          accentCyan: const Color(0xFF5AC8FA), // Apple System Cyan
        );

      case AppThemeType.classicMinimal:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFFE5E5EA), // Apple Titanium White
          secondary: const Color(0xFF8E8E93), // Apple System Gray
          background: const Color(0xFF0A0A0C), // Deep Space Gray
          surface: const Color(0xFF18181B), // Zinc Card
          surfaceVariant: const Color(0xFF27272A),
          onPrimary: Colors.black,
          onBackground: const Color(0xFFFAFAFA),
          onSurface: const Color(0xFFF4F4F5),
          accentColor: const Color(0xFFD1D1D6),
          accentCyan: const Color(0xFFA1A1AA),
        );

      case AppThemeType.warmColdDual:
        return _buildTheme(
          brightness: Brightness.dark,
          primary: const Color(0xFFFF9F0A), // iOS Vivid Orange
          secondary: const Color(0xFF64D2FF), // iOS Vivid Cyan
          background: const Color(0xFF090D14), // Dual Deep Space
          surface: const Color(0xFF131B26), // iOS Deep Slate Blue
          surfaceVariant: const Color(0xFF1D2838),
          onPrimary: Colors.black,
          onBackground: const Color(0xFFF0F6FC),
          onSurface: const Color(0xFFE2EDF8),
          accentColor: const Color(0xFFFF453A), // iOS Vivid Red
          accentCyan: const Color(0xFF64D2FF),
        );
    }
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color onPrimary,
    required Color onBackground,
    required Color onSurface,
    required Color accentColor,
    required Color accentCyan,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      fontFamily: GoogleFonts.vazirmatn().fontFamily,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: Colors.white,
        error: const Color(0xFFFF453A),
        onError: Colors.white,
        background: background,
        onBackground: onBackground,
        surface: surface,
        onSurface: onSurface,
        surfaceVariant: surfaceVariant,
        tertiary: accentColor,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            width: 1.0,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background.withOpacity(0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: onBackground),
        titleTextStyle: TextStyle(
          color: onBackground,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Colors.white),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF34C759); // Apple standard green switch
          }
          return isDark ? const Color(0xFF39393D) : const Color(0xFFE5E5EA);
        }),
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA),
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}
