import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/model/api/trip_list_model.dart';
import '../../../theme/app_theme.dart';

class ActiveTripsContainer extends StatelessWidget {
  const ActiveTripsContainer({super.key, required this.trip});
  final TripListModel trip;

  String _weekDay(int weekday) {
    const keys = ['', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return translate(keys[weekday]);
  }

  String _month(int month) {
    const keys = ['', 'january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'];
    return translate(keys[month]);
  }

  String _formatTime(DateTime time) {
    final h = time.hour < 13 ? time.hour : (time.hour - 12);
    final m = time.minute < 10 ? '0${time.minute}' : '${time.minute}';
    final period = time.hour < 13 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final t1 = trip.startTime;
    final t2 = trip.endTime;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.purple,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 0),
            blurRadius: 25,
            spreadRadius: 0,
            color: AppTheme.purple.withOpacity(0.45),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Text(
              '${_formatTime(t1)} - ${_formatTime(t2)}',
              style: const TextStyle(
                color: Colors.white,
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
                color: AppTheme.light,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              '${_weekDay(t1.weekday)}, ${_month(t1.month)} ${t1.day}',
              style: const TextStyle(
                color: AppTheme.light,
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
                    color: AppTheme.light,
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
                        color: AppTheme.light,
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
                    Colors.white,
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
                    trip.fromWhere,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    trip.toWhere,
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
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      height: 24,
                      "assets/icons/car.svg",
                      colorFilter: const ColorFilter.mode(
                        AppTheme.purple,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  trip.vehicle.model,
                  style: const TextStyle(
                    color: AppTheme.light,
                    fontSize: 12,
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
