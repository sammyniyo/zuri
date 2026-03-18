import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/location_permission_screen.dart';
import 'features/auth/welcome_screen.dart';
import 'features/home/home_shell.dart';

enum _AppState { splash, locationPermission, auth, home }

class ZuriApp extends ConsumerStatefulWidget {
  const ZuriApp({super.key});

  @override
  ConsumerState<ZuriApp> createState() => _ZuriAppState();
}

class _ZuriAppState extends ConsumerState<ZuriApp> {
  _AppState _state = _AppState.splash;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZURI',
      debugShowCheckedModeBanner: false,
      theme: ZuriTheme.light,
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_state) {
      case _AppState.splash:
        return SplashScreen(
          onComplete: () =>
              setState(() => _state = _AppState.locationPermission),
        );
      case _AppState.locationPermission:
        return LocationPermissionScreen(
          onPermissionGranted: () => setState(() => _state = _AppState.auth),
          onSkip: () => setState(() => _state = _AppState.auth),
        );
      case _AppState.auth:
        return WelcomeScreen(
          onAuthenticated: () => setState(() => _state = _AppState.home),
        );
      case _AppState.home:
        return const HomeShell();
    }
  }
}
