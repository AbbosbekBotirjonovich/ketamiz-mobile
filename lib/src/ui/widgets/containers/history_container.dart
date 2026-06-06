import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/model/api/book_model.dart';
import 'package:ketamiz/src/theme/app_theme.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_12h_400w.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_14h_500w.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_16h_500w.dart';
import 'package:ketamiz/src/utils/utils.dart';

class HistoryContainer extends StatelessWidget {
  const HistoryContainer({super.key, required this.booking});

  final BookModel booking;

  @override
  Widget build(BuildContext context) {
    final colorCode = booking.vehicle.color.colorCode;
    final vehicleColor = _parseColor(colorCode);

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
            color: AppTheme.dark.withOpacity(0.4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header: date + status ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text12h400w(
                  title: Utils.historyDateFormat(booking.trip.startTime),
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: _statusColor(booking.status),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text12h400w(
                  title: _statusText(booking.status),
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Route row ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text12h400w(
                      title: booking.trip.startRegion,
                      color: AppTheme.gray,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      safeSubstring(booking.trip.startQuarter, 3),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text12h400w(
                      title: booking.trip.startDistrict,
                      color: AppTheme.gray,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.dark,
                          shape: BoxShape.circle,
                        ),
                      ),
                      DottedLine(
                        direction: Axis.horizontal,
                        lineThickness: 2,
                        lineLength:
                            ((MediaQuery.of(context).size.width - 96) / 3 -
                                    40) /
                                2,
                        dashLength: 2,
                        dashColor: AppTheme.gray,
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.black,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: SvgPicture.asset(
                          "assets/icons/car.svg",
                          height: 24,
                          width: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      DottedLine(
                        direction: Axis.horizontal,
                        lineThickness: 2,
                        lineLength:
                            ((MediaQuery.of(context).size.width - 96) / 3 -
                                    40) /
                                2,
                        dashLength: 2,
                        dashColor: AppTheme.gray,
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.dark,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.vehicle.model,
                    style: const TextStyle(
                      color: AppTheme.gray,
                      fontSize: 12,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (vehicleColor != null)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: vehicleColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.gray.withOpacity(0.3),
                            ),
                          ),
                        ),
                      Text(
                        booking.vehicle.carNumber,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text12h400w(
                      title: booking.trip.endRegion,
                      color: AppTheme.gray,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      safeSubstring(booking.trip.endQuarter, 3),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text12h400w(
                      title: booking.trip.endDistrict,
                      color: AppTheme.gray,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          // ── Driver row ────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.black.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 18, color: AppTheme.dark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${booking.driver.firstName} ${booking.driver.lastName}'.trim(),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.black,
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.event_seat, size: 16, color: AppTheme.gray),
                  const SizedBox(width: 4),
                  Text(
                    '${booking.seatsBooked} ${translate("history.seats")}',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.gray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ── Price row ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text14h500w(
                title: translate("history.price"),
                color: AppTheme.gray,
              ),
              Text16h500w(
                title: "${Utils.priceFormat(booking.totalPrice)} UZS",
                color: AppTheme.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'confirmed':
        return translate('history.in_progress');
      case 'completed':
        return translate('history.completed');
      case 'canceled':
      case 'cancelled':
        return translate('history.canceled');
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'confirmed':
        return AppTheme.purple;
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'canceled':
      case 'cancelled':
        return const Color(0xFFE53935);
      default:
        return AppTheme.purple;
    }
  }

  Color? _parseColor(String hex) {
    if (hex.isEmpty) return null;
    final cleaned = hex.replaceAll('#', '');
    final value = int.tryParse(
      cleaned.length == 6 ? 'FF$cleaned' : cleaned,
      radix: 16,
    );
    return value != null ? Color(value) : null;
  }

  String safeSubstring(String text, int length) {
    return text.length >= length
        ? text.substring(0, length).toUpperCase()
        : text.toUpperCase();
  }
}
