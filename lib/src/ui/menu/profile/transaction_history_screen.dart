import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../../model/api/top_up_model.dart';
import '../../../resources/repository.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/utils.dart';
import '../../widgets/texts/text_14h_400w.dart';
import '../../widgets/texts/text_16h_500w.dart';

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
                      return _TransactionCard(
                          transaction: _transactions[index]);
                    },
                  ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});
  final TransactionModel transaction;

  String _typeLabel(String type) {
    const knownTypes = [
      'top_up', 'credit', 'refund', 'debit', 'booking', 'withdrawal'
    ];
    if (knownTypes.contains(type)) {
      return translate('profile.transaction_type_$type');
    }
    return type;
  }

  bool get _isCredit =>
      transaction.type == 'top_up' ||
      transaction.type == 'credit' ||
      transaction.type == 'refund';

  @override
  Widget build(BuildContext context) {
    final isCredit = _isCredit;
    final color = isCredit ? AppTheme.green : AppTheme.red;
    final icon =
        isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final sign = isCredit ? '+' : '-';

    return Container(
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
                  title: _typeLabel(transaction.type),
                ),
                const SizedBox(height: 4),
                if (transaction.createdAt != null)
                  Text14h400w(
                    title: _formatDate(transaction.createdAt!),
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
                title:
                    '${Utils.priceFormat(transaction.balanceAfter)} UZS',
                color: AppTheme.gray,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
