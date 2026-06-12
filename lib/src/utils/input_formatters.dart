import 'package:flutter/services.dart';

/// 2 uppercase letters + 7 digits  →  AB1234567
/// Used for: personal passport, driver licence number.
class DocumentNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final raw = next.text.toUpperCase();
    final buf = StringBuffer();
    int pos = 0;

    for (int i = 0; i < raw.length && pos < 9; i++) {
      final c = raw[i];
      if (pos < 2) {
        if (RegExp(r'[A-Z]').hasMatch(c)) { buf.write(c); pos++; }
      } else {
        if (RegExp(r'\d').hasMatch(c)) { buf.write(c); pos++; }
      }
    }

    final s = buf.toString();
    return TextEditingValue(
      text: s,
      selection: TextSelection.collapsed(offset: s.length),
    );
  }
}

/// Uzbekistan vehicle plate — two patterns:
///   Pattern A:  40 O 450 FB   (2 digits · 1 letter · 3 digits · 2 letters)
///   Pattern B:  40 456 ABC    (2 digits · 3 digits · 3 letters)
/// Pattern is determined by whether the 3rd raw character is a letter (A) or
/// digit (B).  Spaces are inserted automatically.
class VehiclePlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final raw =
        next.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    if (raw.isEmpty) return TextEditingValue.empty;

    final buf = StringBuffer();
    int i = 0;

    // Region code: 2 digits
    while (i < raw.length && buf.length < 2) {
      if (RegExp(r'\d').hasMatch(raw[i])) buf.write(raw[i]);
      i++;
    }
    if (buf.length < 2 || i >= raw.length) {
      final s = buf.toString();
      return TextEditingValue(
          text: s, selection: TextSelection.collapsed(offset: s.length));
    }

    buf.write(' ');
    final third = raw[i];

    if (RegExp(r'[A-Z]').hasMatch(third)) {
      // Pattern A: letter · space · 3 digits · space · 2 letters
      buf.write(third); i++;
      if (i >= raw.length) {
        final s = buf.toString();
        return TextEditingValue(
            text: s, selection: TextSelection.collapsed(offset: s.length));
      }
      buf.write(' ');
      int count = 0;
      while (i < raw.length && count < 3) {
        if (RegExp(r'\d').hasMatch(raw[i])) { buf.write(raw[i]); count++; }
        i++;
      }
      if (count < 3 || i >= raw.length) {
        final s = buf.toString();
        return TextEditingValue(
            text: s, selection: TextSelection.collapsed(offset: s.length));
      }
      buf.write(' ');
      count = 0;
      while (i < raw.length && count < 2) {
        if (RegExp(r'[A-Z]').hasMatch(raw[i])) { buf.write(raw[i]); count++; }
        i++;
      }
    } else if (RegExp(r'\d').hasMatch(third)) {
      // Pattern B: 3 digits · space · 3 letters
      int count = 0;
      while (i < raw.length && count < 3) {
        if (RegExp(r'\d').hasMatch(raw[i])) { buf.write(raw[i]); count++; }
        i++;
      }
      if (count < 3 || i >= raw.length) {
        final s = buf.toString();
        return TextEditingValue(
            text: s, selection: TextSelection.collapsed(offset: s.length));
      }
      buf.write(' ');
      count = 0;
      while (i < raw.length && count < 3) {
        if (RegExp(r'[A-Z]').hasMatch(raw[i])) { buf.write(raw[i]); count++; }
        i++;
      }
    }

    final s = buf.toString();
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

/// Tech passport serie: exactly 3 uppercase letters  →  AAG
class TechSerieFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final filtered =
        next.text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final s = filtered.length > 3 ? filtered.substring(0, 3) : filtered;
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

/// Tech passport combined: 3 uppercase letters + 7 digits  →  AAG8534413
class TechPassportCombinedFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final raw = next.text.toUpperCase();
    final buf = StringBuffer();
    int pos = 0;

    for (int i = 0; i < raw.length && pos < 10; i++) {
      final c = raw[i];
      if (pos < 3) {
        if (RegExp(r'[A-Z]').hasMatch(c)) { buf.write(c); pos++; }
      } else {
        if (RegExp(r'\d').hasMatch(c)) { buf.write(c); pos++; }
      }
    }

    final s = buf.toString();
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}

/// Tech passport number: exactly 7 digits  →  8534413
class TechNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final filtered = next.text.replaceAll(RegExp(r'[^\d]'), '');
    final s = filtered.length > 7 ? filtered.substring(0, 7) : filtered;
    return TextEditingValue(
        text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}
