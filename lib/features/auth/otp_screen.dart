import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final VoidCallback onAuthenticated;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.onAuthenticated,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsLeft = 60;
  Timer? _timer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isComplete => _otp.length == 6;

  void _onDigitChanged(int index, String value) {
    setState(() => _error = null);
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_isComplete) _verify();
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verify() async {
    setState(() => _error = null);
    final success = await ref
        .read(authProvider.notifier)
        .verifyOtp(widget.phone, _otp);
    if (success && mounted) {
      widget.onAuthenticated();
    } else if (mounted) {
      setState(() => _error = ref.read(authProvider).error);
      // Clear and refocus
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resend() async {
    for (final c in _controllers) {
      c.clear();
    }
    setState(() => _error = null);
    await ref.read(authProvider.notifier).sendOtp(widget.phone);
    _startTimer();
    if (mounted) {
      _focusNodes[0].requestFocus();
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
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: ZuriColors.textPrimary,
            size: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: ZuriColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.sms_outlined,
                  color: ZuriColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Enter the code', style: ZuriTextStyles.displayMedium),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: ZuriTextStyles.bodyLarge.copyWith(
                    color: ZuriColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a 6-digit code to\n'),
                    TextSpan(
                      text: '+250 ${widget.phone}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: ZuriColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    hasError: _error != null,
                    onChanged: (v) => _onDigitChanged(i, v),
                    onKey: (e) => _onKeyEvent(i, e),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: ZuriColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _error!,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: ZuriColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              // Resend timer
              Center(
                child: _secondsLeft > 0
                    ? RichText(
                        text: TextSpan(
                          style: ZuriTextStyles.bodyMedium,
                          children: [
                            const TextSpan(text: 'Resend code in '),
                            TextSpan(
                              text: '${_secondsLeft}s',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                color: ZuriColors.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: _resend,
                        child: const Text(
                          'Resend code',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ZuriColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
              ),
              const Spacer(),
              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isComplete && !isLoading) ? _verify : null,
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
                          'Verify & Continue',
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

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final Function(KeyEvent) onKey;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onKey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 58,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: onKey,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: ZuriColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? ZuriColors.error
                  : focusNode.hasFocus
                  ? ZuriColors.primary
                  : ZuriColors.border,
              width: focusNode.hasFocus ? 2 : 1.5,
            ),
            boxShadow: focusNode.hasFocus ? ZuriColors.cardShadow : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: hasError ? ZuriColors.error : ZuriColors.textPrimary,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              filled: false,
            ),
          ),
        ),
      ),
    );
  }
}
