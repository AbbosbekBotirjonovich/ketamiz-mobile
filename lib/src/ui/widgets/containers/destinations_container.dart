import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../../lan_localization/load_places.dart';
import '../../../model/api/trip_list_model.dart';
import '../../../model/location_model.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/utils.dart';

class DestinationsContainer extends StatelessWidget {
  const DestinationsContainer({super.key, required this.trip});

  final TripListModel trip;

  static const _weekDays = <int, String>{
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  static const _months = <int, String>{
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  @override
  Widget build(BuildContext context) {
    final time = trip.startTime;
    final weekDay = _weekDays[time.weekday] ?? 'Sunday';
    final month = _months[time.month] ?? 'December';
    final m1 =
        time.minute < 10 ? '0${time.minute}' : time.minute.toString();
    final t1 = time.hour < 12 ? 'AM' : 'PM';
    final hour12 = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    final h1 = hour12.toString();

    final unknown = LocationModel(id: "0", text: "—", parentID: "0");
    final fromVillage = LocationData.villages.firstWhere(
        (n) => n.id == trip.fromVillageId.toString(),
        orElse: () => unknown);
    final fromCityModel = LocationData.cities.firstWhere(
        (c) => c.id == trip.fromCityId.toString(),
        orElse: () => unknown);
    final fromRegion = LocationData.regions.firstWhere(
        (r) => r.id == trip.fromRegionId.toString(),
        orElse: () => unknown);
    final toVillage = LocationData.villages.firstWhere(
        (n) => n.id == trip.toVillageId.toString(),
        orElse: () => unknown);
    final toCityModel = LocationData.cities.firstWhere(
        (c) => c.id == trip.toCityId.toString(),
        orElse: () => unknown);
    final toRegion = LocationData.regions.firstWhere(
        (r) => r.id == trip.toRegionId.toString(),
        orElse: () => unknown);

    final from =
        "${fromVillage.text}, ${fromCityModel.text}, ${fromRegion.text}";
    final to = "${toVillage.text}, ${toCityModel.text}, ${toRegion.text}";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 25,
            spreadRadius: 0,
            color: AppTheme.dark.withOpacity(0.2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.light,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "${trip.availableSeats} ${translate("home.seats_available")}",
                      style: TextStyle(
                        color: trip.availableSeats == 1
                            ? AppTheme.red
                            : trip.availableSeats <= 3
                                ? AppTheme.yellow
                                : AppTheme.green,
                        fontSize: 12,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                "${Utils.priceFormat(trip.pricePerSeat)} ${translate("currency")}",
                style: const TextStyle(
                  color: AppTheme.black,
                  fontSize: 20,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "$h1:$m1 $t1",
                style: const TextStyle(
                  color: AppTheme.black,
                  fontSize: 14,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.black,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                "$weekDay, $month ${trip.startTime.day}",
                style: const TextStyle(
                  color: AppTheme.gray,
                  fontSize: 14,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.dark,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Column(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Container(
                          width: 2,
                          height: 8,
                          color: AppTheme.gray,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  SvgPicture.asset(
                    "assets/icons/map_pin.svg",
                    height: 24,
                    width: 24,
                    colorFilter: const ColorFilter.mode(
                      AppTheme.purple,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      from,
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      to,
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        height: 24,
                        "assets/icons/car.svg",
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trip.vehicle.model,
                    style: const TextStyle(
                      color: AppTheme.black,
                      fontSize: 12,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
