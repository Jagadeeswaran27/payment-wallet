import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:app/core/theme/app_theme.dart';

class MainWrapperScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({super.key, required this.navigationShell});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: Colors.black),
                selectedIcon: Icon(Icons.home, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.black,
                ),
                selectedIcon: Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                ),
                label: 'Wallet',
              ),
              NavigationDestination(
                icon: Icon(Icons.flash_on_outlined, color: Colors.black),
                selectedIcon: Icon(
                  Icons.flash_on,
                  color: AppColors.primary,
                ),
                label: 'Blink',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Colors.black),
                selectedIcon: Icon(Icons.person, color: AppColors.primary),
                label: 'Account',
              ),
            ],
            onDestinationSelected: _goBranch,
            indicatorColor: Colors.transparent,
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            height: 65,
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                );
              }
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              );
            }),
          ),
        ),
      ),
    );
  }
}
