import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:ketamiz/src/theme/app_theme.dart';
import 'package:ketamiz/src/ui/widgets/buttons/primary_button.dart';
import 'package:ketamiz/src/ui/widgets/containers/leading_back.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_16h_500w.dart';
import 'package:latlong2/latlong.dart';

/// Tap-to-pick a location on a free OpenStreetMap (Leaflet-style) map.
class MapSelectScreen extends StatefulWidget {
  final String place;
  final Function(LatLng position) onSelected;

  const MapSelectScreen({
    super.key,
    required this.place,
    required this.onSelected,
  });

  @override
  State<MapSelectScreen> createState() => _MapSelectScreenState();
}

class _MapSelectScreenState extends State<MapSelectScreen> {
  final MapController _mapController = MapController();

  LatLng? _selectedLocation;
  // Default to Tashkent — the map renders here immediately, then recenters
  // once (and if) geocoding of the typed address resolves.
  static const LatLng _defaultPosition = LatLng(41.2995, 69.2401);

  @override
  void initState() {
    super.initState();
    // Run geocoding in the background — never block the map on it. The
    // platform geocoder can be slow or hang, which previously left the
    // screen stuck on a spinner with no map to tap.
    _resolveAddress();
  }

  Future<void> _resolveAddress() async {
    final place = widget.place.trim();
    if (place.isEmpty) return;

    // Address variants, most specific to least specific.
    final variants = <String>[];
    if (!place.toLowerCase().contains('uzbekistan')) {
      variants.add('$place, Uzbekistan');
    }
    variants.add(place);

    final parts = place
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length > 2) {
      final shorter = '${parts[parts.length - 2]}, ${parts.last}';
      if (!shorter.toLowerCase().contains('uzbekistan')) {
        variants.add('$shorter, Uzbekistan');
      }
      variants.add(shorter);
    }
    if (parts.isNotEmpty) {
      final last = parts.last;
      if (!last.toLowerCase().contains('uzbekistan')) {
        variants.add('$last, Uzbekistan');
      }
      variants.add(last);
    }

    for (final variant in variants.toSet()) {
      try {
        // Guard against the platform geocoder hanging.
        final locations = await locationFromAddress(variant)
            .timeout(const Duration(seconds: 6));
        if (locations.isNotEmpty) {
          final target =
              LatLng(locations.first.latitude, locations.first.longitude);
          if (!mounted) return;
          // Recenter without dropping a pin — the user still picks the
          // exact spot by tapping.
          _mapController.move(target, 14);
          return;
        }
      } catch (e) {
        debugPrint('Geocoding failed for "$variant": $e');
      }
    }
    debugPrint('No geocoding result for "${widget.place}". Using default.');
  }

  void _onMapTap(LatLng position) {
    setState(() => _selectedLocation = position);
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      widget.onSelected(_selectedLocation!);
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate("ketamiz.select_location_hint"))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("ketamiz.select_location")),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultPosition,
              initialZoom: 13,
              onTap: (tapPosition, latLng) => _onMapTap(latLng),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'uz.ketamiz.app',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.red,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              const SimpleAttributionWidget(
                source: Text('OpenStreetMap contributors'),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 32,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(top: 22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: AppTheme.black),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 15,
                      blurRadius: 25,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _selectedLocation == null
                          ? Icons.touch_app_outlined
                          : Icons.location_on,
                      color: AppTheme.purple,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedLocation == null
                            ? translate("ketamiz.select_location_hint")
                            : (widget.place.isEmpty
                                ? translate("ketamiz.select_location")
                                : widget.place),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                          color: AppTheme.black,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 32,
                  left: 16,
                  right: 16,
                ),
                child: GestureDetector(
                  onTap: _confirmSelection,
                  child: PrimaryButton(
                    title: translate("ketamiz.confirm_location"),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
