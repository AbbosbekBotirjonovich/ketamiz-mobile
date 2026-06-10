import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:open_filex/open_filex.dart';

import '../../../model/api/top_up_model.dart';
import '../../../resources/repository.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/utils.dart';
import '../../widgets/texts/text_14h_400w.dart';
import '../../widgets/texts/text_16h_500w.dart';

const _knownTxnTypes = [
  'top_up',
  'credit',
  'refund',
  'debit',
  'booking',
  'withdrawal'
];

String _txnTypeLabel(String type) {
  if (_knownTxnTypes.contains(type)) {
    return translate('profile.transaction_type_$type');
  }
  return type;
}

bool _txnIsCredit(String type) =>
    type == 'top_up' || type == 'credit' || type == 'refund';

String _formatTxnDate(DateTime date) {
  final d = date.toLocal();
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

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

  void _showDetails(TransactionModel t) {
    final isCredit = _txnIsCredit(t.type);
    final color = isCredit ? AppTheme.green : AppTheme.red;
    final sign = isCredit ? '+' : '-';
    final icon =
        isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        bool busy = false;
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            height: 5,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppTheme.gray,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text16h500w(
                            title: translate("home.transaction_details")),
                        const SizedBox(height: 16),
                        Row(
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
                              child: Text16h500w(title: _txnTypeLabel(t.type)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$sign ${Utils.priceFormat(t.amount)} UZS',
                              style: TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        if ((t.reason ?? '').trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.light,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text14h400w(
                                  title: translate("profile.txn_reason"),
                                  color: AppTheme.gray,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t.reason!
                                      .replaceAll(RegExp(r'\s+'), ' ')
                                      .trim(),
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                    color: AppTheme.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        _detailRow(translate("profile.txn_id"), '#${t.id}'),
                        _detailRow(translate("profile.txn_type"),
                            _txnTypeLabel(t.type)),
                        _detailRow(translate("profile.txn_amount"),
                            '${Utils.priceFormat(t.amount)} UZS'),
                        _detailRow(translate("profile.txn_balance_before"),
                            '${Utils.priceFormat(t.balanceBefore)} UZS'),
                        _detailRow(translate("profile.txn_balance_after"),
                            '${Utils.priceFormat(t.balanceAfter)} UZS'),
                        if (t.createdAt != null)
                          _detailRow(translate("profile.txn_date"),
                              _formatTxnDate(t.createdAt!)),
                        if (t.seatsBooked != null)
                          _detailRow(translate("home.seats_booked"),
                              t.seatsBooked.toString()),
                        if ((t.totalPrice ?? '').isNotEmpty)
                          _detailRow(translate("home.total_price"),
                              '${Utils.priceFormat(t.totalPrice!)} UZS'),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: busy
                              ? null
                              : () async {
                                  setSheet(() => busy = true);
                                  await _openReceipt(t.id);
                                  if (ctx.mounted) setSheet(() => busy = false);
                                },
                          child: Container(
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppTheme.purple,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: busy
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.receipt_long_outlined,
                                            color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text16h500w(
                                          title:
                                              translate("home.get_a_receipt"),
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text14h400w(title: label, color: AppTheme.gray),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openReceipt(int id) async {
    final bytes = await _repository.fetchTransactionPdfBytes(id);
    if (!mounted) return;
    if (bytes == null || bytes.isEmpty) {
      _showReceiptError();
      return;
    }
    try {
      final file = File('${Directory.systemTemp.path}/receipt_$id.pdf');
      await file.writeAsBytes(bytes, flush: true);
      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done && mounted) {
        _showReceiptError();
      }
    } catch (_) {
      if (mounted) _showReceiptError();
    }
  }

  void _showReceiptError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(translate("profile.receipt_failed"))),
    );
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
                        onTap: () => _showDetails(t),
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
    final isCredit = _txnIsCredit(transaction.type);
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
                    title: _txnTypeLabel(transaction.type),
                  ),
                  const SizedBox(height: 4),
                  if (transaction.createdAt != null)
                    Text14h400w(
                      title: _formatTxnDate(transaction.createdAt!),
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
