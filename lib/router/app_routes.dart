import 'package:app/screens/kyc_screen.dart';
import 'package:app/screens/payment_success_screen.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:app/screens/auth/otp_screen.dart';
import 'package:app/screens/auth/phone_auth_screen.dart';
import 'package:app/screens/home_screen.dart';
import 'package:app/screens/onboarding_screen.dart';
import 'package:app/screens/welcome_screen.dart';
import 'package:app/screens/profile_screen.dart';
import 'package:app/screens/loading_screen.dart';
import 'package:app/screens/wallet_screen.dart';
import 'package:app/screens/cart_screen.dart';
import 'package:app/screens/account_screen.dart';
import 'package:app/screens/add_funding_source_screen.dart';
import 'package:app/screens/add_money_screen.dart';
import 'package:app/screens/send_money_screen.dart';
import 'package:app/screens/transactions_screen.dart';

enum AppRoutes {
  welcome,
  phoneAuth,
  otp,
  home,
  onboarding,
  profile,
  loading,
  wallet,
  cart,
  account,
  addFundingSource,
  addMoney,
  sendMoney,
  transactions,
  routes,
  kyc,
  paymentSuccess,
}

extension AppRoutesExtension on AppRoutes {
  static const Map<AppRoutes, String> _paths = {
    AppRoutes.welcome: '/welcome',
    AppRoutes.phoneAuth: '/phone-auth',
    AppRoutes.otp: '/otp',
    AppRoutes.home: '/home',
    AppRoutes.onboarding: '/onboarding',
    AppRoutes.profile: '/profile',
    AppRoutes.loading: '/loading',
    AppRoutes.wallet: '/wallet',
    AppRoutes.cart: '/cart',
    AppRoutes.account: '/account',
    AppRoutes.addFundingSource: '/add-funding-source',
    AppRoutes.addMoney: '/add-money',
    AppRoutes.sendMoney: '/send-money',
    AppRoutes.transactions: '/transactions',
    AppRoutes.kyc: '/kyc',
    AppRoutes.paymentSuccess: '/payment-success',
  };

  static const Map<AppRoutes, String> _names = {
    AppRoutes.welcome: 'welcome',
    AppRoutes.phoneAuth: 'phone-auth',
    AppRoutes.otp: 'otp',
    AppRoutes.home: 'home',
    AppRoutes.onboarding: 'onboarding',
    AppRoutes.profile: 'profile',
    AppRoutes.loading: 'loading',
    AppRoutes.wallet: 'wallet',
    AppRoutes.cart: 'cart',
    AppRoutes.account: 'account',
    AppRoutes.addFundingSource: 'add-funding-source',
    AppRoutes.addMoney: 'add-money',
    AppRoutes.sendMoney: 'send-money',
    AppRoutes.transactions: 'transactions',
    AppRoutes.kyc: 'kyc',
    AppRoutes.paymentSuccess: 'payment-success',
  };

  static const Map<AppRoutes, Widget Function()> _builders = {
    AppRoutes.welcome: WelcomeScreen.new,
    AppRoutes.phoneAuth: PhoneAuthScreen.new,
    AppRoutes.otp: OtpScreen.new,
    AppRoutes.home: HomeScreen.new,
    AppRoutes.onboarding: OnboardingScreen.new,
    AppRoutes.profile: ProfileScreen.new,
    AppRoutes.loading: LoadingScreen.new,
    AppRoutes.wallet: WalletScreen.new,
    AppRoutes.cart: CartScreen.new,
    AppRoutes.account: AccountScreen.new,
    AppRoutes.addFundingSource: AddFundingSourceScreen.new,
    AppRoutes.addMoney: AddMoneyScreen.new,
    AppRoutes.sendMoney: SendMoneyScreen.new,
    AppRoutes.transactions: TransactionsScreen.new,
    AppRoutes.kyc: KycScreen.new,
  };

  String get path => _paths[this]!;
  String get name => _names[this]!;

  GoRoute get route {
    if (this == AppRoutes.paymentSuccess) {
      return GoRoute(
        name: name,
        path: path,
        builder: (context, state) {
          final params = state.uri.queryParameters;
          final amount = double.tryParse(params['amount'] ?? '');
          final recipient = params['recipient'];
          return PaymentSuccessScreen(amount: amount, recipient: recipient);
        },
      );
    }
    return GoRoute(
      name: name,
      path: path,
      builder: (context, state) {
        return _builders[this]!();
      },
    );
  }
}
