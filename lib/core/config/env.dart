import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralised access to all environment variables.
///
/// Usage:
///   Env.flutterwavePublicKey
///   Env.googleMapsApiKey
///   Env.isProduction
///
/// Keys are loaded from the `.env` file at app startup (see main.dart).
class Env {
  Env._(); // prevent instantiation

  // ── App ────────────────────────────────────────────────────────────────────
  /// Current environment: "development" or "production"
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  /// True when APP_ENV=production
  static bool get isProduction => appEnv == 'production';

  /// True when APP_ENV=development
  static bool get isDevelopment => appEnv == 'development';

  // ── Google Maps ────────────────────────────────────────────────────────────
  /// Google Maps API key — also injected into AndroidManifest via local.properties
  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  // ── Flutterwave ────────────────────────────────────────────────────────────
  /// Flutterwave public key (FLWPUBK_TEST-... or FLWPUBK-...)
  static String get flutterwavePublicKey =>
      dotenv.env['FLUTTERWAVE_PUBLIC_KEY'] ?? '';

  /// True = sandbox/test mode | False = live payments
  static bool get flutterwaveTestMode =>
      dotenv.env['FLUTTERWAVE_TEST_MODE'] != 'false';
}
