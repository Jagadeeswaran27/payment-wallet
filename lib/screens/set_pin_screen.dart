import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/router/app_routes.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/providers/pin_providers.dart';

class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isConfirmStep = false;
  String _firstPin = '';
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _clearInputs() {
    for (var controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
    setState(() {});
  }

  Future<void> _handleNext() async {
    final pin = _controllers.map((c) => c.text).join();
    if (pin.length < 4) {
      CustomSnackBar.show(
        context,
        message: 'Please enter a 4-digit PIN',
        isError: true,
      );
      return;
    }

    if (!_isConfirmStep) {
      // Move to confirm step
      setState(() {
        _firstPin = pin;
        _isConfirmStep = true;
      });
      _clearInputs();
    } else {
      // Validate and save
      if (pin != _firstPin) {
        CustomSnackBar.show(
          context,
          message: 'PINs do not match. Try again.',
          isError: true,
        );
        setState(() {
          _isConfirmStep = false;
          _firstPin = '';
        });
        _clearInputs();
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final error =
          await ref.read(pinControllerProvider.notifier).setPin(pin);

      setState(() {
        _isLoading = false;
      });

      if (error != null) {
        if (mounted) {
          CustomSnackBar.show(context, message: error, isError: true);
        }
      } else {
        if (mounted) {
          CustomSnackBar.show(context, message: 'PIN set successfully');
          goToScreen(context, AppRoutes.account.path);
          popScreen(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _isConfirmStep ? 'Confirm your PIN' : 'Set your PIN',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _isConfirmStep
                  ? 'Re-enter your 4-digit PIN to confirm.'
                  : 'Enter a 4-digit PIN to secure your wallet transactions.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 56,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    obscureText: true,
                    maxLength: 1,
                    enabled: !_isLoading,
                    style: const TextStyle(
                      fontSize: 24,
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const Spacer(),
            PrimaryButton(
              text: _isConfirmStep ? 'Confirm PIN' : 'Next',
              onPressed: _handleNext,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
