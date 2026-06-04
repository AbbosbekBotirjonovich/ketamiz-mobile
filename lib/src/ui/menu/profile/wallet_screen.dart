import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../bloc/profile_bloc.dart';
import '../../../model/api/top_up_model.dart';
import '../../../resources/repository.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/utils.dart';
import '../../widgets/texts/text_14h_400w.dart';
import '../../widgets/texts/text_16h_500w.dart';
import 'top_up_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final Repository _repository = Repository();
  String _balance = "0";
  String _lockedBalance = "0";
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await blocProfile.fetchMe();
    await Future.wait([_loadBalance(), _fetchTransactions()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _balance = prefs.getString('balance') ?? "0";
        _lockedBalance = prefs.getString('balance_locked') ?? "0";
      });
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      final response = await _repository.fetchTransactionList();
      if (!mounted) return;
      if (response.isSuccess) {
        List<dynamic> data = [];
        if (response.result is List) {
          data = response.result as List<dynamic>;
        } else if (response.result is Map &&
            response.result.containsKey('transactions')) {
          data = response.result['transactions'] as List<dynamic>;
        } else if (response.result is Map &&
            response.result.containsKey('data')) {
          data = response.result['data'] as List<dynamic>;
        }
        if (mounted) {
          setState(() {
            _transactions =
                data.map((e) => TransactionModel.fromJson(e)).toList();
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        title: Text16h500w(title: translate("profile.wallet")),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppTheme.purple,
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.only(
              top: 20, left: 16, right: 16, bottom: 92),
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 24),
            Text16h500w(title: translate("profile.transactions")),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child:
                      CircularProgressIndicator(color: AppTheme.purple),
                ),
              )
            else if (_transactions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 56,
                        color: AppTheme.gray.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text14h400w(
                        title: translate("profile.no_transactions"),
                        color: AppTheme.gray,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(
                _transactions.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TransactionItem(transaction: _transactions[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text16h500w(
            title: translate("profile.my_balance"),
            color: AppTheme.gray,
          ),
          const SizedBox(height: 6),
          Text(
            "${Utils.priceFormat(_balance)} ${translate("currency")}",
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    color: AppTheme.gray, size: 16),
                const SizedBox(width: 8),
                Text14h400w(
                  title:
                      "${translate("profile.locked")}: ${Utils.priceFormat(_lockedBalance)} ${translate("currency")}",
                  color: AppTheme.gray,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TopUpScreen()),
                ).then((_) => _loadData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add, size: 20),
              label: Text(
                translate("profile.top_up"),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction});
  final TransactionModel transaction;

  bool get _isCredit =>
      transaction.type == 'top_up' ||
      transaction.type == 'credit' ||
      transaction.type == 'refund';

  String _typeLabel(String type) {
    const known = [
      'top_up',
      'credit',
      'refund',
      'debit',
      'booking',
      'withdrawal'
    ];
    if (known.contains(type)) {
      return translate('profile.transaction_type_$type');
    }
    return type;
  }

  String _fmt(DateTime d) {
    final l = d.toLocal();
    return '${l.day.toString().padLeft(2, '0')}.${l.month.toString().padLeft(2, '0')}.${l.year}  '
        '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

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
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: AppTheme.black.withOpacity(0.04),
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
                Text16h500w(title: _typeLabel(transaction.type)),
                if (transaction.createdAt != null)
                  Text14h400w(
                    title: _fmt(transaction.createdAt!),
                    color: AppTheme.gray,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign ${Utils.priceFormat(transaction.amount)} ${translate("currency")}',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
