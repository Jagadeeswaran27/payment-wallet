import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/models/blink_card_model.dart';
import 'package:app/models/enums/payment_type.dart';
import 'package:app/providers/payment_providers.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/pin_verification_sheet.dart';
import 'package:app/utils/payment_util.dart';
import 'package:app/utils/navigation.dart';

Future<void> showBlinkPaymentSheet(
  BuildContext context,
  WidgetRef ref,
  BlinkCardModel card,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _BlinkPaymentSheetContent(card: card, ref: ref),
  );
}

class _BlinkPaymentSheetContent extends StatefulWidget {
  final BlinkCardModel card;
  final WidgetRef ref;

  const _BlinkPaymentSheetContent({required this.card, required this.ref});

  @override
  State<_BlinkPaymentSheetContent> createState() =>
      _BlinkPaymentSheetContentState();
}

class _BlinkPaymentSheetContentState extends State<_BlinkPaymentSheetContent> {
  bool _isLoading = false;

  void _handlePay() async {
    final user = widget.ref.read(authStateChangesProvider).value;
    if (user?.kycStatus != true) {
      CustomSnackBar.show(
        context,
        message: 'Please complete KYC verification to make UPI payments',
        isError: true,
      );
      return;
    }

    final verified = await showPinVerificationSheet(context, widget.ref);
    if (!verified) return;

    setState(() => _isLoading = true);

    // Provide target UPI ID.
    await widget.ref
        .read(paymentControllerProvider.notifier)
        .storeUpiId(upiId: widget.card.receiverUpiId);

    // Trigger transaction rules via main controller.
    final isWallet = widget.card.sourceId == 'wallet';

    await widget.ref.read(paymentControllerProvider.notifier).sendMoney(
          amount: widget.card.amount,
          paymentType: isWallet ? PaymentType.wallet : PaymentType.card,
          sourceCardId: isWallet ? null : widget.card.sourceId,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      
      final paymentState = widget.ref.read(paymentControllerProvider);
      
      if (paymentState.hasError) {
        CustomSnackBar.show(
          context,
          message: paymentState.error.toString(),
          isError: true,
        );
      } else {
        CustomSnackBar.show(context, message: 'Blink Payment Successful!');
        popScreen(context);
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.flash_on, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Confirm Blink Payment',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildInfoRow('Title', widget.card.name),
                const Divider(),
                _buildInfoRow('To', widget.card.receiverUpiId),
                const Divider(),
                _buildInfoRow(
                  'From',
                  widget.card.sourceId == 'wallet'
                      ? 'Paytm Wallet'
                      : 'Saved Card (${widget.card.sourceId})',
                ),
                const Divider(),
                _buildInfoRow(
                  'Amount',
                  PaymentUtil.formatAmount(widget.card.amount),
                  isAmount: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Pay ${PaymentUtil.formatAmount(widget.card.amount)}',
            onPressed: _handlePay,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isAmount ? 18 : 14,
              color: isAmount ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
