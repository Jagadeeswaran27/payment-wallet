import 'package:app/providers/kyc_provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:app/router/app_routes.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/widgets/custom_snackbar.dart';
import 'package:app/models/user_model.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Summary (Simple Header)
          if (user != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child:
                          (user.profilePicPath != null &&
                              user.profilePicPath!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: user.profilePicPath!,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              fadeInDuration: Duration.zero,
                              placeholder: (context, url) => const SizedBox(),
                              errorWidget: (context, url, error) =>
                                  _buildInitials(user),
                            )
                          : _buildInitials(user),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name ?? 'User',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? 'No email',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          _buildOptionItem(
            context,
            icon: Icons.person_outline_rounded,
            title: 'My Profile',
            subtitle: 'Edit personal details',
            onTap: () {
              pushToScreen(context, AppRoutes.profile.path);
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Set PIN',
            subtitle: 'Secure your wallet',
            onTap: () {
              CustomSnackBar.show(
                context,
                message: "Set Pin feature will be available soon",
              );
            },
          ),
          _buildDivider(),
          _buildOptionItem(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Kyc Verifcation',
            subtitle: user?.kycStatus == true
                ? 'Identity verified'
                : 'Verify your identity',
            trailing: user?.kycStatus == true
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 20,
                  )
                : null,
            onTap: () async {
              if (user?.kycStatus == true) {
                CustomSnackBar.show(context, message: "Kyc already verified");
                return;
              }
              final result = await ref
                  .read(authServiceProvider)
                  .getCurrentUser();
              result.fold(
                (failure) {
                  CustomSnackBar.show(context, message: failure.message);
                },
                (user) async {
                  final kycStatus = await ref
                      .read(kycProvider)
                      .getKycStatus(ref: ref, uid: user.uid);
                  kycStatus.fold(
                    (failure) {
                      CustomSnackBar.show(context, message: failure.message);
                    },
                    (kycStatus) {
                      if (kycStatus) {
                        CustomSnackBar.show(
                          context,
                          message: "Kyc already verified",
                        );
                      } else {
                        pushToScreen(context, AppRoutes.kyc.path);
                      }
                    },
                  );
                },
              );
            },
          ),
          _buildDivider(),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(UserModel user) {
    return Center(
      child: Text(
        (user.name?.isNotEmpty ?? false) ? user.name![0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      ),
      trailing:
          trailing ??
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey,
          ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade100,
      indent: 64, // Align with text start
    );
  }
}
