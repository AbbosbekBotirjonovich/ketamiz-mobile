import 'package:flutter/material.dart';
import 'package:ketamiz/src/model/settings_model.dart';
import 'package:ketamiz/src/theme/app_theme.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_14h_500w.dart';

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({
    super.key,
    required this.settingsModel,
    this.iconColor = AppTheme.purple,
    this.trailingText,
    this.showChevron = true,
  });

  final SettingsModel settingsModel;
  final Color iconColor;

  /// Optional value shown on the right (e.g. the current language).
  final String? trailingText;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 24,
            spreadRadius: 0,
            color: AppTheme.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(settingsModel.icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text14h500w(title: settingsModel.title),
            ),
          ),
          if (trailingText != null) ...[
            const SizedBox(width: 8),
            Text(
              trailingText!,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.purple,
              ),
            ),
          ],
          if (showChevron) ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 20, color: AppTheme.gray),
          ],
        ],
      ),
    );
  }
}
