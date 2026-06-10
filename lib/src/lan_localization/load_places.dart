import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/location_model.dart';

class LocationData {
  static List<LocationModel> regions = [];
  static List<LocationModel> cities = [];
  static List<LocationModel> villages = [];
  static Map<String, dynamic>? _cachedJson;

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
