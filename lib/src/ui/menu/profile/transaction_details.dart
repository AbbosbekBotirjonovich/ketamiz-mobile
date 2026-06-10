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
  'top_up', 'credit', 'refund', 'debit', 'booking', 'withdrawal'
];

/// Human-readable label for a transaction type (falls back to the raw value).
String txnTypeLabel(String type) {
  if (_knownTxnTypes.contains(type)) {
    return translate('profile.transaction_type_$type');
  }
  return type;
}

/// Money-in types (shown green with a down arrow); everything else is money-out.
bool txnIsCredit(String type) =>
    type == 'top_up' || type == 'credit' || type == 'refund';

String formatTxnDate(DateTime date) {
  final d = date.toLocal();
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

/// Opens the shared transaction details bottom sheet (with a PDF receipt
/// action). Reused from the transactions history and the wallet pages.
void showTransactionDetailsSheet(BuildContext context, TransactionModel t) {
  final isCredit = txnIsCredit(t.type);
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
                      Text16h500w(title: translate("home.transaction_details")),
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
                            child: Text16h500w(title: txnTypeLabel(t.type)),
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
                      _detailRow(
                          translate("profile.txn_type"), txnTypeLabel(t.type)),
                      _detailRow(translate("profile.txn_amount"),
                          '${Utils.priceFormat(t.amount)} UZS'),
                      _detailRow(translate("profile.txn_balance_before"),
                          '${Utils.priceFormat(t.balanceBefore)} UZS'),
                      _detailRow(translate("profile.txn_balance_after"),
                          '${Utils.priceFormat(t.balanceAfter)} UZS'),
                      if (t.createdAt != null)
                        _detailRow(translate("profile.txn_date"),
                            formatTxnDate(t.createdAt!)),
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
                                await _openReceipt(ctx, t.id);
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
                                        title: translate("home.get_a_receipt"),
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

Future<void> _openReceipt(BuildContext context, int id) async {
  final bytes = await Repository().fetchTransactionPdfBytes(id);
  if (!context.mounted) return;
  if (bytes == null || bytes.isEmpty) {
    _receiptError(context);
    return;
  }
  try {
    final file = File('${Directory.systemTemp.path}/receipt_$id.pdf');
    await file.writeAsBytes(bytes, flush: true);
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done && context.mounted) {
      _receiptError(context);
    }
  } catch (_) {
    if (context.mounted) _receiptError(context);
  }
}

void _receiptError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(translate("profile.receipt_failed"))),
  );
}
