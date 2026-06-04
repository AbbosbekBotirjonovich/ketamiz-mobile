import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../resources/repository.dart';
import '../../../theme/app_theme.dart';
import '../../dialogs/center_dialog.dart';
import '../../dialogs/snack_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/containers/leading_back.dart';
import '../../widgets/textfield/main_textfield.dart';
import '../../widgets/texts/text_14h_400w.dart';
import '../../widgets/texts/text_16h_500w.dart';
import '../../widgets/texts/text_18h_500w.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final Repository _repository = Repository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    final prefs = await SharedPreferences.getInstance();
    final first = prefs.getString('first_name') ?? '';
    final last = prefs.getString('last_name') ?? '';
    if (!mounted) return;
    setState(() {
      _nameController.text = '$first $last'.trim();
      _emailController.text = prefs.getString('email') ?? '';
    });
  }

  bool _isValidEmail(String value) {
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return re.hasMatch(value);
  }

  Future<void> _send() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      CenterDialog.showActionFailed(
        context,
        translate("ketamiz.error"),
        translate("home.fill_all_fields"),
      );
      return;
    }
    if (!_isValidEmail(email)) {
      CenterDialog.showActionFailed(
        context,
        translate("ketamiz.error"),
        translate("auth.invalid_email"),
      );
      return;
    }

    setState(() => _isSending = true);
    final response = await _repository.fetchSupport(name, email, message);
    if (!mounted) return;
    setState(() => _isSending = false);

    if (response.isSuccess) {
      final result = response.result;
      final ok = result is! Map ||
          result['success'] == true ||
          result['status'] == 'success' ||
          result['status'] == 200;
      if (ok) {
        CustomSnackBar().showSnackBar(
          context,
          translate("support.success"),
          1,
        );
        _messageController.clear();
        Navigator.pop(context);
        return;
      }
    }
    CenterDialog.showActionFailed(
      context,
      translate("ketamiz.error"),
      response.result is Map && response.result['message'] != null
          ? response.result['message']
          : translate("auth.connection_failed"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("support.title")),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                Text18h500w(title: translate("support.subtitle")),
                const SizedBox(height: 20),
                Text16h500w(title: translate("support.formTitle")),
                const SizedBox(height: 16),
                MainTextField(
                  hintText: translate("support.name"),
                  icon: Icons.person_outline,
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                MainTextField(
                  hintText: translate("support.email"),
                  icon: Icons.email_outlined,
                  controller: _emailController,
                ),
                const SizedBox(height: 16),
                _buildMessageField(),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _isSending ? null : _send,
                  child: PrimaryButton(title: translate("support.send")),
                ),
                const SizedBox(height: 28),
                Text16h500w(title: translate("support.contactInfo")),
                const SizedBox(height: 12),
                _contactRow(
                  icon: Icons.telegram,
                  label: "Telegram",
                  value: "@ketamizcom",
                ),
                _contactRow(
                  icon: Icons.phone_outlined,
                  label: translate("profile.phone_number"),
                  value: "+998 91 665 01 27",
                ),
                _contactRow(
                  icon: Icons.location_on_outlined,
                  label: translate("support.address"),
                  value: "Samarqand Urgut, Uzbekistan.",
                ),
              ],
            ),
            if (_isSending)
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

  Widget _buildMessageField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 100,
            color: AppTheme.black.withOpacity(0.05),
          ),
        ],
      ),
      child: TextField(
        controller: _messageController,
        maxLines: 6,
        cursorColor: AppTheme.purple,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 16,
          color: AppTheme.black,
        ),
        decoration: InputDecoration(
          labelText: translate("support.message"),
          labelStyle: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            color: AppTheme.dark.withOpacity(0.6),
          ),
          alignLabelWithHint: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.purple),
          ),
        ),
      ),
    );
  }

  Widget _contactRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.purple, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text14h400w(title: label, color: AppTheme.gray),
                const SizedBox(height: 2),
                Text16h500w(title: value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
