import 'package:flutter/material.dart';
import 'package:ketamiz/src/model/settings_model.dart';
import 'package:ketamiz/src/theme/app_theme.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_14h_500w.dart';

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({super.key, required this.settingsModel});
  final SettingsModel settingsModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 100,
            spreadRadius: 0,
            color: AppTheme.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            settingsModel.icon,
            size: 24,
            color: AppTheme.black,
          ),
          const SizedBox(width: 16),
          // Bounded width: long titles shrink to fit instead of overflowing.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text14h500w(title: settingsModel.title),
            ),
          ),
        ],
      ),
    );
  }
}
