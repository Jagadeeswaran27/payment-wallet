import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app/providers/transaction_providers.dart';
import 'package:app/models/transaction_model.dart';
import 'package:app/models/enums/payment_type.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/utils/payment_util.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: transactionsState.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Sort transactions by timestamp descending (newest first)
          final sortedTransactions = List<TransactionModel>.from(transactions)
            ..sort((a, b) {
              if (a.timestamp == null || b.timestamp == null) return 0;
              return b.timestamp!.compareTo(a.timestamp!);
            });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sortedTransactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final transaction = sortedTransactions[index];
              return _TransactionItem(transaction: transaction);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading transactions: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.transactionType == TransactionType.credit;
    final isWallet = transaction.paymentType == PaymentType.wallet;

    // Icon logic
    IconData icon;
    Color iconColor;
    if (isCredit) {
      icon = Icons.account_balance_wallet;
      iconColor = Colors.green;
    } else {
      icon = isWallet ? Icons.account_balance_wallet : Icons.credit_card;
      iconColor = isWallet ? AppColors.primary : Colors.orange;
    }

    // Title logic
    String title;
    if (isCredit) {
      title = 'Added to Wallet';
    } else {
      title = 'To ${transaction.destinationUpiId}';
    }

    // Subtitle logic
    String subtitle = '';
    if (isCredit && transaction.sourceCardId != null) {
      // Parse sourceCardId (e.g., pm_visa_1234)
      final parts = transaction.sourceCardId!.split('_');
      String cardName = 'Bank';
      String last4 = '';

      if (parts.length >= 3) {
        // e.g., pm, visa, 1234
        final typeStr = parts[1];
        last4 = parts[2];

        switch (typeStr.toLowerCase()) {
          case 'visa':
            cardName = 'Visa';
            break;
          case 'mastercard':
            cardName = 'Mastercard';
            break;
          case 'rupay':
            cardName = 'Rupay';
            break;
          default:
            cardName = 'Card';
        }
      } else if (transaction.sourceCardId!.length >= 4) {
        last4 = transaction.sourceCardId!.substring(
          transaction.sourceCardId!.length - 4,
        );
        cardName = 'Card';
      }

      subtitle = 'From  ****$last4';
    }

    // Format timestamp
    String dateString = '';
    if (transaction.timestamp != null) {
      dateString = DateFormat(
        'MMM d, yyyy • h:mm a',
      ).format(transaction.timestamp!.toDate());
    }

    // Amount logic
    final amountSign = isCredit ? '+' : '-';
    final amountColor = isCredit ? Colors.green : AppColors.textPrimary;

    // Combine subtitle and date
    String dateAndSource;
    if (subtitle.isNotEmpty) {
      dateAndSource = '$subtitle\n$dateString';
    } else {
      dateAndSource = dateString;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateAndSource,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$amountSign ${PaymentUtil.formatAmount(transaction.amount)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
