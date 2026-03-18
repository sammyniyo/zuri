import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import 'phone_auth_screen.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onAuthenticated;

  const WelcomeScreen({super.key, required this.onAuthenticated});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
    if (mounted && ref.read(authProvider).isAuthenticated) {
      widget.onAuthenticated();
    }
  }

  void _signInWithPhone() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PhoneAuthScreen(onAuthenticated: widget.onAuthenticated),
      ),
    );
  }

  void _continueAsGuest() {
    ref.read(authProvider.notifier).continueAsGuest();
    widget.onAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ───────────────────────────────────────────
          Image.network(
            'https://images.unsplash.com/photo-1617369120004-4fc70312c5e6?w=800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0C8A47), Color(0xFF085E30)],
                ),
              ),
            ),
          ),
          // ── Dark gradient overlay ──────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(102),
                  Colors.black.withAlpha(153),
                  Colors.black.withAlpha(230),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          // ── Content ───────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      // Logo mark
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: ZuriColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ZuriColors.primary.withAlpha(100),
                              blurRadius: 20,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Z',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ZURI',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Discover the best places\naround you in Rwanda',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withAlpha(204),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(flex: 4),
                      // ── CTA Buttons ──────────────────────────────────
                      // Google Sign-In
                      _WelcomeButton(
                        onTap: isLoading ? null : _signInWithGoogle,
                        backgroundColor: Colors.white,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: ZuriColors.textSecondary,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Google "G" icon
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'G',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4285F4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: ZuriColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 12),
                      // Phone Sign-In
                      _WelcomeButton(
                        onTap: isLoading ? null : _signInWithPhone,
                        backgroundColor: ZuriColors.primary,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.phone_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Continue with Phone',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Guest link
                      GestureDetector(
                        onTap: _continueAsGuest,
                        child: Text(
                          'Continue browsing as guest',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withAlpha(153),
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withAlpha(102),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Terms notice
                      Text(
                        'By continuing, you agree to ZURI\'s Terms of Service\nand Privacy Policy.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.white.withAlpha(102),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Widget child;

  const _WelcomeButton({
    required this.onTap,
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(51),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
