import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../../model/api/top_up_model.dart';
import '../../../resources/repository.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/utils.dart';
import '../../widgets/texts/text_14h_400w.dart';
import '../../widgets/texts/text_16h_500w.dart';
import 'transaction_details.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final Repository _repository = Repository();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      final response = await _repository.fetchTransactionList();
      if (!mounted) return;
      if (response.isSuccess) {
        List<dynamic> data = [];
        if (response.result is List) {
          data = response.result as List<dynamic>;
        } else if (response.result.containsKey('transactions')) {
          data = response.result['transactions'] as List<dynamic>;
        } else if (response.result.containsKey('data')) {
          data = response.result['data'] as List<dynamic>;
        }
        setState(() {
          _transactions =
              data.map((e) => TransactionModel.fromJson(e)).toList();
        });
      }
    } catch (_) {
      // silently keep empty list on parse errors
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text16h500w(title: translate("profile.transactions")),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppTheme.purple,
        onRefresh: _fetchTransactions,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.purple),
              )
            : _transactions.isEmpty
                ? ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
                          child: Text14h400w(
                            title: translate("profile.no_transactions"),
                            color: AppTheme.gray,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    itemCount: _transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final t = _transactions[index];
                      return _TransactionCard(
                        transaction: t,
                        onTap: () => showTransactionDetailsSheet(context, t),
                      );
                    },
                  ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction, required this.onTap});
  final TransactionModel transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = txnIsCredit(transaction.type);
    final color = isCredit ? AppTheme.green : AppTheme.red;
    final icon =
        isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final sign = isCredit ? '+' : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 100,
              color: AppTheme.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text16h500w(
                    title: txnTypeLabel(transaction.type),
                  ),
                  const SizedBox(height: 4),
                  if (transaction.createdAt != null)
                    Text14h400w(
                      title: formatTxnDate(transaction.createdAt!),
                      color: AppTheme.gray,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign ${Utils.priceFormat(transaction.amount)} UZS',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text14h400w(
                  title: '${Utils.priceFormat(transaction.balanceAfter)} UZS',
                  color: AppTheme.gray,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
