import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:latlong2/latlong.dart';
import 'package:ketamiz/src/model/api/book_model.dart';
import 'package:ketamiz/src/ui/dialogs/center_dialog.dart';
import 'package:ketamiz/src/ui/dialogs/snack_bar.dart';
import 'package:ketamiz/src/ui/menu/home/map_route_screen.dart';
import 'package:ketamiz/src/ui/widgets/containers/leading_back.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_14h_400w.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_16h_500w.dart';
import 'package:ketamiz/src/utils/utils.dart';
import '../../../resources/repository.dart';
import '../../../theme/app_theme.dart';

/// Client-facing details of a trip the user has booked, with the option to
/// cancel the booking (while it is still cancellable).
class BookedTripDetailsScreen extends StatefulWidget {
  const BookedTripDetailsScreen({super.key, required this.booking});

  final BookModel booking;

  @override
  State<BookedTripDetailsScreen> createState() =>
      _BookedTripDetailsScreenState();
}

class _BookedTripDetailsScreenState extends State<BookedTripDetailsScreen> {
  final Repository _repository = Repository();
  bool _isCancelling = false;

  BookedTrip get _trip => widget.booking.trip;

  String get _status => widget.booking.status.toLowerCase();

  /// A booking can be cancelled while it is still upcoming.
  bool get _canCancel =>
      _status == 'confirmed' || _status == 'pending' || _status == 'active';

  String get _from => [_trip.startQuarter, _trip.startDistrict, _trip.startRegion]
      .where((s) => s.isNotEmpty)
      .join(', ');

  String get _to => [_trip.endQuarter, _trip.endDistrict, _trip.endRegion]
      .where((s) => s.isNotEmpty)
      .join(', ');

  Color get _statusColor {
    switch (_status) {
      case 'completed':
        return AppTheme.green;
      case 'canceled':
      case 'cancelled':
        return AppTheme.red;
      default: // confirmed / pending / in_progress / active
        return AppTheme.purple;
    }
  }

  String get _statusText {
    switch (_status) {
      case 'confirmed':
        return translate('history.in_progress');
      case 'in_progress':
        return translate('history.in_progress');
      case 'completed':
        return translate('history.completed');
      case 'canceled':
      case 'cancelled':
        return translate('history.canceled');
      case 'active':
        return translate('history.active');
      default:
        return widget.booking.status;
    }
  }

  String get _pricePerSeat {
    final p = _trip.pricePerSeat;
    return p.contains('.') ? p.split('.')[0] : p;
  }

