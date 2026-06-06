import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/theme/app_theme.dart';
import 'package:ketamiz/src/ui/dialogs/center_dialog.dart';
import 'package:ketamiz/src/ui/dialogs/snack_bar.dart';
import 'package:ketamiz/src/ui/widgets/buttons/primary_button.dart';
import 'package:ketamiz/src/ui/widgets/containers/leading_back.dart';
import 'package:ketamiz/src/ui/widgets/textfield/main_textfield.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_16h_500w.dart';
import 'package:ketamiz/src/utils/text_formatters.dart';
import 'package:ketamiz/src/utils/utils.dart';

import '../../../resources/repository.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _repository = Repository();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _amountController.text.trim();
    if (raw.isEmpty) {
      CenterDialog.showActionFailed(
        context,
        translate('profile.withdraw_failed'),
        translate('profile.enter_amount_error'),
      );
      return;
    }

    final amount = Utils().stringToInt(raw).toString();

    setState(() => _isLoading = true);
    final response = await _repository.fetchWithdraw(amount);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess) {
      CustomSnackBar().showSnackBar(
        context,
        translate('profile.withdraw_success'),
        1,
      );
      Navigator.pop(context, true);
    } else {
      CenterDialog.showActionFailed(
        context,
        translate('profile.withdraw_failed'),
        response.result is Map && response.result['message'] != null
            ? response.result['message']
            : translate('auth.something_went_wrong'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const LeadingBack(),
        title: Text16h500w(title: translate('profile.withdraw_title')),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainTextField(
                    hintText: translate('profile.enter_withdraw_amount'),
                    icon: Icons.currency_exchange_outlined,
                    controller: _amountController,
                    phone: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      PriceInputFormatter(maxDigits: 10),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.purple,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${translate('profile.withdraw')} ${translate('currency')}',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 13,
                              color: AppTheme.dark,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: GestureDetector(
                  onTap: _submit,
                  child: PrimaryButton(
                    title: translate('profile.withdraw'),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: AppTheme.black.withOpacity(0.45),
                child: Center(
                  child: Container(
                    height: 96,
                    width: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 5),
                          blurRadius: 25,
                          color: AppTheme.dark.withOpacity(0.2),
                        ),
                      ],
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
}
