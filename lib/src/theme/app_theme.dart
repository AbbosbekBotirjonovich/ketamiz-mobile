import 'package:flutter/cupertino.dart';

class AppTheme {
  /// Primary brand colors
  static const Color purple = Color(0xFF4F46E5);       // primary
  static const Color primaryDark = Color(0xFF4338CA);  // primary dark

  /// Semantic colors
  static const Color blue = Color(0xFF0EA5E9);         // secondary
  static const Color yellow = Color(0xFFF59E0B);       // accent
  static const Color orange = Color(0xFFF59E0B);       // accent (alias)
  static const Color orangeLight = Color(0xFFFFF7EC);  // accent light
  static const Color green = Color(0xFF10B981);        // success
  static const Color red = Color(0xFFEF4444);          // error

  /// Background & surface colors
  static const Color bg = Color(0xFFFFFFFF);           // card bg
  static const Color light = Color(0xFFF8FAFC);        // light bg
  static const Color navbarBg = Color(0xFFF5F9F1);     // navbar bg
  static const Color cream = Color(0xFFF6F7F1);         // logo bg (splash)

  /// Text & border colors
  static const Color black = Color(0xFF0F172A);        // dark text
  static const Color dark = Color(0xFF616161);
  static const Color gray = Color(0xFFABABAB);
  static const Color text = Color(0xFF9C9A9A);
  static const Color border = Color(0xFFE2E8F0);

  /// Input field colors (unified across all text fields)
  static const Color inputBorder = Color(0xFFDDD5C8);  // warm cream border
  static const Color inputFill = Color(0xFFFFFBF7);    // warm cream fill

  /// Utility colors
  static const Color shadow = Color(0xFFE0EEFF);
  static const Color baseColor = Color(0xFFEBEBF4);
  static const Color highlightColor = Color(0xFFF4F4F4);

  /// Fonts
  static const String fontFamily = "Poppins";
}
