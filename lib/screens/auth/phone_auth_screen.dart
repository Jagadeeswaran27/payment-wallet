import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/router/app_routes.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/custom_text_field.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/widgets/custom_snackbar.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length != 10) {
      CustomSnackBar.show(
        context,
        message: 'Please enter a valid 10-digit phone number',
        isError: true,
      );
      return;
    }

    final error = await ref
        .read(authControllerProvider.notifier)
        .verifyPhoneNumber('+91$phone');

    if (error != null && mounted) {
      CustomSnackBar.show(context, message: error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    ref.listen(authControllerProvider, (previous, next) {
      if (!next.isLoading && next.value?.verificationId != null) {
        _phoneController.clear();
        if (ModalRoute.of(context)?.isCurrent == true) {
          pushToScreen(context, AppRoutes.otp.path);
        }
      }
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
              'Enter your phone number',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We will send you a verification code to this number.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            CustomTextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              enabled: !isLoading,
              hintText: 'Phone Number',
              prefix: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: const Text(
                  '+91 ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Send OTP',
              onPressed: _handleSendOtp,
              isLoading: isLoading,
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'By continuing, you agree to our Terms & Conditions',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
