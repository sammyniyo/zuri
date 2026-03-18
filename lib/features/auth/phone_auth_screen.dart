import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import 'otp_screen.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  final VoidCallback onAuthenticated;

  const PhoneAuthScreen({super.key, required this.onAuthenticated});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(String value) {
    setState(() => _isValid = value.replaceAll(' ', '').length >= 9);
  }

  Future<void> _sendOtp() async {
    if (!_isValid) return;
    final phone = _phoneController.text.replaceAll(' ', '').trim();
    final success = await ref.read(authProvider.notifier).sendOtp(phone);
    if (success && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpScreen(
            phone: phone,
            onAuthenticated: widget.onAuthenticated,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: ZuriColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_rounded,
              color: ZuriColors.textPrimary, size: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ZuriColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.phone_rounded,
                    color: ZuriColors.primary, size: 26),
              ),
              const SizedBox(height: 20),
              const Text('Enter your\nphone number', style: ZuriTextStyles.displayMedium),
              const SizedBox(height: 10),
              Text(
                'We\'ll send you a verification code via SMS.',
                style: ZuriTextStyles.bodyLarge
                    .copyWith(color: ZuriColors.textSecondary),
              ),
              const SizedBox(height: 36),
              // Phone input
              Form(
                key: _formKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: ZuriColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isValid
                          ? ZuriColors.primary
                          : ZuriColors.border,
                      width: 1.5,
                    ),
                    boxShadow: ZuriColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      // Country prefix
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(color: ZuriColors.border, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('🇷🇼', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              '+250',
                              style: ZuriTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      // Phone number
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          autofocus: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(9),
                          ],
                          onChanged: _onPhoneChanged,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            color: ZuriColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            filled: false,
                            hintText: '7XX XXX XXX',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 2,
                              color: ZuriColors.textTertiary,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 14, color: ZuriColors.textTertiary),
                  const SizedBox(width: 6),
                  Text(
                    'Your number is never shared with anyone.',
                    style: ZuriTextStyles.labelSmall,
                  ),
                ],
              ),
              const Spacer(),
              // Send OTP button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isValid && !isLoading) ? _sendOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZuriColors.primary,
                    disabledBackgroundColor: ZuriColors.border,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Send Verification Code',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
