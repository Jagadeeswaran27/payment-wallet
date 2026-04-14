import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/router/app_routes.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/payment_method_providers.dart';
import 'package:app/utils/input_formatters.dart';

class AddFundingSourceScreen extends ConsumerStatefulWidget {
  const AddFundingSourceScreen({super.key});

  @override
  ConsumerState<AddFundingSourceScreen> createState() =>
      _AddFundingSourceScreenState();
}

class _AddFundingSourceScreenState extends ConsumerState<AddFundingSourceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    final user = ref.read(authStateChangesProvider).value;
    if (user?.kycStatus != true) {
      CustomSnackBar.show(
        context,
        message: 'Please complete KYC verification to add payment cards',
        isError: true,
      );
      pushToScreen(context, AppRoutes.kyc.path);
      return;
    }

    if (_formKey.currentState!.validate()) {
      await ref
          .read(paymentMethodControllerProvider.notifier)
          .addCard(
            cardNumber: _cardNumberController.text,
            expiryDate: _expiryDateController.text,
            cvv: _cvvController.text,
            cardHolderName: _nameController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(paymentMethodControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          if (mounted) {
            CustomSnackBar.show(context, message: "$error", isError: true);
          }
        },
        data: (data) {
          if (mounted) {
            CustomSnackBar.show(context, message: "Card added successfully");
            popScreen(context);
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment Method'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Debit / Credit Card'),
            // Tab(text: 'Bank Account'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCardForm(),
          // _buildBankForm()
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    final paymentControllerState = ref.watch(paymentMethodControllerProvider);
    final isLoading = paymentControllerState.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Card Number'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _cardNumberController,
              hint: 'Enter 16-digit card number',
              keyboardType: TextInputType.number,
              maxLength: 16,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card number';
                }
                if (value.length != 16) {
                  return 'Card number must be 16 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Expiry Date'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _expiryDateController,
                        hint: 'MM/YY',
                        maxLength: 5,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ExpiryDateInputFormatter(),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return 'Invalid format';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('CVV'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _cvvController,
                        hint: '123',
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (value.length != 3) {
                            return 'Invalid CVV';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel('Name on Card'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Enter name as on card',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              text: "Save Card",
              onPressed: _saveCard,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  //  Will work on this later
  // Widget _buildBankForm() {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.all(24.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         _buildLabel('Select Bank'),
  //         const SizedBox(height: 8),
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.grey.shade300),
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           child: DropdownButtonHideUnderline(
  //             child: DropdownButton<String>(
  //               isExpanded: true,
  //               hint: const Text('Choose your bank'),
  //               items: ['HDFC Bank', 'SBI', 'ICICI Bank', 'Axis Bank']
  //                   .map(
  //                     (bank) =>
  //                         DropdownMenuItem(value: bank, child: Text(bank)),
  //                   )
  //                   .toList(),
  //               onChanged: (value) {},
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 24),
  //         _buildLabel('Account Number'),
  //         const SizedBox(height: 8),
  //         _buildTextField(hint: 'Enter account number'),
  //         const SizedBox(height: 24),
  //         _buildLabel('IFSC Code'),
  //         const SizedBox(height: 8),
  //         _buildTextField(hint: 'Enter IFSC code'),
  //         const SizedBox(height: 40),
  //         SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton(
  //             onPressed: () {
  //               // TODO: Add Bank Logic
  //               popScreen(context);
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: AppColors.primary,
  //               padding: const EdgeInsets.symmetric(vertical: 16),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //             ),
  //             child: const Text(
  //               'Add Bank Account',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    String? hint,
    TextEditingController? controller,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
