import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/app_providers.dart';

class LocationPermissionScreen extends ConsumerStatefulWidget {
  final VoidCallback onPermissionGranted;
  final VoidCallback onSkip;

  const LocationPermissionScreen({
    super.key,
    required this.onPermissionGranted,
    required this.onSkip,
  });

  @override
  ConsumerState<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends ConsumerState<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    // In production: use geolocator + permission_handler
    // For now simulate granting permission with Kigali coordinates
    ref.read(locationProvider.notifier).setLocation(-1.9441, 30.0619);
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onPermissionGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZuriColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Animated location icon
              ScaleTransition(
                scale: _pulseAnim,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ZuriColors.primaryLight,
                    boxShadow: [
                      BoxShadow(
                        color: ZuriColors.primary.withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: ZuriColors.primary,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Where are you?',
                style: ZuriTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'ZURI uses your location to instantly show you the best places nearby in Kigali and across Rwanda.',
                style: ZuriTextStyles.bodyLarge.copyWith(
                  color: ZuriColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Benefits
              _PermissionBenefit(
                icon: Icons.flash_on_rounded,
                color: ZuriColors.secondary,
                text: 'Instant discovery — no searching needed',
              ),
              _PermissionBenefit(
                icon: Icons.directions_walk_rounded,
                color: ZuriColors.primary,
                text: 'Real walking distances & times',
              ),
              _PermissionBenefit(
                icon: Icons.lock_outline_rounded,
                color: ZuriColors.textSecondary,
                text: 'Your location is never stored or shared',
              ),
              const Spacer(flex: 3),
              // Enable button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZuriColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Enable Location',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: widget.onSkip,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ZuriColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionBenefit extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _PermissionBenefit({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: ZuriColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
