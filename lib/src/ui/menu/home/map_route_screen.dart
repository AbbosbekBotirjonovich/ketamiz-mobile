import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../theme/app_theme.dart';
import '../../widgets/buttons/primary_button.dart';

/// Route between two points on a free OpenStreetMap (Leaflet-style) map.
/// Routing uses the public OSRM server; falls back to a straight line.
///
/// In [approximate] mode (client hasn't booked yet) the exact start/end are
/// hidden — only 1 km fully-opaque circles are drawn so the rough area is
/// visible but the precise pickup/drop-off points are not revealed.
class MapRouteScreen extends StatefulWidget {
  final LatLng start;
  final LatLng end;
  final String startText;
  final String endText;
  final bool approximate;

  const MapRouteScreen({
    super.key,
    required this.start,
    required this.end,
    required this.startText,
    required this.endText,
    this.approximate = false,
  });

  @override
  State<MapRouteScreen> createState() => _MapRouteScreenState();
}

class _MapRouteScreenState extends State<MapRouteScreen> {
  // Radius (metres) of the privacy circle drawn around unbooked trips.
  static const double _approxRadiusMeters = 1000;

  List<LatLng> _routePoints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Route is fetched in both modes — circles obscure exact points in approximate mode.
    _routePoints = [widget.start, widget.end];
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final s = widget.start;
    final e = widget.end;
    // Skip routing for clearly invalid coordinates (0,0 or identical points) —
    // otherwise OSRM returns no route and we'd draw a bogus straight line.
    final invalid = (s.latitude == 0 && s.longitude == 0) ||
        (e.latitude == 0 && e.longitude == 0) ||
        (s.latitude == e.latitude && s.longitude == e.longitude);
    if (invalid) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    // GeoJSON geometry returns coordinates directly ([lon, lat] pairs), which
    // avoids any polyline-decoding mismatch.
    final url = 'https://router.project-osrm.org/route/v1/driving/'
        '${s.longitude},${s.latitude};${e.longitude},${e.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: const {'User-Agent': 'uz.ketamiz.app'},
      ).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && (data['routes'] as List).isNotEmpty) {
          final coords =
              data['routes'][0]['geometry']['coordinates'] as List;
          final decoded = coords
              .map((c) => LatLng(
                    (c[1] as num).toDouble(),
                    (c[0] as num).toDouble(),
                  ))
              .toList();
          if (decoded.length >= 2 && mounted) {
            setState(() => _routePoints = decoded);
          }
        }
      } else {
        debugPrint('OSRM route failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('OSRM route error: $e');
    }
    if (mounted) setState(() => isLoading = false);
  }

  /// Bounds that include the full 1 km circles when in approximate mode,
  /// so neither circle is clipped at the screen edge.
  LatLngBounds get _cameraBounds {
    if (!widget.approximate) {
      return LatLngBounds(widget.start, widget.end);
    }
    // ~0.02° latitude ≈ 2 km — enough padding to show the ~1 km circles.
    const pad = 0.02;
    final lats = [widget.start.latitude, widget.end.latitude];
    final lngs = [widget.start.longitude, widget.end.longitude];
    return LatLngBounds(
      LatLng(lats.reduce((a, b) => a < b ? a : b) - pad,
          lngs.reduce((a, b) => a < b ? a : b) - pad),
      LatLng(lats.reduce((a, b) => a > b ? a : b) + pad,
          lngs.reduce((a, b) => a > b ? a : b) + pad),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: _cameraBounds,
                padding: const EdgeInsets.fromLTRB(48, 230, 48, 140),
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'uz.ketamiz.app',
              ),
              // Route line — always drawn; circles cover exact endpoints in approximate mode.
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: AppTheme.purple,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              if (widget.approximate)
                // Two-layer privacy circles: opaque white base erases the
                // map tiles and route line beneath; colored layer on top
                // gives the visual approximate-area indicator.
                CircleLayer(
                  circles: [
                    // White base — start
                    CircleMarker(
                      point: widget.start,
                      radius: _approxRadiusMeters,
                      useRadiusInMeter: true,
                      color: Colors.white,
                      borderColor: Colors.transparent,
                      borderStrokeWidth: 0,
                    ),
                    // Colored indicator — start
                    CircleMarker(
                      point: widget.start,
                      radius: _approxRadiusMeters,
                      useRadiusInMeter: true,
                      color: AppTheme.green.withOpacity(0.22),
                      borderColor: AppTheme.green.withOpacity(0.7),
                      borderStrokeWidth: 2,
                    ),
                    // White base — end
                    CircleMarker(
                      point: widget.end,
                      radius: _approxRadiusMeters,
                      useRadiusInMeter: true,
                      color: Colors.white,
                      borderColor: Colors.transparent,
                      borderStrokeWidth: 0,
                    ),
                    // Colored indicator — end
                    CircleMarker(
                      point: widget.end,
                      radius: _approxRadiusMeters,
                      useRadiusInMeter: true,
                      color: AppTheme.red.withOpacity(0.22),
                      borderColor: AppTheme.red.withOpacity(0.7),
                      borderStrokeWidth: 2,
                    ),
                  ],
                )
              else
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.start,
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.green,
                        size: 40,
                      ),
                    ),
                    Marker(
                      point: widget.end,
                      width: 40,
                      height: 40,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.red,
                        size: 40,
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
              const SizedBox(height: 52),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.radio_button_checked_rounded,
                        color: AppTheme.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.startText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: AppTheme.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.endText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (widget.approximate)
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.red.withOpacity(0.3), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: AppTheme.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          translate("home.approximate_location_note"),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            color: AppTheme.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 32,
                  left: 16,
                  right: 16,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const PrimaryButton(title: "OK"),
                ),
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 5),
                      blurRadius: 25,
                      spreadRadius: 0,
                      color: Colors.black.withOpacity(0.05),
                    ),
                  ],
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.purple),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
