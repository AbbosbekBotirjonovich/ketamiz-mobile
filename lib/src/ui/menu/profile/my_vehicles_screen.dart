import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:ketamiz/src/ui/menu/profile/add_vehicle_screen.dart';
import 'package:ketamiz/src/ui/widgets/containers/car_container.dart';
import 'package:ketamiz/src/ui/widgets/containers/leading_back.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_16h_500w.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/api/vehicles_list_model.dart';
import '../../../model/color_model.dart';
import '../../../model/vehicle_model.dart';
import '../../../resources/repository.dart';
import '../../../theme/app_theme.dart';
import '../../dialogs/center_dialog.dart';
import '../../dialogs/snack_bar.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/buttons/secondary_button.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  static const String _vehiclesCacheKey = 'cache_vehicles';

  final Repository _repository = Repository();
  List<VehicleModel> myVehicles = [];
  bool isLoading = false;

  String driverStatus = "";

  Future<void> getDriverStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String status = prefs.getString('driving_verification_status') ?? "";

    setState(() {
      driverStatus = status;
    });
  }

  /// Shared gate for both Add Vehicle buttons (empty state + bottom bar).
  void _onAddVehicle() {
    if (driverStatus == "approved") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddVehicleScreen()),
      );
    } else if (driverStatus == "pending") {
      CenterDialog.showInfo(
        context,
        translate("profile.application_pending_title"),
        translate("profile.application_pending_msg"),
      );
    } else {
      CenterDialog.showActionFailed(
        context,
        translate("ketamiz.error"),
        translate("profile.docs_not_verified"),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getVehicles();
    getDriverStatus();
  }

  List<VehicleModel> _mapVehicles(List<dynamic> data) {
    return data.map((e) {
      MyVehiclesModel m = MyVehiclesModel.fromJson(e);
      return VehicleModel(
        id: m.id,
        vehicleName: m.model,
        color: ColorModel(
          id: 0,
          titleEn: m.color.titleEn,
          titleRu: m.color.titleRu,
          titleUz: m.color.titleUz,
          colorCode: _parseColorCode(m.color.code),
        ),
        capacity: m.seats,
      );
    }).toList();
  }

  Future<void> getVehicles() async {
    // Cache-first: render the last known list instantly, no spinner flash.
    final cached = await _repository.getCachedList(_vehiclesCacheKey);
    if (!mounted) return;
    if (cached.isNotEmpty) {
      setState(() {
        myVehicles = _mapVehicles(cached);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = true);
    }

    // Always revalidate from the network.
    final response = await _repository.fetchVehiclesList();
    if (!mounted) return;
    if (response.isSuccess) {
      List<dynamic> data = [];
      if (response.result is List) {
        data = response.result;
      } else if (response.result is Map &&
          response.result.containsKey('data')) {
        data = response.result['data'];
      }
      _repository.cacheRawList(_vehiclesCacheKey, data);
      setState(() => myVehicles = _mapVehicles(data));
    }
    setState(() => isLoading = false);
  }

  Color _parseColorCode(String code) {
    try {
      return Color(int.parse(code.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.grey;
    }
  }

  Future<void> _deleteVehicle(int index) async {
    final vehicle = myVehicles[index];
    CenterDialog.showConfirmation(
      context,
      translate("profile.delete_vehicle"),
      translate("profile.delete_vehicle_confirm"),
      onConfirm: () async {
        Navigator.pop(context);
        setState(() => isLoading = true);
        final response = await _repository.fetchDeleteVehicle(vehicle.id);
        if (!mounted) return;
        setState(() => isLoading = false);
        if (response.isSuccess) {
          setState(() => myVehicles.removeAt(index));
          CustomSnackBar().showSnackBar(context, translate("profile.vehicle_deleted"), 1);
        } else {
          CenterDialog.showActionFailed(
            context,
            translate("ketamiz.error"),
            translate("profile.delete_vehicle_failed"),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("profile.my_vehicles")),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppTheme.purple,
            onRefresh: () async {
              await getVehicles();
            },
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.purple,
                    ),
                  )
                : myVehicles.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  "assets/lottie/empty.json",
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(height: 24),
                                Text16h500w(title: translate("profile.no_vehicles_found")),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const SizedBox(width: 32),
                                    Expanded(
                                      child: Text(
                                        translate("profile.no_vehicles_found_msg"),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.gray,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppTheme.fontFamily,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: SecondaryButton(
                                    title: translate("profile.add_vehicle"),
                                    onTap: _onAddVehicle,
                                  ),
                                ),
                                const SizedBox(height: 92),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: 100,
                        ),
                        itemCount: myVehicles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.dark.withOpacity(0.05),
                                  spreadRadius: 0,
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CarContainer(
                                car: myVehicles[index],
                                onDelete: () => _deleteVehicle(index),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrimaryButton(
                title: translate("profile.add_vehicle"),
                onTap: _onAddVehicle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
