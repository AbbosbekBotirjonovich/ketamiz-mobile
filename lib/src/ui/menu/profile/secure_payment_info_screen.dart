import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../../../theme/app_theme.dart';
import '../../widgets/containers/leading_back.dart';
import '../../widgets/texts/text_16h_500w.dart';

/// Static information page describing how payments are kept secure.
class SecurePaymentInfoScreen extends StatelessWidget {
  const SecurePaymentInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        backgroundColor: AppTheme.light,
        elevation: 0,
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("home.secure_info_title")),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.purple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_user_rounded,
                  size: 46, color: AppTheme.purple),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text16h500w(title: translate("home.secure_info_title")),
          ),
          const SizedBox(height: 8),
          Text(
            translate("home.secure_info_intro"),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppTheme.gray,
            ),
          ),
          const SizedBox(height: 24),
          _point(Icons.lock_outline_rounded,
              translate("home.secure_point_1")),
          const SizedBox(height: 12),
          _point(Icons.no_accounts_outlined,
              translate("home.secure_point_2")),
          const SizedBox(height: 12),
          _point(Icons.sms_outlined, translate("home.secure_point_3")),
        ],
      ),
    );
  }

  Widget _point(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppTheme.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: AppTheme.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
