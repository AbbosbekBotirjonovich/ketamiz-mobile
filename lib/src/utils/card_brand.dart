/// Detects the local card network (Uzcard / Humo) from a card number's BIN
/// prefix. The first digits remain visible even on masked numbers received
/// from the backend (e.g. "8600 **** **** 1234"), so this works for both a
/// card being entered and one returned by the API.
class CardBrand {
  static const String uzcard = 'Uzcard';
  static const String humo = 'Humo';
  static const String unknown = 'Card';

  /// Returns 'Uzcard', 'Humo', or 'Card'.
  static String detect(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('8600')) return uzcard;
    if (digits.startsWith('9860')) return humo;
    return unknown;
  }

  /// Asset path of the brand logo, or null for unknown brands.
  static String? logoAsset(String raw) {
    switch (detect(raw)) {
      case uzcard:
        return 'assets/logos/uzcard.png';
      case humo:
        return 'assets/logos/humo-logo-more.png';
      default:
        return null;
    }
  }
}
