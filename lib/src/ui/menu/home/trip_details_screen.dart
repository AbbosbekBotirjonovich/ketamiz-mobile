import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ketamiz/src/ui/dialogs/bottom_dialog.dart';
import 'package:ketamiz/src/ui/dialogs/center_dialog.dart';
import 'package:ketamiz/src/ui/menu/home/map_single_screen.dart';
import 'package:ketamiz/src/ui/menu/home/payment_screen.dart';
import 'package:ketamiz/src/ui/menu/main_screen.dart';
import 'package:ketamiz/src/ui/widgets/containers/leading_back.dart';
import 'package:ketamiz/src/ui/widgets/containers/passengers_container.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_14h_400w.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_16h_500w.dart';
import 'package:ketamiz/src/utils/utils.dart';
import '../../../lan_localization/load_places.dart';
import '../../../model/api/trip_list_model.dart';
import '../../../model/location_model.dart';
import '../../../model/passenger_model.dart';
import '../../../resources/repository.dart';
import '../../../theme/app_theme.dart';
import '../../dialogs/snack_bar.dart';
import 'map_route_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({
    super.key,
    required this.trip,
    this.isDriver = false,
  });

  final TripListModel trip;
  final bool isDriver;

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  static final _unknownLocation =
      LocationModel(id: "0", text: "—", parentID: "0");

  String pricePerSeat = "";
  int passengersNum = 1;

  String from = '';
  String to = '';

  String fromRegion = "";
  String fromCity = "";
  String fromNeighborhood = "";
  String toRegion = "";
  String toCity = "";
  String toNeighborhood = "";

  List<PassengerModel> passengers = [];
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    final p = widget.trip.pricePerSeat;
    pricePerSeat = p.contains(".") ? p.split(".")[0] : p;
    setLocations();
    _initFirstPassenger();
  }

  Future<void> _initFirstPassenger() async {
    final user = await Repository().appCache.cacheGetMe();
    if (!mounted) return;
    setState(() {
      passengers = [
        PassengerModel(
          fullName: "${user.firstName} ${user.lastName}".trim(),
          phoneNumber: user.phone,
        ),
      ];
    });
  }

  Future<void> setLocations() async {
    final trip = widget.trip;

    if (trip.fromRegion.isNotEmpty ||
        trip.fromCity.isNotEmpty ||
        trip.fromVillage.isNotEmpty) {
      fromRegion = trip.fromRegion;
      fromCity = trip.fromCity;
      fromNeighborhood = trip.fromVillage;
      toRegion = trip.toRegion;
      toCity = trip.toCity;
      toNeighborhood = trip.toVillage;
    } else {
      if (LocationData.regions.isEmpty) {
        await LocationData.loadPlaces(context);
      }
      fromRegion = LocationData.regions
          .firstWhere((r) => r.id == trip.fromRegionId.toString(),
              orElse: () => _unknownLocation)
          .text;
      fromCity = LocationData.cities
          .firstWhere((c) => c.id == trip.fromCityId.toString(),
              orElse: () => _unknownLocation)
          .text;
      fromNeighborhood = LocationData.villages
          .firstWhere((n) => n.id == trip.fromVillageId.toString(),
              orElse: () => _unknownLocation)
          .text;
      toRegion = LocationData.regions
          .firstWhere((r) => r.id == trip.toRegionId.toString(),
              orElse: () => _unknownLocation)
          .text;
      toCity = LocationData.cities
          .firstWhere((c) => c.id == trip.toCityId.toString(),
              orElse: () => _unknownLocation)
          .text;
      toNeighborhood = LocationData.villages
          .firstWhere((n) => n.id == trip.toVillageId.toString(),
              orElse: () => _unknownLocation)
          .text;
    }

    if (!mounted) return;
    setState(() {
      from = [fromNeighborhood, fromCity, fromRegion]
          .where((s) => s.isNotEmpty && s != "—")
          .join(", ");
      to = [toNeighborhood, toCity, toRegion]
          .where((s) => s.isNotEmpty && s != "—")
          .join(", ");
    });
  }

  Color get _seatsColor {
    final s = widget.trip.availableSeats;
    if (s <= 1) return AppTheme.red;
    if (s <= 3) return AppTheme.yellow;
    return AppTheme.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
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
                if (!widget.isDriver) ...[
                  const SizedBox(height: 16),
                  _buildPassengerCard(),
                ],
              ],
            ),
          ),
          widget.isDriver
              ? _buildDriverBottomBar()
              : _buildPassengerBottomBar(),
        ],
      ),
    );
  }

  // ── Route hero card ────────────────────────────────────────────────────────
  Widget _buildRouteCard() {
    final driverName = widget.trip.driver.name.trim();
    final vehicleModel = widget.trip.vehicle.model;

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
          // Seats badge + price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _seatsColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${widget.trip.availableSeats} ${translate("home.seats_left")}",
                  style: TextStyle(
                    color: _seatsColor,
                    fontSize: 12,
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
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
          // Timeline + places + driver block
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
              // Driver block
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
                      Icons.person_rounded,
                      color: AppTheme.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (driverName.isNotEmpty)
                    SizedBox(
                      width: 92,
                      child: Text(
                        driverName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.black,
                          fontSize: 12,
                          fontFamily: AppTheme.fontFamily,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (vehicleModel.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.directions_car_rounded,
                            size: 12, color: AppTheme.gray),
                        const SizedBox(width: 3),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 76),
                          child: Text(
                            vehicleModel.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                  value: "${Utils.priceFormat(pricePerSeat)} ${translate("currency")}",
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _routeMapButton(),
        ],
      ),
    );
  }

  // ── Passenger card (client view) ───────────────────────────────────────────
  Widget _buildPassengerCard() {
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
              Text(
                passengersNum.toString(),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.purple,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (passengersNum < widget.trip.availableSeats) {
                    BottomDialog.showAddPassenger(
                      context,
                      PassengerModel(fullName: ""),
                      (data) {
                        final exists = passengers
                            .any((p) => p.fullName == data.fullName);
                        if (!exists && data.fullName.isNotEmpty) {
                          setState(() {
                            passengers.add(data);
                            passengersNum++;
                          });
                        } else {
                          CenterDialog.showActionFailed(
                            context,
                            translate("home.passenger_exist"),
                            translate("home.passenger_exist_error"),
                          );
                        }
                      },
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.purple,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: passengers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => PassengersContainer(
              passenger: passengers[index],
              onEdit: (data) {
                if (data.fullName.isNotEmpty && data != passengers[index]) {
                  setState(() => passengers[index] = data);
                }
              },
              onDelete: () {
                if (passengers.length > 1) {
                  setState(() {
                    passengers.removeAt(index);
                    passengersNum--;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bars ────────────────────────────────────────────────────────────
  Widget _buildPassengerBottomBar() {
    final total = int.tryParse(pricePerSeat) ?? 0;
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
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text14h400w(
                title: translate("home.total_price"),
                color: AppTheme.gray,
              ),
              Text(
                "${Utils.priceFormat((total * passengersNum).toString())} ${translate("currency")}",
                style: const TextStyle(
                  color: AppTheme.black,
                  fontSize: 18,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      trip: widget.trip,
                      passengersNum: passengersNum,
                      passengers: passengers,
                    ),
                  ),
                );
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.purple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    translate("home.book_now"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverBottomBar() {
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
      child: GestureDetector(
        onTap: _isCancelling ? null : _cancelTrip,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.red, width: 1.5),
          ),
          child: Center(
            child: _isCancelling
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.red,
                    ),
                  )
                : Text(
                    translate("ketamiz.cancel_trip"),
                    style: const TextStyle(
                      color: AppTheme.red,
                      fontSize: 15,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _cancelTrip() async {
    CenterDialog.showConfirmation(
      context,
      translate("ketamiz.cancel_trip"),
      translate("ketamiz.cancel_trip_confirm"),
      onConfirm: () async {
        Navigator.pop(context);
        setState(() => _isCancelling = true);

        final response = await Repository()
            .fetchCancelDriverTrip(widget.trip.id.toString());

        if (!mounted) return;
        setState(() => _isCancelling = false);

        if (response.isSuccess) {
          CustomSnackBar()
              .showSnackBar(context, translate("ketamiz.trip_cancelled"), 1);
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else {
          CenterDialog.showActionFailed(
            context,
            translate("ketamiz.error"),
            translate("auth.something_went_wrong"),
          );
        }
      },
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
