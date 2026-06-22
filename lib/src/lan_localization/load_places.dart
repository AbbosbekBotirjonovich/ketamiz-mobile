import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/event_bus/http_result.dart';
import '../model/location_model.dart';
import '../resources/repository.dart';

class LocationData {
  static List<LocationModel> regions = [];
  static List<LocationModel> cities = [];
  static List<LocationModel> villages = [];
  static Map<String, dynamic>? _cachedJson;

  // ── Backend-driven places ────────────────────────────────────────────────
  // The location pickers fetch regions/districts/quarters live from the
  // backend so the IDs (and exact names) sent to the trip search match the
  // server's data exactly. Results are cached per session; region/district
  // caches are keyed by language since those names are localized (quarter
  // names are not). Caches survive a language switch by including the lang key.
  static final Repository _repo = Repository();
  static final Map<String, List<LocationModel>> _regionCache = {};
  static final Map<String, List<LocationModel>> _districtCache = {};
  static final Map<String, List<LocationModel>> _quarterCache = {};

  static Future<String> _nameKey() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'uz';
    return lang == 'en'
        ? 'name_en'
        : lang == 'ru'
            ? 'name_ru'
            : 'name_uz';
  }

  /// The backend place endpoints return bare JSON arrays; [_processResponse]
  /// wraps non-Map bodies as `{"data": [...]}`, so handle both shapes.
  static List<dynamic> _extractList(HttpResult res) {
    final r = res.result;
    if (r is List) return r;
    if (r is Map && r['data'] is List) return List<dynamic>.from(r['data']);
    return const [];
  }

  static LocationModel _place(Map e, String nameKey, String parentId) {
    return LocationModel(
      id: e['id'].toString(),
      text: (e[nameKey] ?? e['name_uz'] ?? e['name'] ?? '').toString(),
      parentID: parentId,
    );
  }

  /// All regions, localized to the current language.
  static Future<List<LocationModel>> fetchRegions() async {
    final nameKey = await _nameKey();
    final cached = _regionCache[nameKey];
    if (cached != null) return cached;
    final res = await _repo.fetchRegions();
    if (!res.isSuccess) return const [];
    final list = _extractList(res)
        .whereType<Map>()
        .map((e) => _place(e, nameKey, '0'))
        .toList();
    _regionCache[nameKey] = list;
    return list;
  }

  /// Districts for [regionId], localized to the current language.
  static Future<List<LocationModel>> fetchDistricts(String regionId) async {
    final nameKey = await _nameKey();
    final key = '$nameKey:$regionId';
    final cached = _districtCache[key];
    if (cached != null) return cached;
    final res = await _repo.fetchDistricts(regionId);
    if (!res.isSuccess) return const [];
    final list = _extractList(res)
        .whereType<Map>()
        .map((e) => _place(e, nameKey, regionId))
        .toList();
    _districtCache[key] = list;
    return list;
  }

  /// Quarters (neighborhoods) for [districtId]. The backend only returns a
  /// single `name` field for quarters (not localized).
  static Future<List<LocationModel>> fetchQuarters(String districtId) async {
    final cached = _quarterCache[districtId];
    if (cached != null) return cached;
    final res = await _repo.fetchQuarters(districtId);
    if (!res.isSuccess) return const [];
    final list = _extractList(res)
        .whereType<Map>()
        .map((e) => _place(e, 'name', districtId))
        .toList();
    _quarterCache[districtId] = list;
    return list;
  }

  static LocationModel _build(Map<String, dynamic> json, String nameKey) {
    return LocationModel(
      id: json['id'].toString(),
      text: json[nameKey]?.toString() ??
          json['name_uz']?.toString() ??
          json['name']?.toString() ??
          '',
      parentID: json['region_id']?.toString() ??
          json['district_id']?.toString() ??
          '0',
    );
  }

  static Future<void> loadPlaces(BuildContext context) async {
    try {
      if (_cachedJson == null) {
        final String jsonString = await DefaultAssetBundle.of(context)
            .loadString('assets/places.json');
        _cachedJson = jsonDecode(jsonString);
      }

      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('language') ?? 'uz';
      final nameKey = lang == 'en'
          ? 'name_en'
          : lang == 'ru'
              ? 'name_ru'
              : 'name_uz';

      regions = (_cachedJson!['regions'] as List<dynamic>)
          .map((r) => _build(Map<String, dynamic>.from(r), nameKey))
          .toList();
      cities = (_cachedJson!['cities'] as List<dynamic>)
          .map((c) => _build(Map<String, dynamic>.from(c), nameKey))
          .toList();
      villages = (_cachedJson!['villages'] as List<dynamic>)
          .map((v) => _build(Map<String, dynamic>.from(v), nameKey))
          .toList();

      debugPrint('Locations loaded: ${regions.length} regions, ${cities.length} cities, ${villages.length} villages');
    } catch (e) {
      debugPrint('Error loading places.json: $e');
    }
  }
}
