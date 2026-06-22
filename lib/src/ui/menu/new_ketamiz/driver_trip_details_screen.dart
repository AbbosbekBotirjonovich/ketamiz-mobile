import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:latlong2/latlong.dart';
import 'package:ketamiz/src/model/api/driver_trips_list_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ketamiz/src/model/passenger_info_model.dart';
import 'package:ketamiz/src/ui/menu/home/map_single_screen.dart';
import 'package:ketamiz/src/ui/menu/profile/terms_screen.dart';
import 'package:ketamiz/src/ui/widgets/containers/leading_back.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_14h_400w.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_16h_500w.dart';
import 'package:ketamiz/src/utils/utils.dart';
import '../../../theme/app_theme.dart';
import '../home/map_route_screen.dart';

class DriverTripDetailsScreen extends StatefulWidget {
  const DriverTripDetailsScreen({
    super.key,
    required this.trip,
  });

  final DriverTripModel trip;

  @override
  State<DriverTripDetailsScreen> createState() =>
      _DriverTripDetailsScreenState();
}

class _DriverTripDetailsScreenState extends State<DriverTripDetailsScreen> {
  String pricePerSeat = "";

  String from = '';
  String to = '';

  String fromRegion = "";
  String fromCity = "";
  String fromNeighborhood = "";
  String toRegion = "";
  String toCity = "";
  String toNeighborhood = "";

  List<PassengerInfoModel> passengersList = [];

  @override
  void initState() {
    super.initState();
    final p = widget.trip.pricePerSeat;
    pricePerSeat = p.contains(".") ? p.split(".")[0] : p;
    _setLocations();
    _loadPassengers();
  }

  void _setLocations() {
    final t = widget.trip;
    fromRegion = t.fromRegion;
    fromCity = t.fromCity;
    fromNeighborhood = t.fromVillage;
    toRegion = t.toRegion;
    toCity = t.toCity;
    toNeighborhood = t.toVillage;

    from = [fromNeighborhood, fromCity, fromRegion]
        .where((s) => s.isNotEmpty)
        .join(", ");
    to = [toNeighborhood, toCity, toRegion]
        .where((s) => s.isNotEmpty)
        .join(", ");
  }

  void _loadPassengers() {
    final bookings = widget.trip.bookings;
    if (bookings.isNotEmpty) {
      passengersList = bookings
          .whereType<Map<String, dynamic>>()
          .map((b) => PassengerInfoModel(
                fullName: b['name']?.toString() ?? '',
                phone: b['phone']?.toString() ?? '',
                numberOfSeats: (b['seats'] as int?) ?? 1,
              ))
          .toList();
    }
  }

