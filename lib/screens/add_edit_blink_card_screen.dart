import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/models/blink_card_model.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/blink_providers.dart';
import 'package:app/providers/payment_method_providers.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/router/app_routes.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/utils/decimal_max_value_formatter.dart';

class AddEditBlinkCardScreen extends ConsumerStatefulWidget {
  final BlinkCardModel? card;

  const AddEditBlinkCardScreen({super.key, this.card});

  @override
  ConsumerState<AddEditBlinkCardScreen> createState() =>
      _AddEditBlinkCardScreenState();
}

class _AddEditBlinkCardScreenState
    extends ConsumerState<AddEditBlinkCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _upiIdController;
  late TextEditingController _amountController;

  String? _selectedSourceId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card?.name ?? '');
    _upiIdController = TextEditingController(
      text: widget.card?.receiverUpiId ?? '',
    );
    _amountController = TextEditingController(
      text: widget.card?.amount != null ? widget.card!.amount.toString() : '',
    );
    _selectedSourceId = widget.card?.sourceId ?? 'wallet';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _upiIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final user = ref.read(authStateChangesProvider).value;
    if (user?.kycStatus != true) {
      CustomSnackBar.show(
        context,
        message: 'Please complete KYC verification to create Blink cards',
        isError: true,
      );
      pushToScreen(context, AppRoutes.kyc.path);
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_selectedSourceId == null) {
      CustomSnackBar.show(
        context,
        message: 'Please select a payment source',
        isError: true,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    final newCard = BlinkCardModel(
      id: widget.card?.id ?? '', // Service sets correct ID on add
      name: _nameController.text.trim(),
      receiverUpiId: _upiIdController.text.trim(),
      sourceId: _selectedSourceId!,
      amount: amount,
      createdAt: widget.card?.createdAt,
    );

    final controller = ref.read(blinkControllerProvider.notifier);
    final error = widget.card == null
        ? await controller.addCard(newCard)
        : await controller.updateCard(newCard);

    setState(() => _isLoading = false);

    if (error != null) {
      if (mounted) {
        CustomSnackBar.show(context, message: error, isError: true);
      }
    } else {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: widget.card == null
              ? 'Blink card added!'
              : 'Blink card updated!',
        );
        popScreen(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentCardsState = ref.watch(paymentMethodControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.card == null ? 'Create Blink Card' : 'Edit Blink Card',
        ),
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
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Alias Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  'e.g. Monthly Rent, Mom, Groceries',
                  Icons.label_outline,
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _buildLabel('Receiver UPI ID'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _upiIdController,
                decoration: _buildInputDecoration(
                  'receiver@upi',
                  Icons.alternate_email,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (!RegExp(
                    r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$',
                  ).hasMatch(value)) {
                    return 'Enter a valid UPI ID (e.g. user@bank)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildLabel('Amount (₹)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  DecimalMaxValueFormatter(maxValue: 50000.0, decimalPlaces: 2),
                ],
                decoration: _buildInputDecoration('0.00', Icons.currency_rupee),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final numVal = double.tryParse(value);
                  if (numVal == null || numVal <= 0) return 'Invalid amount';
                  if (numVal > 50000) return 'Max ₹50,000 allowed';
                  return null;
                },
              ),

              const SizedBox(height: 24),
              _buildLabel('Payment Source'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: paymentCardsState.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Loading payment sources...'),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Error loading sources',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                  data: (cards) {
                    final cardItems = cards.map((card) {
                      return DropdownMenuItem(
                        value: card.id,
                        child: Text(card.cardHolderName),
                      );
                    }).toList();

                    // Ensure _selectedSourceId exists in the list
                    final availableIds = ['wallet', ...cards.map((c) => c.id)];
                    final effectiveValue =
                        availableIds.contains(_selectedSourceId)
                        ? _selectedSourceId
                        : 'wallet';

                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: effectiveValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedSourceId = value;
                          });
                        },
                        items: [
                          const DropdownMenuItem(
                            value: 'wallet',
                            child: Text('Wallet'),
                          ),
                          ...cardItems,
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: widget.card == null
                    ? 'Create Blink Card'
                    : 'Save Changes',
                onPressed: _handleSave,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }
}
