// One-off data migration: adds name_uz / name_ru / name_en to every village
// in assets/places.json (they only had a single `name` field, so village
// names never changed with the app language).
//
// uz/en keep the Uzbek Latin spelling; ru is produced by rule-based
// Uzbek Latin -> Cyrillic transliteration (the standard way Uzbek place
// names are written in Russian).
//
// Run from the project root:  dart run tool/add_village_translations.dart
import 'dart:convert';
import 'dart:io';

final Set<String> unmapped = {};

const Map<String, String> digraphs = {
  // oʻ / gʻ with every apostrophe variant found in the wild
  "o'": 'ў', 'oʻ': 'ў', 'o`': 'ў', 'o’': 'ў', 'o‘': 'ў',
  "g'": 'ғ', 'gʻ': 'ғ', 'g`': 'ғ', 'g’': 'ғ', 'g‘': 'ғ',
  'sh': 'ш', 'ch': 'ч', 'yo': 'ё', 'ya': 'я', 'yu': 'ю', 'ye': 'е',
};

const Map<String, String> singles = {
  'a': 'а', 'b': 'б', 'd': 'д', 'f': 'ф', 'g': 'г', 'h': 'ҳ', 'i': 'и',
  'j': 'ж', 'k': 'к', 'l': 'л', 'm': 'м', 'n': 'н', 'o': 'о', 'p': 'п',
  'q': 'қ', 'r': 'р', 's': 'с', 't': 'т', 'u': 'у', 'v': 'в', 'x': 'х',
  'y': 'й', 'z': 'з',
  // data typos use latin c for s; Karakalpak names use w (= ў in Cyrillic)
  'c': 'с', 'w': 'ў',
  // tutuq belgisi (glottal stop) variants
  "'": 'ъ', 'ʼ': 'ъ', '’': 'ъ', '`': 'ъ', '‘': 'ъ', 'ʻ': 'ъ',
};

final RegExp latinLetter = RegExp(r'[A-Za-z]');

String matchCase(String mapped, String source) =>
    source[0] == source[0].toLowerCase() ? mapped : mapped.toUpperCase();

String toCyrillic(String s) {
  final sb = StringBuffer();
  var i = 0;
  var wordStart = true;
  while (i < s.length) {
    if (i + 1 < s.length) {
      final two = s.substring(i, i + 2);
      final mapped = digraphs[two.toLowerCase()];
      if (mapped != null) {
        sb.write(matchCase(mapped, two));
        i += 2;
        wordStart = false;
        continue;
      }
    }
    final ch = s[i];
    final lower = ch.toLowerCase();
    String? mapped;
    if (lower == 'e') {
      mapped = wordStart ? 'э' : 'е'; // word-initial E -> Э (Eski -> Эски)
    } else {
      mapped = singles[lower];
    }
    if (mapped != null) {
      sb.write(matchCase(mapped, ch));
      wordStart = false;
    } else {
      sb.write(ch); // digits, spaces, dashes, existing Cyrillic, etc.
      if (latinLetter.hasMatch(ch)) {
        unmapped.add(ch);
        wordStart = false;
      } else {
        wordStart = true; // separators start a new word
      }
    }
    i++;
  }
  return sb.toString();
}

void fillNames(Map<String, dynamic> item) {
  final base = (item['name_uz'] ?? item['name'] ?? '').toString();
  item['name_uz'] ??= base;
  item['name_en'] ??= base;
  item['name_ru'] ??= toCyrillic(base);
}

void main() {
  final file = File('assets/places.json');
  final data =
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  var filled = 0;
  for (final key in ['regions', 'cities', 'villages']) {
    for (final item in (data[key] as List)) {
      final map = item as Map<String, dynamic>;
      final before = map.containsKey('name_ru');
      fillNames(map);
      if (!before) filled++;
    }
  }

  const encoder = JsonEncoder.withIndent(null); // compact
  file.writeAsStringSync(encoder.convert(data));

  stdout.writeln('Filled translations for $filled entries.');
  if (unmapped.isNotEmpty) {
    stdout.writeln('WARNING — unmapped Latin characters: $unmapped');
  } else {
    stdout.writeln('All characters mapped cleanly.');
  }
  // Show a few samples for eyeballing
  final villages = data['villages'] as List;
  for (final v in villages.take(5)) {
    stdout.writeln('${v['name']} -> ${v['name_ru']}');
  }
}
