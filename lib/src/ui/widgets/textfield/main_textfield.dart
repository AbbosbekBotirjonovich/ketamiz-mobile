import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

class MainTextField extends StatefulWidget {
  const MainTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.controller,
    this.pass = false,
    this.phone = false,
    this.inputFormatters = const [],
    this.scrollPadding = const EdgeInsets.all(20),
    this.textInputAction,
  });

  final String hintText;
  final IconData icon;
  final TextEditingController controller;
  final bool pass;
  final bool phone;
  final List<TextInputFormatter> inputFormatters;

  /// Keyboard action button: [TextInputAction.next] jumps to the next field
  /// without closing the keyboard; [TextInputAction.done] dismisses it.
  final TextInputAction? textInputAction;

  /// Extra space kept between the focused field and the keyboard when the
  /// field is auto-scrolled into view (covers bottom-anchored buttons).
  final EdgeInsets scrollPadding;

  @override
  State<MainTextField> createState() => _MainTextFieldState();
}

class _MainTextFieldState extends State<MainTextField> {
  bool obscure = false;

  @override
  void initState() {
    if (widget.pass == true) {
      obscure = widget.pass;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset:
            const Offset(0, 4),
            blurRadius: 100,
            spreadRadius: 0,
            color: AppTheme.black
                .withOpacity(0.05),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: AppTheme.purple,
        enableInteractiveSelection: true,
        obscureText: obscure,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          height: 1.5,
          color: AppTheme.black,
        ),
        keyboardType: widget.phone == true
            ? TextInputType.phone
            : TextInputType.text,
        autofocus: false,
        scrollPadding: widget.scrollPadding,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          border:
          const OutlineInputBorder(),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius
                .circular(16),
            borderSide:
            const BorderSide(
                color: AppTheme
                    .border),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius
                .circular(16),
            borderSide:
            const BorderSide(
              color:
              AppTheme.purple,
            ),
          ),
          contentPadding:
          const EdgeInsets
              .symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          // hintText: widget.hintText,
          // hintStyle: TextStyle(
          //   fontFamily: AppTheme.fontFamily,
          //   fontSize: 14,
          //   fontWeight: FontWeight.normal,
          //   height: 1.5,
          //   color: AppTheme.dark.withOpacity(0.6),
          // ),
          labelText: widget.hintText,
          labelStyle: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppTheme.dark.withOpacity(0.6),
          ),
          prefixIcon: Icon(widget.icon),
          prefixIconColor: WidgetStateColor.resolveWith(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.focused)) {
                return AppTheme.black;
              }
              return AppTheme.dark;
            },
          ),
          suffixIcon: widget.pass == true? GestureDetector(
            onTap: () {
              setState(() {
                obscure = !obscure;
              });
            },
            child: Icon(obscure == false
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
          ): const SizedBox(),
          suffixIconColor: WidgetStateColor.resolveWith(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.focused)) {
                return AppTheme.black;
              }
              return AppTheme.dark;
            },
          ),
        ),
      ),
    );
  }
}
