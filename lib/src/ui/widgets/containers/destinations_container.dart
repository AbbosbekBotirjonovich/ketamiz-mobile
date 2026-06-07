import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../../model/api/trip_list_model.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/utils.dart';

class DestinationsContainer extends StatelessWidget {
  const DestinationsContainer({super.key, required this.trip});

  final TripListModel trip;

  String get _fromPlace {
    if (trip.fromCity.isNotEmpty) return trip.fromCity;
    if (trip.fromRegion.isNotEmpty) return trip.fromRegion;
    return trip.fromWhere;
  }

  String get _toPlace {
    if (trip.toCity.isNotEmpty) return trip.toCity;
    if (trip.toRegion.isNotEmpty) return trip.toRegion;
    return trip.toWhere;
  }

  Color get _seatsColor {
    if (trip.availableSeats <= 1) return AppTheme.red;
    if (trip.availableSeats <= 3) return AppTheme.yellow;
    return AppTheme.green;
  }

  String get _status => trip.status.toLowerCase();

  /// Seats only make sense while the trip can still be booked.
  bool get _isActive => _status.isEmpty || _status == 'active';

  Color get _statusColor {
    switch (_status) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'canceled':
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return AppTheme.purple;
    }
  }

  String get _statusText {
    switch (_status) {
      case 'active':
        return translate('history.active');
      case 'in_progress':
        return translate('history.in_progress');
      case 'completed':
        return translate('history.completed');
      case 'canceled':
      case 'cancelled':
        return translate('history.canceled');
      default:
        return trip.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
            color: AppTheme.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: status badge + seats badge (active only) + price ────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (trip.status.isNotEmpty) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 12,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Seats left — only while the trip is still bookable
              if (_isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _seatsColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${trip.availableSeats} ${translate("home.seats_left")}",
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
                    "${Utils.priceFormat(trip.pricePerSeat)} ${translate("currency")}",
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
          // ── Body row: timeline + driver ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Timeline dots
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
                      Utils.timeFormat(trip.startTime),
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _fromPlace,
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
                      Utils.timeFormat(trip.endTime),
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _toPlace,
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
              // Driver info
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 92,
                    child: Text(
                      trip.driver.name,
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
                  if (trip.vehicle.model.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_car_rounded,
                          color: AppTheme.gray,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 74),
                          child: Text(
                            trip.vehicle.model.toUpperCase(),
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
}
