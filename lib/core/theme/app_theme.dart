import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class ZuriTheme {
  ZuriTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: ZuriColors.primary,
        secondary: ZuriColors.secondary,
        surface: ZuriColors.background,
        // `background` and `onBackground` are deprecated in favor of surface/onSurface.
        onPrimary: ZuriColors.textOnPrimary,
        onSecondary: ZuriColors.textOnPrimary,
        onSurface: ZuriColors.textPrimary,
        error: ZuriColors.error,
      ),
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: ZuriColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: ZuriColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: ZuriColors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ZuriColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZuriColors.primary,
          foregroundColor: ZuriColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ZuriColors.primary,
          side: const BorderSide(color: ZuriColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZuriColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZuriColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ZuriColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          color: ZuriColors.textTertiary,
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ZuriColors.surfaceVariant,
        selectedColor: ZuriColors.primary,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        side: BorderSide.none,
      ),
      cardTheme: CardThemeData(
        color: ZuriColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ZuriColors.surface,
        selectedItemColor: ZuriColors.primary,
        unselectedItemColor: ZuriColors.textTertiary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ZuriColors.divider,
        thickness: 1,
        space: 0,
      ),
    );
  }
}

// Text style helpers
class ZuriTextStyles {
  ZuriTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: ZuriColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: ZuriColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: ZuriColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ZuriColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ZuriColors.textPrimary,
    letterSpacing: -0.1,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ZuriColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: ZuriColors.textPrimary,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: ZuriColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: ZuriColors.textSecondary,
    letterSpacing: 0.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: ZuriColors.textTertiary,
    letterSpacing: 0.2,
  );

  static const TextStyle priceBold = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: ZuriColors.primary,
    letterSpacing: 0.1,
  );
}
