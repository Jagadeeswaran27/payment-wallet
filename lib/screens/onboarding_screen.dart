import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/constants/states.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/onboarding_providers.dart';
import 'package:app/router/app_routes.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/custom_text_field.dart';
import 'package:app/widgets/custom_dropdown.dart';
import 'package:app/widgets/primary_button.dart';
import 'package:app/widgets/custom_snackbar.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedState;
  final _addressController = TextEditingController();
  Timer? _errorTimer;
  bool _showErrors = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _errorTimer?.cancel();
    super.dispose();
  }

  void _handleSubmit() {
    _errorTimer?.cancel();
    setState(() {
      _showErrors = true;
    });

    if (_formKey.currentState!.validate()) {
      ref
          .read(onboardingControllerProvider.notifier)
          .saveOnboardingDetails(
            name: _nameController.text,
            email: _emailController.text,
            userState: _selectedState ?? '',
            address: _addressController.text,
          );
    } else {
      _errorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showErrors = false;
            _formKey.currentState!.validate();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(onboardingControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          CustomSnackBar.show(
            context,
            message: next.error.toString(),
            isError: true,
          );
        },
        data: (data) {
          goToScreen(context, AppRoutes.home.path);
        },
      );
    });

    final onboardingState = ref.watch(onboardingControllerProvider);

    final isLoading = onboardingState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile Setup',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Complete your profile to start using WalletApp',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  autofillHints: const [AutofillHints.name],
                  validator: (value) {
                    if (!_showErrors) return null;
                    return value == null || value.isEmpty
                        ? 'Please enter your name'
                        : null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hintText: 'example@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    if (!_showErrors) return null;
                    if (value == null || value.isEmpty)
                      return 'Please enter your email';
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomDropdown(
                  value: _selectedState,
                  label: 'State',
                  hintText: 'Select your state',
                  prefixIcon: Icons.location_city_outlined,
                  items: indianStates,
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                  },
                  validator: (value) {
                    if (!_showErrors) return null;
                    return value == null || value.isEmpty
                        ? 'Please select your state'
                        : null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _addressController,
                  label: 'Full Address',
                  hintText: 'Enter your permanent address',
                  maxLines: 3,
                  autofillHints: const [AutofillHints.fullStreetAddress],
                  prefix: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(
                      Icons.home_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (!_showErrors) return null;
                    return value == null || value.isEmpty
                        ? 'Please enter your address'
                        : null;
                  },
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  text: 'Get Started',
                  onPressed: _handleSubmit,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
