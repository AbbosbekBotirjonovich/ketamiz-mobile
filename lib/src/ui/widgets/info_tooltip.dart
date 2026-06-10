import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A small info icon that reveals a hint message when tapped.
///
/// Reusable across forms to explain what a field expects.
class InfoTooltip extends StatelessWidget {
  const InfoTooltip({
    super.key,
    required this.message,
    this.size = 16,
    this.color = AppTheme.gray,
  });

  final String message;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 4),
      preferBelow: true,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(10),
      ),
      textStyle: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: Colors.white,
      ),
      child: Icon(Icons.info_outline, size: size, color: color),
    );
  }
}