  String get _driverName =>
      '${widget.booking.driver.firstName} ${widget.booking.driver.lastName}'
          .trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("home.booking_details")),
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
                if (widget.booking.passengers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildPassengersCard(),
                ],
              ],
            ),
          ),
          if (_canCancel) _buildCancelBar(),
        ],
      ),
    );
  }

  // ── Route card ──────────────────────────────────────────────────────────
  Widget _buildRouteCard() {
    final vehicleModel = widget.booking.vehicle.model;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.booking.status.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
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
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${Utils.priceFormat(widget.booking.totalPrice.isNotEmpty ? widget.booking.totalPrice : _pricePerSeat)} ${translate("currency")}",
                    style: const TextStyle(
                      color: AppTheme.black,
                      fontSize: 17,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    translate("home.total_price"),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Utils.timeFormat(_trip.startTime),
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _from.isEmpty ? "—" : _from,
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
                      Utils.timeFormat(_trip.endTime),
                      style: const TextStyle(
                        color: AppTheme.black,
                        fontSize: 16,
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _to.isEmpty ? "—" : _to,
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
                    child: const Icon(Icons.person_rounded,
                        color: AppTheme.purple, size: 24),
                  ),
                  const SizedBox(height: 6),
                  if (_driverName.isNotEmpty)
                    SizedBox(
                      width: 92,
                      child: Text(
                        _driverName,
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

  // ── Details card ────────────────────────────────────────────────────────
  Widget _buildDetailsCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text16h500w(title: translate("home.details")),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.radio_button_checked_rounded,
            iconColor: AppTheme.purple,
            label: translate("home.travelling_from"),
            value: _from.isEmpty ? "—" : _from,
          ),
          _divider(),
          _infoRow(
            icon: Icons.location_on_rounded,
            iconColor: AppTheme.red,
            label: translate("home.where_to"),
            value: _to.isEmpty ? "—" : _to,
          ),
          _divider(),
          _infoRow(
            icon: Icons.calendar_today_rounded,
            iconColor: AppTheme.purple,
            label: translate("home.departure_date"),
            value: Utils.searchDateFormat(_trip.startTime),
          ),
          _divider(),
          _infoRow(
            icon: Icons.event_seat_rounded,
            iconColor: AppTheme.purple,
            label: translate("home.seats_booked"),
            value: "${widget.booking.seatsBooked}",
          ),
          _divider(),
          _infoRow(
            icon: Icons.payments_rounded,
            iconColor: AppTheme.purple,
            label: translate("home.price_per_seat"),
            value:
                "${Utils.priceFormat(_pricePerSeat)} ${translate("currency")}",
          ),
          const SizedBox(height: 14),
          if (_hasCoordinates) _showOnMapButton(),
        ],
      ),
    );
  }

  // ── Passengers card ─────────────────────────────────────────────────────
  Widget _buildPassengersCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text16h500w(title: translate("home.booked_passengers")),
              ),
              Text(
                "${widget.booking.passengers.length}",
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(widget.booking.passengers.length, (i) {
            final p = widget.booking.passengers[i];
            return Container(
              margin: EdgeInsets.only(
                  bottom: i == widget.booking.passengers.length - 1 ? 0 : 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.light,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.person,
                        size: 22, color: AppTheme.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text14h400w(title: p.name),
                        if (p.phone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text14h400w(title: p.phone, color: AppTheme.gray),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Cancel bar ──────────────────────────────────────────────────────────
  Widget _buildCancelBar() {
    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppTheme.border)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -4),
            blurRadius: 16,
            color: AppTheme.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: _isCancelling ? null : _cancelBooking,
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
                    translate("ketamiz.cancel_booking"),
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

  void _cancelBooking() {
    CenterDialog.showConfirmation(
      context,
      translate("ketamiz.cancel_booking"),
      translate("ketamiz.cancel_booking_confirm"),
      onConfirm: () async {
        Navigator.pop(context);
        setState(() => _isCancelling = true);

        final response = await _repository
            .fetchCancelBooking(widget.booking.bookingId.toString());

        if (!mounted) return;
        setState(() => _isCancelling = false);

        if (response.isSuccess) {
          CustomSnackBar()
              .showSnackBar(context, translate("ketamiz.booking_cancelled"), 1);
          // Tell the caller to refresh its list.
          Navigator.pop(context, true);
        } else {
          CenterDialog.showActionFailed(
            context,
            translate("ketamiz.error"),
            translate("ketamiz.booking_cancel_failed"),
          );
        }
      },
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  bool get _hasCoordinates =>
      _trip.fromLatitude.isNotEmpty &&
      _trip.fromLongitude.isNotEmpty &&
      _trip.toLatitude.isNotEmpty &&
      _trip.toLongitude.isNotEmpty;

  Widget _showOnMapButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MapRouteScreen(
              start: LatLng(double.tryParse(_trip.fromLatitude) ?? 0,
                  double.tryParse(_trip.fromLongitude) ?? 0),
              end: LatLng(double.tryParse(_trip.toLatitude) ?? 0,
                  double.tryParse(_trip.toLongitude) ?? 0),
              startText: _from,
              endText: _to,
              // Already booked → exact route visible.
              approximate: false,
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
              translate("home.show_on_map"),
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

  Widget _card({required Widget child}) {
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
      child: child,
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppTheme.border);

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
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
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: AppTheme.gray,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
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
        ],
      ),
    );
  }
}
