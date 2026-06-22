// Asosiy smoke test'lar.
//
// Standart Flutter "counter" testi olib tashlandi, chunki bu ilovada counter
// yo'q va u localization (flutter_translate) hamda SharedPreferences'ga
// bog'liq bo'lib, MyApp'ni to'g'ridan-to'g'ri pump qilishni murakkablashtiradi.
//
// Bu yerda ilova kodi importga muammosiz yuklanishini tekshiramiz. Keyinchalik
// haqiqiy widget/unit testlarni shu yerga qo'shib boring.
import 'package:flutter_test/flutter_test.dart';

import 'package:ketamiz/main.dart';

void main() {
  test('App entry point imports without errors', () {
    // main.dart muvaffaqiyatli yuklansa, scaffoldKey global mavjud bo'ladi.
    expect(scaffoldKey, isNotNull);
  });
}
