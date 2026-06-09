import 'package:flutter/services.dart';

/// Formats Uzbek mobile numbers as "XX XXX XX XX" and caps input at 9 digits.
/// The "+998" country code is shown separately as a field prefix, so the field
/// itself only holds the 9 local digits (spaced for readability).
class UzPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 9) digits = digits.substring(0, 9);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      // Group as XX XXX XX XX → spaces before the 3rd, 6th and 8th digit.
      if (i == 2 || i == 5 || i == 7) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Builds the full E.164 number ("+998XXXXXXXXX") from a formatted field value.
String uzFullPhone(String fieldText) =>
    '+998${fieldText.replaceAll(RegExp(r'\D'), '')}';

/// Returns just the 9 local digits from a formatted field value.
String uzPhoneDigits(String fieldText) =>
    fieldText.replaceAll(RegExp(r'\D'), '');
