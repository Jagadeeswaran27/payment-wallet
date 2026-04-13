import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/models/enums/payment_type.dart';
import 'package:app/router/app_routes.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/payment_method_providers.dart';
import 'package:app/providers/payment_providers.dart';
import 'package:app/utils/payment_util.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/models/payment_card.dart';
import 'package:app/resources/icons.dart';
import 'package:app/utils/decimal_max_value_formatter.dart';
import 'package:app/widgets/pin_verification_sheet.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();

  String _selectedSourceId = 'wallet';
  double _dailyBankRemaining = 50000.0;
  bool _isLoadingLimit = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDailyRemaining();
    });
  }

  Future<void> _fetchDailyRemaining() async {
    setState(() => _isLoadingLimit = true);
    final remaining = await ref
        .read(paymentControllerProvider.notifier)
        .getDailyBankPaymentRemaining();
    if (mounted) {
      setState(() {
        _dailyBankRemaining = remaining;
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

  void _handlePay() async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    if (user.kycStatus != true) {
      CustomSnackBar.show(
        context,
        message: 'Please complete KYC verification to make UPI payments',
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
    final isWallet = _selectedSourceId == 'wallet';

    ref.read(paymentControllerProvider.notifier).sendMoney(
          amount: amount,
          paymentType: isWallet ? PaymentType.wallet : PaymentType.card,
          sourceCardId: isWallet ? null : _selectedSourceId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authStateChangesProvider);
    final user = userState.value;
    final paymentCardsState = ref.watch(paymentMethodControllerProvider);
    final paymentState = ref.watch(paymentControllerProvider);

    ref.listen<AsyncValue<void>>(paymentControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        },
        data: (_) {
          _fetchDailyRemaining();
          CustomSnackBar.show(context, message: 'Payment Successful!');
          goToScreen(context, AppRoutes.home.path);
        },
      );
    });

    final amountText = _amountController.text;
    final amount = double.tryParse(amountText) ?? 0;

    bool isBalanceSufficient = true;
    final isWallet = _selectedSourceId == 'wallet';
    final isKycVerified = user?.kycStatus == true;
    
    if (isWallet && user != null) {
      isBalanceSufficient = amount <= user.walletBalance;
    }

    final double activeLimit = isWallet ? 50000.0 : _dailyBankRemaining;
    final isValidAmount = amount >= 1 && amount <= activeLimit;
    final isButtonEnabled =
        isKycVerified && isValidAmount && isBalanceSufficient && !_isLoadingLimit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
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
            if (paymentState.value != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        paymentState.value![0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Paying to',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          paymentState.value!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

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
                  'KYC verification is required before making UPI payments.',
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                DecimalMaxValueFormatter(
                  maxValue: isWallet ? 50000.0 : _dailyBankRemaining,
                  decimalPlaces: 2,
                ),
              ],
              onChanged: _onAmountChanged,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            if (!isBalanceSufficient && isWallet)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Insufficient Wallet Balance (₹${user?.walletBalance ?? 0})',
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),

            if (!isWallet)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isLoadingLimit
                          ? 'Checking limit...'
                          : 'Daily Bank Limit Remaining: ${PaymentUtil.formatAmount(_dailyBankRemaining)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Source Selection
            const Text(
              'Pay From',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Wallet Option
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _selectedSourceId == 'wallet'
                      ? AppColors.primary
                      : Colors.grey.shade200,
                  width: _selectedSourceId == 'wallet' ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RadioListTile<String>(
                value: 'wallet',
                groupValue: _selectedSourceId,
                onChanged: (value) {
                  setState(() {
                    _selectedSourceId = value!;
                    // Re-validate logic happens in build
                  });
                },
                activeColor: AppColors.primary,
                title: const Text(
                  'Paytm Wallet',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Balance: ${user != null ? PaymentUtil.formatAmount(user.walletBalance) : '₹0'}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                secondary: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Payment Methods (Cards)
            paymentCardsState.when(
              data: (cards) {
                if (cards.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: cards.map((card) {
                    final isSelected = _selectedSourceId == card.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RadioListTile<String>(
                          value: card.id,
                          groupValue: _selectedSourceId,
                          onChanged: (value) {
                            setState(() {
                              _selectedSourceId = value!;
                            });
                          },
                          title: Row(
                            children: [
                              _buildCardIcon(card.cardType),
                              const SizedBox(width: 12),
                              Text(
                                '•••• ${card.last4}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          activeColor: AppColors.primary,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 100), // Spacing for bottom button
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: isButtonEnabled && !paymentState.isLoading
                ? _handlePay
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
            child: paymentState.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Pay ${PaymentUtil.formatAmount(amount)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
