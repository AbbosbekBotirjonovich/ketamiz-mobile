import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/model/api/my_registered_cards_model.dart' as model;
import 'package:ketamiz/src/theme/app_theme.dart';
import 'package:ketamiz/src/ui/dialogs/snack_bar.dart';
import 'package:ketamiz/src/ui/dialogs/verify_card_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/credit_card_model.dart';
import '../../../resources/repository.dart';
import '../../../utils/card_brand.dart';
import '../../../utils/text_formatters.dart';
import '../../../utils/utils.dart';
import '../../dialogs/center_dialog.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/containers/leading_back.dart';
import '../../widgets/texts/text_16h_500w.dart';
import '../home/add_credit_card_screen.dart';
import 'secure_payment_info_screen.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  TextEditingController amountController = TextEditingController();

  bool isLoading = false;
  String _balance = "0";

  final Repository _repository = Repository();

  static const List<int> _presets = [50000, 100000, 200000, 500000];

  CreditCardModel? selectedCard;
  List<CreditCardModel> cards = [];

  @override
  void initState() {
    super.initState();
    _loadBalance();
    _fetchCards();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _balance = prefs.getString('balance') ?? "0");
  }

  Future<void> _fetchCards() async {
    setState(() {
      isLoading = true;
    });

    final response = await _repository.fetchCardList();

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });

    if (response.isSuccess) {
      final myCardsModel = model.MyCardsResponseModel.fromJson(response.result);
      if (myCardsModel.status == "success") {
        cards = myCardsModel.cards
            .map((e) => CreditCardModel(
                  id: e.id,
                  cardNumber: e.number,
                  expiryDate: e.expiry,
                  cardHolderName: e.label,
                  cvvCode: "",
                  isDefault: e.isDefault == 1,
                  status: e.status,
                  cardKey: e.cardId,
                  phone: e.phone,
                ))
            .toList();

        // Only verified cards can be selected for payment.
        final verifiedCards =
            cards.where((c) => !_needsVerify(c.status)).toList();
        if (verifiedCards.isNotEmpty) {
          selectedCard = verifiedCards.firstWhere((c) => c.isDefault,
              orElse: () => verifiedCards.first);
        } else {
          selectedCard = null;
        }
        setState(() {});
      }
    }
  }

  void _selectCard(int index) {
    setState(() {
      for (final c in cards) {
        c.isDefault = false;
      }
      selectedCard = cards[index];
      cards[index].isDefault = true;
    });
  }

  void _setAmount(int amount) {
    final text = Utils.priceFormat(amount.toString());
    setState(() {
      amountController.text = text;
      amountController.selection =
          TextSelection.collapsed(offset: text.length);
    });
  }

  Future<void> _openAddCard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCreditCardScreen(
          onAdded: (data, msg) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) CustomSnackBar().showSnackBar(context, msg, 1);
            });
          },
        ),
      ),
    );
    if (result == true && mounted) _fetchCards();
  }

  Future<void> _deleteCard(int index) async {
    final card = cards[index];
    final cardId = card.id;
    if (cardId == null) return;
    CenterDialog.showConfirmation(
      context,
      translate("profile.delete_card"),
      translate("profile.delete_card_confirm"),
      onConfirm: () async {
        Navigator.pop(context);
        setState(() => isLoading = true);
        final response = await _repository.fetchDeleteCard(cardId);
        if (!mounted) return;
        setState(() => isLoading = false);
        if (response.isSuccess) {
          CustomSnackBar().showSnackBar(
            context,
            translate("profile.card_deleted"),
            1,
          );
          await _fetchCards();
        } else {
          CenterDialog.showActionFailed(
            context,
            translate("ketamiz.error"),
            response.result is Map && response.result['message'] != null
                ? response.result['message']
                : translate("auth.something_went_wrong"),
          );
        }
      },
    );
  }

  Future<void> _createPayment() async {
    if (amountController.text.isEmpty) {
      CenterDialog.showActionFailed(
        context,
        translate("profile.top_up_failed"),
        translate("profile.enter_amount_error"),
      );
      return;
    }

    if (selectedCard == null) {
      CenterDialog.showActionFailed(
        context,
        translate("home.payment_method_error"),
        translate("home.payment_method_error_msg"),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await _repository.fetchCreatePayment(
      Utils().stringToInt(amountController.text).toString(),
      cardId: selectedCard!.id.toString(),
    );

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });

    if (response.isSuccess) {
      final result = response.result;
      if (result['pay_id'] != null) {
        final payId = result['pay_id'].toString();
        _showConfirmDialog(
          payId,
          (message) {
            CustomSnackBar().showSnackBar(context, message, 1);
          },
        );
      } else {
        CustomSnackBar().showSnackBar(
          context,
          translate("profile.top_up_success"),
          1,
        );
        Navigator.pop(context);
      }
    } else {
      CenterDialog.showActionFailed(
        context,
        translate("profile.top_up_failed"),
        response.result is Map && response.result['message'] != null
            ? response.result['message']
            : translate("auth.something_went_wrong"),
      );
    }
  }

  void _showConfirmDialog(String payId, Function(String) onVerify) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return VerifyCardDialog(
          onResend: () async {
            final resend = await _repository.fetchResendPaymentSms(payId);
            if (!mounted) return;
            CustomSnackBar().showSnackBar(
              context,
              resend.isSuccess
                  ? translate("auth.code_resent")
                  : translate("auth.something_went_wrong"),
              resend.isSuccess ? 1 : 0,
            );
          },
          onVerify: (code) async {
            setState(() {
              isLoading = true;
            });

            final response = await _repository.fetchConfirmPayment(payId, code);

            setState(() {
              isLoading = false;
            });

            if (response.isSuccess) {
              final message = response.result['message'] ??
                  translate("profile.top_up_success");
              onVerify(message);
              Navigator.pop(dialogContext);
            } else {
              onVerify(
                  response.result is Map && response.result['message'] != null
                      ? response.result['message']
                      : translate("auth.something_went_wrong"));
              Navigator.pop(dialogContext);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        backgroundColor: AppTheme.light,
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("profile.top_up")),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded,
                color: AppTheme.purple),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SecurePaymentInfoScreen()),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              children: [
                _buildBalanceCard(),
                const SizedBox(height: 20),
                _sectionLabel(translate("profile.enter_top_up_amount")),
                const SizedBox(height: 10),
                _buildAmountField(),
                const SizedBox(height: 10),
                _buildAmountChips(),
                const SizedBox(height: 20),
                _sectionLabel(translate("home.select_payment_card")),
                const SizedBox(height: 10),
                ...List.generate(cards.length, _buildCardRow),
                _buildAddCardButton(),
                const SizedBox(height: 16),
                _buildSecureBanner(),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: AppTheme.light,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: GestureDetector(
                  onTap: _createPayment,
                  child: PrimaryButton(
                    title: translate("home.confirm_payment"),
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: AppTheme.black.withOpacity(0.45),
                child: Center(
                  child: Container(
                    height: 96,
                    width: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.purple),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Balance ────────────────────────────────────────────────────────────────
  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _iconBox(Icons.account_balance_wallet_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate("home.current_balance"),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.gray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${Utils.priceFormat(_balance)} ${translate("ketamiz.som")}",
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppTheme.gray, size: 22),
        ],
      ),
    );
  }

  // ── Amount ─────────────────────────────────────────────────────────────────
  Widget _buildAmountField() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: AppTheme.purple, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.phone,
              cursorColor: AppTheme.purple,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.black,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                PriceInputFormatter(maxDigits: 10),
              ],
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: "0",
                hintStyle: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gray,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            translate("ketamiz.som"),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.gray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountChips() {
    final current =
        int.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0;
    return Row(
      children: _presets.map((amount) {
        final selected = current == amount;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => _setAmount(amount),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.purple.withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? AppTheme.purple : AppTheme.border,
                  ),
                ),
                child: Center(
                  child: Text(
                    Utils.priceFormat(amount.toString()),
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppTheme.purple : AppTheme.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Cards ──────────────────────────────────────────────────────────────────
  Widget _buildCardRow(int index) {
    final card = cards[index];
    final verified = !_needsVerify(card.status);
    final selected = verified && selectedCard?.id == card.id;
    final logo = CardBrand.logoAsset(card.cardNumber);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: verified
          ? () => _selectCard(index)
          : () => CustomSnackBar().showSnackBar(
              context, translate("home.card_unverified_hint"), 2),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.purple : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Card content dims when unverified (disabled); the Remove button
            // stays fully active.
            Expanded(
              child: Opacity(
                opacity: verified ? 1.0 : 0.5,
                child: Row(
                  children: [
                    _radio(selected),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 32,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.light,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: logo != null
                          ? Image.asset(logo, fit: BoxFit.contain)
                          : const Icon(Icons.credit_card,
                              color: AppTheme.gray, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _maskedNumber(card.cardNumber),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (card.cardHolderName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              card.cardHolderName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.gray,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (card.isDefault)
                                _badge(translate("home.main_card"),
                                    AppTheme.green),
                              _statusBadge(card.status),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            _cardActionButton(
              label: translate("delete"),
              color: AppTheme.red,
              filled: true,
              onTap: () => _deleteCard(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 94,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }

  bool _needsVerify(String status) {
    final s = status.toLowerCase();
    return s == 'not_verified' || s == 'unverified' || s == 'pending';
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final s = status.toLowerCase();
    if (s == 'verified' || s == 'active' || s == 'success') {
      return _badge(translate("home.card_verified"), AppTheme.green);
    }
    if (s == 'not_verified' || s == 'unverified' || s == 'pending') {
      return _badge(translate("home.card_not_verified"), AppTheme.orange);
    }
    if (status.isEmpty) return const SizedBox.shrink();
    return _badge(status, AppTheme.gray);
  }

  Widget _radio(bool selected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppTheme.purple : AppTheme.gray,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppTheme.purple,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildAddCardButton() {
    return GestureDetector(
      onTap: _openAddCard,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.purple.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.purple.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.purple.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppTheme.purple, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              translate("home.add_new_card"),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Secure banner ──────────────────────────────────────────────────────────
  Widget _buildSecureBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.purple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_rounded,
              color: AppTheme.purple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate("home.secure_payment"),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  translate("home.secure_payment_desc"),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    color: AppTheme.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      );

  Widget _iconBox(IconData icon) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: AppTheme.purple),
      );

  Widget _sectionLabel(String title) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.black,
          ),
        ),
      );

  String _maskedNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 8) return raw;
    final first4 = digits.substring(0, 4);
    final last4 = digits.substring(digits.length - 4);
    return '$first4 **** **** $last4';
  }

}
