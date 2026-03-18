import 'package:flutter/material.dart';

class ZuriColors {
  ZuriColors._();

  // Brand
  static const Color primary = Color(0xFF0FA958);
  static const Color primaryDark = Color(0xFF0C8A47);
  static const Color primaryLight = Color(0xFFE6F7EE);
  static const Color secondary = Color(0xFFFF8C42);
  static const Color secondaryLight = Color(0xFFFFF1E8);

  // Backgrounds
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F4F7);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF0FA958);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFEF4444);

  // Wait time indicators
  static const Color waitGreen = Color(0xFF22C55E);
  static const Color waitYellow = Color(0xFFF59E0B);
  static const Color waitRed = Color(0xFFEF4444);

  // Map pins
  static const Color pinHighRated = Color(0xFF0FA958);
  static const Color pinAverage = Color(0xFFF59E0B);
  static const Color pinBusy = Color(0xFFEF4444);

  // Rating
  static const Color ratingGold = Color(0xFFFFC107);

  // Borders / Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Overlay
  static const Color overlay = Color(0x80000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Card shadow
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> bottomNavShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];
}
