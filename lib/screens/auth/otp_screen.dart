import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/utils/navigation.dart';
import 'package:app/router/app_routes.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/widgets/custom_snackbar.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _start = 30;
  bool _isResendEnabled = true;
  bool _isLoading = false;

  void startTimer() {
    setState(() {
      _isResendEnabled = false;
      _start = 30;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
          _isResendEnabled = true;
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      CustomSnackBar.show(
        context,
        message: 'Please enter a valid 6-digit OTP',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final error = await ref
        .read(authControllerProvider.notifier)
        .signInWithOtp(smsCode: otp);

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      if (mounted) {
        CustomSnackBar.show(context, message: error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      next.whenData((value) {
        if (value.user != null) {
          if (value.user!.isOnboardCompleted) {
            goToScreen(context, AppRoutes.home.path);
          } else {
            goToScreen(context, AppRoutes.onboarding.path);
          }
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => popScreen(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verify your number',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-digit code sent to your phone.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 48,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    enabled: !_isLoading,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    "Didn't receive the code?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _isLoading || !_isResendEnabled
                        ? null
                        : () async {
                            await ref
                                .read(authControllerProvider.notifier)
                                .resendOtp();
                            startTimer();
                          },
                    child: Text(
                      _isResendEnabled
                          ? 'Resend Code'
                          : 'Resend Code ($_start)',
                      style: TextStyle(
                        color: _isResendEnabled
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Verify & Proceed',
              onPressed: _handleVerifyOtp,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
