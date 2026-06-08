import 'package:flutter/cupertino.dart';

import '../../../theme/app_theme.dart';

class Text16h500w extends StatelessWidget {
  const Text16h500w({
    super.key,
    required this.title,
    this.color = AppTheme.black,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String title;
  final Color color;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color,
      ),
    );
  }
}
