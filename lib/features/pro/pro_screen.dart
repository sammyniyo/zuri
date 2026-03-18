import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/config/env.dart';

class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key});

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  bool _isProcessing = false;
  bool _paymentSuccess = false;

  Future<void> _startPayment() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isProcessing = true);

    final txRef = 'ZURI-PRO-${const Uuid().v4()}';
    final customer = Customer(
      name: user.name,
      phoneNumber: user.phone ?? '0780000000',
      email: user.email ?? 'user@zuri.rw',
    );

    final flutterwave = Flutterwave(
      publicKey: Env.flutterwavePublicKey,
      currency: 'RWF',
      amount: '5000',
      customer: customer,
      paymentOptions: 'mobilemoneyghana,card',
      customization: Customization(
        title: 'ZURI Pro',
        description: 'Monthly Pro subscription — 5,000 RWF/month',
        logo: 'https://i.imgur.com/placeholder.png',
      ),
      txRef: txRef,
      isTestMode: Env.flutterwaveTestMode,
      redirectUrl: 'https://zuri.rw/payment-success',
    );

    try {
      final response = await flutterwave.charge(context);
      if (response.status == 'successful') {
        await ref.read(authProvider.notifier).activatePro();
        if (mounted) setState(() => _paymentSuccess = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment failed. Please try again.'),
            backgroundColor: ZuriColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(isProProvider);

    if (isPro || _paymentSuccess) {
      return _ProSuccessView(onClose: () => Navigator.pop(context));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              height: 320,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0FA958),
                    Color(0xFF0C8A47),
                    Color(0xFF0A5C30),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Pattern overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.06,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 6,
                            ),
                        itemCount: 60,
                        itemBuilder: (_, _) => const Icon(
                          Icons.place_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        // Close button
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Crown icon
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(60),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text('👑', style: TextStyle(fontSize: 34)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ZURI Pro',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unlock the full ZURI experience',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withAlpha(204),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Feature List ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What you get',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ProFeature(
                    emoji: '🔍',
                    title: 'Advanced Filters',
                    description:
                        'Filter by distance, rating, price, and open status. Sort results your way.',
                  ),
                  _ProFeature(
                    emoji: '⭐',
                    title: 'Write Reviews',
                    description:
                        'Share your experience and help others discover the best places.',
                  ),
                  _ProFeature(
                    emoji: '📸',
                    title: 'Upload Photos',
                    description:
                        'Add your own photos to any place and grow the ZURI community.',
                  ),
                  _ProFeature(
                    emoji: '🔖',
                    title: 'Unlimited Saves',
                    description:
                        'Save as many places as you want with no restrictions.',
                  ),
                  _ProFeature(
                    emoji: '⚡',
                    title: 'Priority Updates',
                    description:
                        'Get early access to new places, features, and special offers.',
                  ),
                  const SizedBox(height: 28),

                  // ── Pricing card ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withAlpha(15),
                          Colors.white.withAlpha(8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ZuriColors.primary.withAlpha(100),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '5,000',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 44,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'RWF',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withAlpha(180),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'per month · Cancel anytime',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.white.withAlpha(150),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Pay button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _startPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ZuriColors.primary,
                              disabledBackgroundColor: ZuriColors.primary
                                  .withAlpha(100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isProcessing
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.flash_on_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Unlock ZURI Pro',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Payment methods
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PayMethodChip(label: '📱 MTN MoMo'),
                            const SizedBox(width: 8),
                            _PayMethodChip(label: '💳 Card'),
                            const SizedBox(width: 8),
                            _PayMethodChip(label: '📱 Airtel'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '🔒 Secured by Flutterwave',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white.withAlpha(100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProFeature extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _ProFeature({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha(25)),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.white.withAlpha(153),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: ZuriColors.primary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _PayMethodChip extends StatelessWidget {
  final String label;
  const _PayMethodChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.white.withAlpha(180),
        ),
      ),
    );
  }
}

// ─── Pro Success View ─────────────────────────────────────────────────────────
class _ProSuccessView extends StatelessWidget {
  final VoidCallback onClose;
  const _ProSuccessView({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: ZuriColors.primary.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: ZuriColors.primary, width: 2),
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 50)),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'You\'re Pro!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'Welcome to ZURI Pro. All premium features are now unlocked. Enjoy discovering Rwanda!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: Colors.white.withAlpha(178),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZuriColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Exploring',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
