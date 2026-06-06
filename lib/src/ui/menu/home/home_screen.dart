import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/bloc/home_bloc.dart';
import 'package:ketamiz/src/model/api/trip_list_model.dart';
import 'package:ketamiz/src/model/location_model.dart';
import 'package:ketamiz/src/ui/dialogs/bottom_dialog.dart';
import 'package:ketamiz/src/ui/dialogs/center_dialog.dart';
import 'package:ketamiz/src/ui/menu/home/search_result_screen.dart';
import 'package:ketamiz/src/ui/menu/home/trip_details_screen.dart';
import 'package:ketamiz/src/ui/widgets/containers/active_trips_container.dart';
import 'package:ketamiz/src/utils/nav_constants.dart';
import 'package:ketamiz/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

import '../../../bloc/profile_bloc.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/containers/destinations_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activeTripId = "0";
  String activeBookedId = "0";

  String _fromText = "";
  String _toText = "";

  LocationModel fromRegion = LocationModel(id: "0", text: "", parentID: '');
  LocationModel fromCity = LocationModel(id: "0", text: "", parentID: '');
  LocationModel fromNeighborhood =
      LocationModel(id: "0", text: "", parentID: '');

  LocationModel toRegion = LocationModel(id: "0", text: "", parentID: '');
  LocationModel toCity = LocationModel(id: "0", text: "", parentID: '');
  LocationModel toNeighborhood = LocationModel(id: "0", text: "", parentID: '');

  DateTime departureDate = DateTime.now();
  int passengerCount = 1;

  int notificationNumber = 0;

  @override
  void initState() {
    getActiveTripsId();
    blocHome.fetchTripList();
    blocProfile.fetchMe();
    super.initState();
  }

  Future<void> _onRefresh() async {
    blocHome.fetchTripList();
    blocProfile.fetchMe();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> getActiveTripsId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      activeTripId = prefs.getString('active_trip_id') ?? "0";
      activeBookedId = prefs.getString('active_booked_id') ?? "0";
    });
    if (activeTripId != "0") {
      blocHome.fetchOneDriverTrip(activeTripId);
    }
    if (activeBookedId != "0") {
      blocHome.fetchOneBookedTrip(activeBookedId);
    }
  }

  static int _asId(String id) => int.tryParse(id) ?? 0;

  // ── Pickers ─────────────────────────────────────────────────────────────

  void _pickFrom() {
    BottomDialog.showSelectLocation(
      context,
      fromRegion,
      fromCity,
      fromNeighborhood,
      (r, c, n) {
        setState(() {
          fromRegion = r;
          fromCity = c;
          fromNeighborhood = n;
          _fromText = [n.text, c.text, r.text]
              .where((s) => s.isNotEmpty)
              .join(', ');
        });
      },
    );
  }

  void _pickTo() {
    BottomDialog.showSelectLocation(
      context,
      toRegion,
      toCity,
      toNeighborhood,
      (r, c, n) {
        setState(() {
          toRegion = r;
          toCity = c;
          toNeighborhood = n;
          _toText =
              [n.text, c.text, r.text].where((s) => s.isNotEmpty).join(', ');
        });
      },
    );
  }

  void _swap() {
    setState(() {
      final tr = fromRegion;
      fromRegion = toRegion;
      toRegion = tr;
      final tc = fromCity;
      fromCity = toCity;
      toCity = tc;
      final tn = fromNeighborhood;
      fromNeighborhood = toNeighborhood;
      toNeighborhood = tn;
      final tt = _fromText;
      _fromText = _toText;
      _toText = tt;
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: departureDate.isBefore(now) ? now : departureDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.purple,
            onPrimary: Colors.white,
            onSurface: AppTheme.black,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(departureDate),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.purple,
            onPrimary: Colors.white,
            onSurface: AppTheme.black,
          ),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;
    setState(() {
      departureDate = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? departureDate.hour,
        time?.minute ?? departureDate.minute,
      );
    });
  }

  void _pickPassengers() {
    int temp = passengerCount;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                translate("home.number_passenger"),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontFamily,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stepperButton(
                    icon: Icons.remove_rounded,
                    enabled: temp > 1,
                    onTap: () => setSheetState(() => temp--),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      temp.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                  _stepperButton(
                    icon: Icons.add_rounded,
                    enabled: temp < 4,
                    onTap: () => setSheetState(() => temp++),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => passengerCount = temp);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.purple,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    translate("home.apply"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.purple.withOpacity(0.1)
              : AppTheme.light,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled ? AppTheme.purple : AppTheme.gray,
          size: 22,
        ),
      ),
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────

  void _search() {
    if (fromRegion.id == "0" || toRegion.id == "0") {
      CenterDialog.showActionFailed(
        context,
        translate("home.missing_form"),
        translate("home.trip_search_error"),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(
          trip: TripListModel(
            id: 1,
            fromWhere: _fromText,
            toWhere: _toText,
            fromRegionId: _asId(fromRegion.id),
            toRegionId: _asId(toRegion.id),
            fromCityId: _asId(fromCity.id),
            toCityId: _asId(toCity.id),
            fromVillageId: _asId(fromNeighborhood.id),
            toVillageId: _asId(toNeighborhood.id),
            startTime: departureDate,
            endTime: departureDate,
            pricePerSeat: "",
            totalSeats: 0,
            availableSeats: 0,
            startLat: "",
            startLong: "",
            endLat: "",
            endLong: "",
            status: "",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            driver: TripDriver(id: 0, name: "", role: "driver"),
            vehicle: TripVehicle(
              id: 0,
              model: "",
              seats: 0,
              carNumber: "",
              color: CarColor(
                id: 0,
                titleUz: "",
                titleRu: "",
                titleEn: "",
                code: "",
              ),
            ),
          ),
          isRoundTrip: false,
          requiredSeats: passengerCount,
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppTheme.purple,
          onRefresh: _onRefresh,
          child: ListView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: kNavBarTotalPadding,
            ),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchCard(),
              const SizedBox(height: 24),
              if (activeBookedId != "0") _buildActiveTrip(),
              _buildRecommendedTrips(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          translate("home.title"),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontFamily,
            color: AppTheme.black,
          ),
        ),
        const Spacer(),
        Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppTheme.black,
                size: 24,
              ),
            ),
            if (notificationNumber > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.purple,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 20,
            spreadRadius: 0,
            color: AppTheme.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── From / To group ──────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Column(
                  children: [
                    _locationField(
                      hint: translate("home.from"),
                      value: _fromText,
                      onTap: _pickFrom,
                      leading: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border:
                              Border.all(color: AppTheme.purple, width: 2),
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 44, right: 16),
                      color: AppTheme.border,
                    ),
                    _locationField(
                      hint: translate("home.to"),
                      value: _toText,
                      onTap: _pickTo,
                      leading: const Icon(
                        Icons.location_on_rounded,
                        color: AppTheme.purple,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                // Swap button
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: _swap,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.border),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                            color: AppTheme.black.withOpacity(0.06),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.swap_vert_rounded,
                        color: AppTheme.purple,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ── Date + passengers row ────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _selectorChip(
                      icon: Icons.calendar_today_outlined,
                      label: Utils.searchDateFormat(departureDate),
                      onTap: _pickDateTime,
                    ),
                  ),
                  Container(width: 1, color: AppTheme.border),
                  Expanded(
                    flex: 2,
                    child: _selectorChip(
                      icon: Icons.person_outline_rounded,
                      label:
                          "$passengerCount ${translate(passengerCount == 1 ? "home.passenger" : "home.passengers")}",
                      onTap: _pickPassengers,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ── Search button ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _search,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purple,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    translate("home.find_trip"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationField({
    required String hint,
    required String value,
    required VoidCallback onTap,
    required Widget leading,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            SizedBox(width: 16, child: Center(child: leading)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value.isNotEmpty ? value : hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: value.isNotEmpty ? AppTheme.black : AppTheme.text,
                  fontSize: 15,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight:
                      value.isNotEmpty ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            // Reserve space so text never sits under the swap button.
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _selectorChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.dark, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.black,
                  fontSize: 13,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate("home.my_active_trips"),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
            color: AppTheme.black,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<TripListModel>(
          stream: blocHome.getOneBookedTrip,
          builder: (context, AsyncSnapshot<TripListModel> snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            return ActiveTripsContainer(trip: snapshot.data!);
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRecommendedTrips() {
    return StreamBuilder(
      stream: blocHome.getTrips,
      builder: (context, AsyncSnapshot<List<TripListModel>> snapshot) {
        if (!snapshot.hasData) return _buildShimmer();

        final trips = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    translate("home.recommended_trips"),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTheme.fontFamily,
                      color: AppTheme.black,
                    ),
                  ),
                ),
                Text(
                  translate("home.view_all"),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.purple,
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (trips.isEmpty)
              Column(
                children: [
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: Lottie.asset(
                      "assets/lottie/empty.json",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      translate("ketamiz.No_trip_found"),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.gray,
                      ),
                    ),
                  ),
                ],
              )
            else
              ...List.generate(
                trips.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                      bottom: index == trips.length - 1 ? 0 : 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TripDetailsScreen(trip: trips[index]),
                        ),
                      );
                    },
                    child: DestinationsContainer(trip: trips[index]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.baseColor,
      highlightColor: AppTheme.highlightColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 22,
                width: 180,
                decoration: BoxDecoration(
                  color: AppTheme.baseColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                height: 14,
                width: 40,
                decoration: BoxDecoration(
                  color: AppTheme.baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  color: AppTheme.baseColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
