import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

/// Input field styled as a white rounded card with a leading icon box, a title
/// label on top and the editable value (or placeholder) below it. Optional
/// password eye-toggle and a static prefix (e.g. "+998 ") are supported.
class LabeledInputField extends StatefulWidget {
  const LabeledInputField({
    super.key,
    required this.title,
    required this.hint,
    required this.icon,
    required this.controller,
    this.pass = false,
    this.phone = false,
    this.prefixText,
    this.inputFormatters = const [],
    this.keyboardType,
    this.textInputAction,
    this.scrollPadding = const EdgeInsets.all(20),
  });

  final String title;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool pass;
  final bool phone;
  final String? prefixText;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final EdgeInsets scrollPadding;

  @override
  State<LabeledInputField> createState() => _LabeledInputFieldState();
}

class _LabeledInputFieldState extends State<LabeledInputField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.pass;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.purple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(widget.icon, color: AppTheme.purple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (widget.prefixText != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Text(
                          widget.prefixText!,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.black,
                          ),
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        obscureText: _obscure,
                        keyboardType: widget.keyboardType ??
                            (widget.phone
                                ? TextInputType.phone
                                : TextInputType.text),
                        inputFormatters: widget.inputFormatters,
                        textInputAction: widget.textInputAction,
                        scrollPadding: widget.scrollPadding,
                        cursorColor: AppTheme.purple,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.black,
                        ),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: widget.hint,
                          hintStyle: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.gray,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.pass)
            GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppTheme.gray,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
