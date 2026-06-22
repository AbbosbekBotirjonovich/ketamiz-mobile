import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../bloc/profile_bloc.dart';
import '../../../model/api/top_up_model.dart';
import '../../../resources/repository.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/nav_constants.dart';
import '../../../utils/utils.dart';
import '../../widgets/texts/text_14h_400w.dart';
import '../../widgets/texts/text_16h_500w.dart';
import 'top_up_screen.dart';
import 'transaction_details.dart';
import 'withdraw_screen.dart';
import '../home/add_credit_card_screen.dart';
import '../../../model/settings_model.dart';
import '../../widgets/containers/settings_container.dart';

enum _TxnFilter { all, today, days4, days7 }

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final Repository _repository = Repository();
  final ScrollController _scrollController = ScrollController();
  String _balance = "0";
  String _lockedBalance = "0";
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _page = 1;
  int _lastPage = 1;
  _TxnFilter _filter = _TxnFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Only the "All" view loads on scroll; date filters auto-load their range.
    if (_filter != _TxnFilter.all) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 240) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await blocProfile.fetchMe();
    await _loadBalance();
    await _fetchTransactions(reset: true);
    if (mounted) setState(() => _isLoading = false);
    await _autoFillForFilter();
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

  Future<void> _fetchTransactions({bool reset = false}) async {
    try {
      final page = reset ? 1 : _page + 1;
      final response = await _repository.fetchTransactionList(page: page);
      if (!mounted || !response.isSuccess) return;
      final result = response.result;
      List<dynamic> data = [];
      if (result is List) {
        data = result;
      } else if (result is Map && result.containsKey('data')) {
        data = result['data'] as List<dynamic>;
      } else if (result is Map && result.containsKey('transactions')) {
        data = result['transactions'] as List<dynamic>;
      }
      // Pagination meta — absent meta means a single page.
      if (result is Map && result['meta'] is Map) {
        final meta = result['meta'] as Map;
        _page = (meta['current_page'] as num?)?.toInt() ?? page;
        _lastPage = (meta['last_page'] as num?)?.toInt() ?? _page;
      } else {
        _page = page;
        _lastPage = page;
      }
      final list = data.map((e) => TransactionModel.fromJson(e)).toList();
      if (mounted) {
        setState(() {
          if (reset) {
            _transactions = list;
          } else {
            _transactions.addAll(list);
          }
        });
      }
    } catch (_) {}
  }

  bool get _hasMore => _page < _lastPage;

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    await _fetchTransactions();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  /// Keep loading pages until the selected date range is fully covered.
  Future<void> _autoFillForFilter() async {
    final cutoff = _cutoffFor(_filter);
    if (cutoff == null) return;
    var guard = 0;
    while (mounted &&
        _hasMore &&
        guard++ < 30 &&
        _transactions.isNotEmpty &&
        (_transactions.last.createdAt?.toLocal().isAfter(cutoff) ?? false)) {
      await _loadMore();
    }
  }

  DateTime? _cutoffFor(_TxnFilter f) {
    final now = DateTime.now();
    switch (f) {
      case _TxnFilter.all:
        return null;
      case _TxnFilter.today:
        return DateTime(now.year, now.month, now.day);
      case _TxnFilter.days4:
        return now.subtract(const Duration(days: 4));
      case _TxnFilter.days7:
        return now.subtract(const Duration(days: 7));
    }
  }

  List<TransactionModel> get _visible {
    final cutoff = _cutoffFor(_filter);
    if (cutoff == null) return _transactions;
    return _transactions
        .where((t) =>
            t.createdAt != null && t.createdAt!.toLocal().isAfter(cutoff))
        .toList();
  }

  Future<void> _setFilter(_TxnFilter f) async {
    if (_filter == f) return;
    setState(() => _filter = f);
    await _autoFillForFilter();
  }

  Widget _buildFilterChips() {
    Widget chip(_TxnFilter f, String label) {
      final active = _filter == f;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => _setFilter(f),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppTheme.purple : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? AppTheme.purple : AppTheme.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppTheme.dark,
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip(_TxnFilter.all, translate("home.filter_all")),
          chip(_TxnFilter.today, translate("home.filter_today")),
          chip(_TxnFilter.days4, translate("home.filter_4days")),
          chip(_TxnFilter.days7, translate("home.filter_7days")),
        ],
      ),
    );
  }

  void _openAddCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCreditCardScreen(onAdded: (_, __) {}),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          controller: _scrollController,
          padding: const EdgeInsets.only(
              top: 20, left: 16, right: 16, bottom: kNavBarTotalPadding),
          children: [
            _buildBalanceCard(),
            GestureDetector(
              onTap: _openAddCard,
              child: SettingsContainer(
                settingsModel: SettingsModel(
                  icon: Icons.add_card_outlined,
                  title: translate("home.add_card_action"),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text16h500w(title: translate("profile.transactions")),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 14),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child:
                      CircularProgressIndicator(color: AppTheme.purple),
                ),
              )
            else if (_visible.isEmpty)
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
            else ...[
              ...List.generate(
                _visible.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () =>
                        showTransactionDetailsSheet(context, _visible[i]),
                    child: _TransactionItem(transaction: _visible[i]),
                  ),
                ),
              ),
              if (_isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.purple),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.purple, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 8),
            blurRadius: 20,
            color: AppTheme.purple.withOpacity(0.3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text16h500w(
            title: translate("profile.my_balance"),
            color: Colors.white70,
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
                    color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text14h400w(
                  title:
                      "${translate("profile.locked")}: ${Utils.priceFormat(_lockedBalance)} ${translate("currency")}",
                  color: Colors.white70,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
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
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WithdrawScreen()),
                    ).then((_) => _loadData());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.12),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                  label: Text(
                    translate("profile.withdraw"),
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
