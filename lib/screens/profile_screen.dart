import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/constants/states.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/profile_providers.dart';
import 'package:app/widgets/custom_text_field.dart';
import 'package:app/widgets/custom_dropdown.dart';
import 'package:app/widgets/custom_snackbar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  String? _selectedState;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateChangesProvider).asData?.value;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _addressController = TextEditingController(text: user?.address);
    _selectedState = user?.state;

    if (_selectedState != null && !indianStates.contains(_selectedState)) {
      if (_selectedState!.isEmpty) {
        _selectedState = null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final currentUser = ref.read(authStateChangesProvider).asData?.value;
      if (currentUser == null) return;

      final updatedUser = currentUser.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        state: _selectedState,
        address: _addressController.text,
        walletBalance: currentUser.walletBalance,
        kycStatus: currentUser.kycStatus,
      );

      ref
          .read(profileControllerProvider.notifier)
          .updateUserProfile(updatedUser, newProfile: _selectedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          setState(() {
            _isEditing = false;
          });
          CustomSnackBar.show(context, message: 'Profile updated successfully');
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

    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState.isLoading;
    final user = ref.watch(authStateChangesProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _isEditing ? _saveProfile : _toggleEdit,
              child: Text(
                _isEditing ? 'Save' : 'Edit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                  )
                                : (user?.profilePicPath != null &&
                                      user!.profilePicPath!.isNotEmpty)
                                ? CachedNetworkImage(
                                    imageUrl: user.profilePicPath!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    fadeInDuration: Duration.zero,
                                    // Note: This might be needed later
                                    // memCacheWidth: 550,
                                    // memCacheHeight: 400,
                                    placeholder: (context, url) =>
                                        const SizedBox(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppColors.primary,
                                        ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_isEditing && _selectedImage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: const Text(
                            'Remove photo',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
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
                enabled: _isEditing,
                autofillHints: const [AutofillHints.name],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                enabled: _isEditing,
                autofillHints: const [AutofillHints.email],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isEditing)
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
                    if (value == null || value.isEmpty) {
                      return 'Please select your state';
                    }
                    return null;
                  },
                )
              else
                CustomTextField(
                  controller: TextEditingController(text: _selectedState),
                  label: 'State',
                  hintText: '',
                  prefixIcon: Icons.location_city_outlined,
                  enabled: false,
                ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _addressController,
                label: 'Full Address',
                hintText: 'Enter your address',
                maxLines: 3,
                prefix: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(
                    Icons.home_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                enabled: _isEditing,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
