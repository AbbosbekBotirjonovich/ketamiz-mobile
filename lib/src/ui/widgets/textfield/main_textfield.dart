import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

// Warm cream colors shared by every input field (see AppTheme).
const _kBorderColor = AppTheme.inputBorder;
const _kFillColor = AppTheme.inputFill;

class MainTextField extends StatefulWidget {
  const MainTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.pass = false,
    this.phone = false,
    this.prefixText,
    this.inputFormatters = const [],
    this.scrollPadding = const EdgeInsets.all(20),
    this.textInputAction,
    this.fillColor,
    this.dense = false,
    this.keyboardType,
  });

  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool pass;
  final bool phone;
  final String? prefixText;
  final List<TextInputFormatter> inputFormatters;
  final TextInputAction? textInputAction;
  final EdgeInsets scrollPadding;

  /// Overrides the default cream fill when set (e.g. white inputs on a form).
  final Color? fillColor;

  /// Compact height/padding for denser forms.
  final bool dense;

  /// Overrides the keyboard type. Falls back to phone/text based on [phone].
  final TextInputType? keyboardType;

  @override
  State<MainTextField> createState() => _MainTextFieldState();
}

class _MainTextFieldState extends State<MainTextField> {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.pass;
  }

  @override
  Widget build(BuildContext context) {
    final fill = widget.fillColor ?? _kFillColor;
    return Container(
      height: widget.dense ? 50 : 58,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: widget.controller,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: AppTheme.purple,
        enableInteractiveSelection: true,
        obscureText: _obscure,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppTheme.black,
        ),
        keyboardType: widget.keyboardType ??
            (widget.phone ? TextInputType.phone : TextInputType.text),
        autofocus: false,
        scrollPadding: widget.scrollPadding,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          filled: true,
          fillColor: fill,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kBorderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.purple, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: widget.dense ? 11 : 18,
            horizontal: 14,
          ),
          labelText: widget.hintText,
          labelStyle: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppTheme.gray,
          ),
          prefixText: widget.prefixText,
          prefixStyle: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppTheme.black,
          ),
          prefixIcon: Icon(widget.icon, size: 18),
          prefixIconColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.focused)
                ? AppTheme.purple
                : AppTheme.gray,
          ),
          suffixIcon: widget.pass
              ? GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                )
              : null,
          suffixIconColor: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.focused)
                ? AppTheme.purple
                : AppTheme.gray,
          ),
        ),
      ),
    );
  }
}
