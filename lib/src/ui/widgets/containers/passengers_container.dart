import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/model/passenger_model.dart';
import 'package:ketamiz/src/theme/app_theme.dart';
import 'package:ketamiz/src/ui/dialogs/bottom_dialog.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_14h_400w.dart';

class PassengersContainer extends StatefulWidget {
  const PassengersContainer({
    super.key,
    required this.passenger,
    required this.onEdit,
    required this.onDelete,
    required this.onSetLocation,
  });

  final PassengerModel passenger;
  final Function(PassengerModel data) onEdit;
  final Function() onDelete;
  final Function() onSetLocation;

  @override
  State<PassengersContainer> createState() => _PassengersContainerState();
}

class _PassengersContainerState extends State<PassengersContainer> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 270,
      ),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.light,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 24,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text14h400w(title: widget.passenger.fullName)),
                const SizedBox(width: 8),
                // Pickup-location indicator: green when set, gray when missing.
                Icon(
                  widget.passenger.hasLocation
                      ? Icons.location_on
                      : Icons.location_off_outlined,
                  size: 18,
                  color: widget.passenger.hasLocation
                      ? AppTheme.green
                      : AppTheme.gray,
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: (){
                    widget.onDelete();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 24,
                      color: AppTheme.red,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: (){
                    setState(() {
                      isTapped = !isTapped;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      isTapped == false ? Icons.keyboard_arrow_down_outlined: Icons.keyboard_arrow_up_outlined,
                      size: 24,
                      color: AppTheme.black,
                    ),
                  ),
                ),
              ],
            ),
            isTapped == true
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text14h400w(
                                  title: widget.passenger.phoneNumber,
                                  color: AppTheme.gray,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              BottomDialog.showAddPassenger(
                                context,
                                widget.passenger,
                                (data) {
                                  widget.onEdit(data);
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.mode_edit_outline,
                                size: 24,
                                color: AppTheme.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Pickup location row — tap to set or change on the map.
                      GestureDetector(
                        onTap: widget.onSetLocation,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                widget.passenger.hasLocation
                                    ? Icons.location_on
                                    : Icons.add_location_alt_outlined,
                                size: 20,
                                color: AppTheme.purple,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text14h400w(
                                  title: widget.passenger.hasLocation
                                      ? translate("home.pickup_location_set")
                                      : translate("home.set_pickup_location"),
                                  color: widget.passenger.hasLocation
                                      ? AppTheme.black
                                      : AppTheme.purple,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: AppTheme.gray,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
