import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/providers/pin_providers.dart';

Future<bool> showPinVerificationSheet(BuildContext context, WidgetRef ref) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _PinVerificationSheetContent(ref: ref),
  );
  return result ?? false;
}

class _PinVerificationSheetContent extends StatefulWidget {
  final WidgetRef ref;
  const _PinVerificationSheetContent({required this.ref});

  @override
  State<_PinVerificationSheetContent> createState() =>
      _PinVerificationSheetContentState();
}

class _PinVerificationSheetContentState
    extends State<_PinVerificationSheetContent> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;

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

  void _onInputChanged(String value, int index) async {
    setState(() {
      _errorMessage = null;
    });

    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final pin = _controllers.map((c) => c.text).join();
    if (pin.length == 4) {
      await _verifyPin(pin);
    }
  }

  Future<void> _verifyPin(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final isVerified =
        await widget.ref.read(pinControllerProvider.notifier).verifyPin(pin);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (isVerified) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = 'Wrong PIN. Try again.';
        });
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.lock_outline, size: 40, color: AppColors.primary),
          const SizedBox(height: 12),
          const Text(
            'Enter PIN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your 4-digit PIN to proceed',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
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
                  autofocus: index == 0,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: _errorMessage != null
                        ? AppColors.error.withOpacity(0.05)
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: _errorMessage != null
                          ? const BorderSide(color: AppColors.error)
                          : BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) => _onInputChanged(value, index),
                ),
              );
            }),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ] else if (_isLoading) ...[
            const SizedBox(height: 16),
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