  Color get _seatsColor {
    final s = widget.trip.availableSeats;
    if (s <= 1) return AppTheme.red;
    if (s <= 3) return AppTheme.yellow;
    return AppTheme.green;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in_progress':
        return AppTheme.purple;
      case 'completed':
        return AppTheme.green;
      case 'canceled':
      case 'cancelled':
        return AppTheme.red;
      default:
        return AppTheme.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("home.trip_details")),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                _buildRouteCard(),
                const SizedBox(height: 16),
                _buildDetailsCard(),
                const SizedBox(height: 16),
                _buildPassengersCard(),
                const SizedBox(height: 16),
                _buildCancelInfoCard(),
                const SizedBox(height: 12),
                _buildDriverTermsButton(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Route hero card ────────────────────────────────────────────────────────
  Widget _buildRouteCard() {
    final statusColor = _statusColor(widget.trip.status);
    final vehicleModel = widget.trip.vehicle.model;
    final vehicleNumber = widget.trip.vehicle.carNumber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 16,
            color: AppTheme.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge + price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.trip.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${Utils.priceFormat(pricePerSeat)} ${translate("currency")}",
                    style: const TextStyle(
                      color: AppTheme.black,
                      fontSize: 17,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    translate("home.per_passenger"),
                    style: const TextStyle(
                      color: AppTheme.gray,
                      fontSize: 11,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Timeline + places + vehicle block
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Vertical timeline
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppTheme.purple, width: 2),
                    ),
                  ),
                  ...List.generate(
                    4,
                    (_) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      width: 2,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.border,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Times + places
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Utils.timeFormat(widget.trip.startTime),
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      from.isEmpty ? "—" : from,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.dark,
                        fontSize: 13,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Utils.timeFormat(widget.trip.endTime),
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      to.isEmpty ? "—" : to,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.dark,
                        fontSize: 13,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Vehicle block
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: AppTheme.purple,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _seatsColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${widget.trip.availableSeats} ${translate("home.seats_left")}",
                      style: TextStyle(
                        color: _seatsColor,
                        fontSize: 11,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (vehicleModel.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 88),
                      child: Text(
                        vehicleModel.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.gray,
                          fontSize: 11,
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                  if (vehicleNumber.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 88),
                      child: Text(
                        vehicleNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.gray,
                          fontSize: 10,
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Details card ───────────────────────────────────────────────────────────
  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 16,
            color: AppTheme.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text16h500w(title: translate("home.details")),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.radio_button_checked_rounded,
            iconColor: AppTheme.purple,
            label: translate("home.travelling_from"),
            child: Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      from.isEmpty ? "—" : from,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _mapPinButton(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapSingleScreen(
                          location: LatLng(
                            double.parse(widget.trip.startLat),
                            double.parse(widget.trip.startLong),
                          ),
                          place: from,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          _divider(),
          _infoRow(
            icon: Icons.location_on_rounded,
            iconColor: AppTheme.red,
            label: translate("home.where_to"),
            child: Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      to.isEmpty ? "—" : to,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _mapPinButton(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapSingleScreen(
                          location: LatLng(
                            double.parse(widget.trip.endLat),
                            double.parse(widget.trip.endLong),
                          ),
                          place: to,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          _divider(),
          _infoRow(
            icon: Icons.calendar_today_rounded,
            iconColor: AppTheme.purple,
            label: translate("home.departure_date"),
            valueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Utils.searchDateFormat(widget.trip.startTime),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.gray,
                  ),
                ),
                Text(
                  Utils.timeFormat(widget.trip.startTime),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          _infoRow(
            icon: Icons.flag_rounded,
            iconColor: AppTheme.green,
            label: translate("home.arrival_date"),
            valueWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Utils.searchDateFormat(widget.trip.endTime),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.gray,
                  ),
                ),
                Text(
                  Utils.timeFormat(widget.trip.endTime),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          Row(
            children: [
              Expanded(
                child: _infoRow(
                  icon: Icons.event_seat_rounded,
                  iconColor: _seatsColor,
                  label: translate("home.available_seats"),
                  value: "${widget.trip.availableSeats}",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoRow(
                  icon: Icons.payments_rounded,
                  iconColor: AppTheme.purple,
                  label: translate("home.price_per_seat"),
                  value:
                      "${Utils.priceFormat(pricePerSeat)} ${translate("currency")}",
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _routeMapButton(),
          if (widget.trip.googleMapUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            _OpenInMapsButton(url: widget.trip.googleMapUrl),
          ],
        ],
      ),
    );
  }

  // ── Passengers card ────────────────────────────────────────────────────────
  Widget _buildPassengersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 16,
            color: AppTheme.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text16h500w(title: translate("home.passenger_info"))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${passengersList.length}",
                  style: const TextStyle(
                    color: AppTheme.purple,
                    fontSize: 13,
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (passengersList.isEmpty) ...[
            const SizedBox(height: 16),
            Center(
              child: Text14h400w(
                title: translate("home.no_passenger"),
                color: AppTheme.gray,
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...passengersList.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;
              return Column(
                children: [
                  if (i > 0) const Divider(height: 1, color: AppTheme.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.purple.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppTheme.purple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.fullName.isNotEmpty ? p.fullName : "—",
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.black,
                                ),
                              ),
                              if (p.phone.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  p.phone,
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    color: AppTheme.gray,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (p.numberOfSeats > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.border,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${p.numberOfSeats}x",
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.dark,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  // ── Cancel info card ───────────────────────────────────────────────────────
  Widget _buildCancelInfoCard() {
    final deadline =
        widget.trip.startTime.subtract(const Duration(minutes: 30));
    final deadlineStr = Utils.searchDateFormat(deadline);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.yellow.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.yellow.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppTheme.yellow, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              translate("ketamiz.cancel_info_msg", args: {"time": deadlineStr}),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: AppTheme.dark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Driver terms link ──────────────────────────────────────────────────────
  Widget _buildDriverTermsButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TermsScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppTheme.purple.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.purple.withValues(alpha: 0.18), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article_outlined,
                color: AppTheme.purple, size: 16),
            const SizedBox(width: 8),
            Text(
              translate("ketamiz.driver_terms"),
              style: const TextStyle(
                color: AppTheme.purple,
                fontSize: 13,
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 16,
            color: AppTheme.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 1.5),
        ),
        child: Center(
          child: Text(
            translate("ketamiz.edit_trip"),
            style: const TextStyle(
              color: AppTheme.dark,
              fontSize: 15,
              fontFamily: AppTheme.fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? value,
    Widget? valueWidget,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: AppTheme.gray,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (child != null) ...[const SizedBox(width: 8), child],
          if (valueWidget != null) ...[const Spacer(), valueWidget],
          if (value != null) ...[
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.black,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppTheme.border);

  Widget _mapPinButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.light,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: SvgPicture.asset(
          "assets/icons/map_pin.svg",
          colorFilter:
              const ColorFilter.mode(AppTheme.purple, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _routeMapButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MapRouteScreen(
              start: LatLng(double.parse(widget.trip.startLat),
                  double.parse(widget.trip.startLong)),
              end: LatLng(double.parse(widget.trip.endLat),
                  double.parse(widget.trip.endLong)),
              startText: from,
              endText: to,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppTheme.purple.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.purple.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.route_rounded, color: AppTheme.purple, size: 18),
            const SizedBox(width: 8),
            Text(
              translate("home.view_route_map"),
              style: const TextStyle(
                color: AppTheme.purple,
                fontSize: 14,
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenInMapsButton extends StatelessWidget {
  const _OpenInMapsButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          // No handler for external launch — fall back to in-app browser.
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF4285F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              translate("home.open_in_google_maps"),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
