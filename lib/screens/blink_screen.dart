import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/blink_providers.dart';
import 'package:app/router/app_routes.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/utils/payment_util.dart';
import 'package:app/widgets/blink_payment_sheet.dart';
import 'package:app/widgets/custom_snackbar.dart';

const List<List<Color>> _blinkGradients = [
  [Color(0xFF1A1F36), Color(0xFF0D1126)], // Deep professional slate/navy
];

OverlayEntry? _blinkInfoOverlayEntry;

class BlinkScreen extends ConsumerWidget {
  const BlinkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blinkCardsState = ref.watch(blinkCardsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blink Cards'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          GestureDetector(
            onTapDown: (details) => _showBlinkInfoCard(context, details),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.info_outline, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      body: blinkCardsState.when(
        data: (cards) {
          if (cards.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(blinkCardsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                final gradient =
                    _blinkGradients[index % _blinkGradients.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GestureDetector(
                    onTap: () {
                      if (!_ensureKycVerified(context, ref)) {
                        return;
                      }
                      showBlinkPaymentSheet(context, ref, card);
                    },
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background sleek minimalist logo
                          Positioned(
                            right: 20,
                            bottom: 20,
                            child: Icon(
                              Icons.contactless_outlined,
                              size: 40,
                              color: Colors.white.withOpacity(0.12),
                            ),
                          ),
                          // Front Content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            card.name.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.5,
                                              color: Colors.white,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            card.receiverUpiId,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0.5,
                                              color: Colors.white.withOpacity(0.6),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          if (!_ensureKycVerified(context, ref)) {
                                            return;
                                          }
                                          pushToScreen(
                                            context,
                                            AppRoutes.addEditBlink.path,
                                            extra: card,
                                          );
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(
                                            Icons.tune,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'AMOUNT',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 2.0,
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          PaymentUtil.formatAmount(card.amount),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'SOURCE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 2.0,
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          card.sourceId == 'wallet'
                                              ? 'Wallet'
                                              : 'Card •••• ${card.sourceId.substring(max(0, card.sourceId.length - 4))}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 1.2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (!_ensureKycVerified(context, ref)) {
            return;
          }
          pushToScreen(context, AppRoutes.addEditBlink.path);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showBlinkInfoCard(BuildContext context, TapDownDetails details) {
    _blinkInfoOverlayEntry?.remove();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final screenWidth = MediaQuery.of(context).size.width;
    const cardWidth = 280.0;
    final left = (details.globalPosition.dx - cardWidth + 32).clamp(
      12.0,
      screenWidth - cardWidth - 12,
    );
    final top = details.globalPosition.dy + 12;

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: left.toDouble(),
          top: top,
          width: cardWidth,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Blink lets you save quick-pay cards for frequent UPI transfers.\n'
                'Tap a card to pay instantly with a preselected amount and source.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );

    _blinkInfoOverlayEntry = entry;
    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 2), () {
      if (_blinkInfoOverlayEntry == entry) {
        _blinkInfoOverlayEntry?.remove();
        _blinkInfoOverlayEntry = null;
      }
    });
  }

  bool _ensureKycVerified(BuildContext context, WidgetRef ref) {
    final user = ref.read(authStateChangesProvider).value;
    if (user?.kycStatus == true) {
      return true;
    }

    CustomSnackBar.show(
      context,
      message: 'Please complete KYC verification to use this feature',
      isError: true,
    );
    pushToScreen(context, AppRoutes.kyc.path);
    return false;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No Blink Cards Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create reusable cards for blazing fast payments.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
