import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../features/pro/pro_screen.dart';

/// Wraps a widget with a Pro gate.
/// If user is not Pro, shows an upgrade overlay instead of the child.
class ProGate extends ConsumerWidget {
  final Widget child;
  final String? featureName;
  final bool inline; // true = inline card instead of overlay

  const ProGate({
    super.key,
    required this.child,
    this.featureName,
    this.inline = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);

    if (isPro) return child;

    if (inline) {
      return _InlineProPrompt(
        featureName: featureName,
        onTap: () => _openPro(context),
      );
    }

    return Stack(
      children: [
        // Blurred/disabled child preview
        IgnorePointer(
          child: Opacity(opacity: 0.3, child: child),
        ),
        // Lock overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _openPro(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: ZuriColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👑', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      featureName != null
                          ? '$featureName is Pro'
                          : 'Pro Feature',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ZuriColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Upgrade to unlock',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: ZuriColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: ZuriColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Upgrade to Pro',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openPro(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.92,
        child: const ProScreen(),
      ),
    );
  }
}

class _InlineProPrompt extends StatelessWidget {
  final String? featureName;
  final VoidCallback onTap;

  const _InlineProPrompt({this.featureName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ZuriColors.primaryLight,
              ZuriColors.primary.withAlpha(20),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: ZuriColors.primary.withAlpha(60), width: 1.5),
        ),
        child: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    featureName != null
                        ? 'Unlock $featureName'
                        : 'Unlock Pro Feature',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ZuriColors.primaryDark,
                    ),
                  ),
                  const Text(
                    'Upgrade to ZURI Pro — 5,000 RWF/month',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: ZuriColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: ZuriColors.primary),
          ],
        ),
      ),
    );
  }
}
