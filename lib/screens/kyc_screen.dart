import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/router/app_routes.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/kyc_provider.dart';
import 'package:app/utils/kyc_validators.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/widgets/custom_text_field.dart';
import 'package:app/widgets/custom_dropdown.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/widgets/primary_button.dart';

class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();

  String? _selectedIdType;
  File? _frontImage;
  File? _backImage;

  final List<String> _idTypes = ['Aadhaar Card', 'PAN Card'];

  Future<void> _pickImage(bool isFront) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(pickedFile.path);
        } else {
          _backImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_frontImage == null || _backImage == null) {
      CustomSnackBar.show(
        context,
        message: 'Please upload both side images',
        isError: true,
      );
      return;
    }

    final result = await ref.read(authServiceProvider).getCurrentUser();

    result.fold(
      (failure) {
        CustomSnackBar.show(context, message: failure.message, isError: true);
      },
      (user) {
        ref.read(kycControllerProvider.notifier).updateKycStatus(
          ref: ref,
          uid: user.uid,
          image1: _frontImage!,
          image2: _backImage!,
        );
      },
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycControllerProvider);

    ref.listen(kycControllerProvider, (previous, next) {
      if (!next.isLoading && !next.hasError && previous?.isLoading == true) {
        CustomSnackBar.show(context, message: 'KYC Submitted Successfully!');
        goToScreen(context, AppRoutes.account.path);
      }
      if (next.hasError) {
        CustomSnackBar.show(
          context,
          message: next.error.toString(),
          isError: true,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'KYC Verification',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => popScreen(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Identity Details'),
              const SizedBox(height: 16),
              CustomDropdown(
                value: _selectedIdType,
                hintText: 'Select document type',
                label: 'ID Type',
                prefixIcon: Icons.assignment_ind_outlined,
                items: _idTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedIdType = value;
                    _idController.clear();
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select an ID type' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _idController,
                hintText: 'Enter your ${_selectedIdType ?? "ID"} number',
                label: 'ID Number',
                prefixIcon: Icons.credit_card,
                keyboardType: _selectedIdType == 'Aadhaar Card'
                    ? TextInputType.number
                    : TextInputType.text,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    _selectedIdType == 'Aadhaar Card' ? 12 : 10,
                  ),
                ],
                validator: (value) {
                  if (_selectedIdType == 'Aadhaar Card') {
                    final error = KycValidators.validateAadhar(value);
                    if (error != null) return error;
                  } else if (_selectedIdType == 'PAN Card') {
                    final error = KycValidators.validatePanCard(value);
                    if (error != null) return error;
                  }
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                hintText: 'As mentioned in your ID',
                label: 'Full Name',
                prefixIcon: Icons.person_outline,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _dobController,
                hintText: 'DD/MM/YYYY',
                label: 'Date of Birth',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: KycValidators.validateAge,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Document Upload'),
              const SizedBox(height: 8),
              const Text(
                'Please upload clear photos of your ID card',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildUploadCard(
                      'Front Side',
                      _frontImage,
                      () => _pickImage(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildUploadCard(
                      'Back Side',
                      _backImage,
                      () => _pickImage(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Submit for Verification',
                isLoading: kycState.isLoading,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildUploadCard(String title, File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null ? AppColors.primary : Colors.grey[300]!,
            width: image != null ? 2 : 1,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primary.withOpacity(0.8),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
