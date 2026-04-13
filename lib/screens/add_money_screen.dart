import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/router/app_routes.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/services/wallet_service.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/payment_method_providers.dart';
import 'package:app/providers/walllet_providers.dart';
import 'package:app/utils/payment_util.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/payment_card_shimmer.dart';
import 'package:app/models/payment_card.dart';
import 'package:app/resources/icons.dart';
import 'package:app/utils/decimal_max_value_formatter.dart';
import 'package:app/widgets/pin_verification_sheet.dart';

class AddMoneyScreen extends ConsumerStatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  ConsumerState<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends ConsumerState<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedPaymentMethodId;
  final List<int> _quickAmounts = [100, 500, 1000, 2000];
  double _dailyRemaining = WalletService.dailyTopUpLimit;
  bool _isLoadingLimit = true;

  @override
  void initState() {
    super.initState();
    _fetchDailyRemaining();
  }

  Future<void> _fetchDailyRemaining() async {
    final remaining = await ref
        .read(walletControllerProvider.notifier)
        .getDailyTopUpRemaining();
    if (mounted) {
      setState(() {
        _dailyRemaining = remaining;
        _isLoadingLimit = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    setState(() {});
  }

  void _onQuickAmountSelected(int amount) {
    _amountController.text = amount.toString();
    setState(() {});
  }

  Object _getCardIcon(CardType type) {
    switch (type) {
      case CardType.visa:
        return AppIcons.visa;
      case CardType.mastercard:
        return AppIcons.mastercard;
      case CardType.rupay:
        return AppIcons.rupay;
      default:
        return Icons.credit_card;
    }
  }

  Widget _buildCardIcon(CardType type) {
    final icon = _getCardIcon(type);
    if (icon is String) {
      return Image.asset(icon, width: 24, height: 24, fit: BoxFit.contain);
    } else if (icon is IconData) {
      return Icon(icon, color: AppColors.primary, size: 24);
    }
    return const Icon(Icons.credit_card, color: AppColors.primary, size: 24);
  }

  void _handleAddMoney() async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    if (user.kycStatus != true) {
      CustomSnackBar.show(
        context,
        message: 'Please complete KYC verification to add money',
        isError: true,
      );
      pushToScreen(context, AppRoutes.kyc.path);
      return;
    }

    if (user.pinHash == null) {
      CustomSnackBar.show(
        context,
        message: 'Please set your PIN to make transactions',
        isError: true,
      );
      return;
    }

    final verified = await showPinVerificationSheet(context, ref);
    if (!verified) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    ref
        .read(walletControllerProvider.notifier)
        .addWalletBalance(
          amount: amount,
          sourceCardId: _selectedPaymentMethodId!,
        );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authStateChangesProvider);
    final user = userState.value;
    final paymentCardsState = ref.watch(paymentMethodControllerProvider);
    final walletState = ref.watch(walletControllerProvider);

    final cards = paymentCardsState.value;

    if (cards != null && cards.isNotEmpty && _selectedPaymentMethodId == null) {
      try {
        final defaultCard = cards.firstWhere((card) => card.isDefault);
        _selectedPaymentMethodId = defaultCard.id;
      } catch (_) {}
    }

    ref.listen(walletControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          _fetchDailyRemaining();
          CustomSnackBar.show(context, message: 'Money added successfully');
          goToScreen(context, AppRoutes.wallet.path);
        },
        error: (error, stackTrace) {
          CustomSnackBar.show(
            context,
            message: error.toString(),
            isError: true,
          );
        },
      );
    });

    final amountText = _amountController.text;
    final amount = double.tryParse(amountText) ?? 0;
    final maxAllowed = _dailyRemaining;
    final isKycVerified = user?.kycStatus == true;
    final isValidAmount = amount >= 10 && amount <= maxAllowed;
    final isButtonEnabled =
      isKycVerified &&
      isValidAmount &&
      _selectedPaymentMethodId != null &&
      !_isLoadingLimit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Money'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add money to your wallet balance',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Wallet Balance Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Wallet Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user != null
                        ? PaymentUtil.formatAmount(user.walletBalance)
                        : '₹ 0.00',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Daily Limit Info
            _buildDailyLimitInfo(),
            const SizedBox(height: 24),

            if (!isKycVerified)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: const Text(
                  'KYC verification is required before adding money to wallet.',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Enter Amount Section
            const Text(
              'Enter Amount',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              inputFormatters: [
                DecimalMaxValueFormatter(
                  maxValue: maxAllowed,
                  decimalPlaces: 2,
                ),
              ],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: _onAmountChanged,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum ₹10 • Maximum ${PaymentUtil.formatAmount(maxAllowed)}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _quickAmounts.map((amt) {
                return ActionChip(
                  label: Text('+₹$amt'),
                  onPressed: () => _onQuickAmountSelected(amt),
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Payment Method Selection
            const Text(
              'Pay Using',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            paymentCardsState.when(
              data: (cards) {
                if (cards.isEmpty) {
                  return const Text('No payment methods available.');
                }
                return Column(
                  children: cards.map((card) {
                    return RadioListTile<String>(
                      value: card.id,
                      groupValue: _selectedPaymentMethodId,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethodId = value;
                        });
                      },
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _buildCardIcon(card.cardType),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '•••• ${card.last4}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          if (card.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.trailing,
                    );
                  }).toList(),
                );
              },
              loading: () => Column(
                children: List.generate(
                  3,
                  (index) => const PaymentCardShimmer(),
                ),
              ),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 32),

            // Summary Section
            if (isValidAmount && _selectedPaymentMethodId != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount'),
                        Text(
                          PaymentUtil.formatAmount(amount),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          PaymentUtil.formatAmount(amount),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isButtonEnabled && !walletState.isLoading
                    ? _handleAddMoney
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: walletState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isButtonEnabled
                            ? 'Add ${PaymentUtil.formatAmount(amount)} to Wallet'
                            : 'Add Money to Wallet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Security Note
            const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Your payment details are securely processed.',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'We do not store sensitive financial information.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyLimitInfo() {
    if (_isLoadingLimit) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final used = WalletService.dailyTopUpLimit - _dailyRemaining;
    final progress = used / WalletService.dailyTopUpLimit;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _dailyRemaining <= 0
            ? AppColors.error.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _dailyRemaining <= 0
              ? AppColors.error.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _dailyRemaining <= 0
                        ? Icons.warning_amber_rounded
                        : Icons.info_outline,
                    size: 16,
                    color: _dailyRemaining <= 0
                        ? AppColors.error
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Daily Top-Up Limit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _dailyRemaining <= 0
                          ? AppColors.error
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${PaymentUtil.formatAmount(used)} / ${PaymentUtil.formatAmount(WalletService.dailyTopUpLimit)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _dailyRemaining <= 0
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _dailyRemaining <= 0 ? AppColors.error : AppColors.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _dailyRemaining <= 0
                ? 'You have reached your daily limit. Try again tomorrow.'
                : 'Remaining: ${PaymentUtil.formatAmount(_dailyRemaining)}',
            style: TextStyle(
              fontSize: 12,
              color: _dailyRemaining <= 0
                  ? AppColors.error
                  : AppColors.success,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
