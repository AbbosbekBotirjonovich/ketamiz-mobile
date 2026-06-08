import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:ketamiz/src/bloc/home_bloc.dart';
import 'package:ketamiz/src/model/api/trip_list_model.dart';
import 'package:ketamiz/src/ui/menu/home/trip_details_screen.dart';
import 'package:ketamiz/src/ui/widgets/containers/destinations_container.dart';
import 'package:ketamiz/src/ui/widgets/containers/leading_back.dart';
import 'package:shimmer/shimmer.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/texts/text_16h_500w.dart';

/// Lists every available trip ("View all" on the home screen).
class AllTripsScreen extends StatefulWidget {
  const AllTripsScreen({super.key});

  @override
  State<AllTripsScreen> createState() => _AllTripsScreenState();
}

class _AllTripsScreenState extends State<AllTripsScreen> {
  @override
  void initState() {
    blocHome.fetchTripList();
    super.initState();
  }

  Future<void> _onRefresh() async {
    blocHome.fetchTripList();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.light,
      appBar: AppBar(
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("home.all_trips")),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        color: AppTheme.purple,
        onRefresh: _onRefresh,
        child: StreamBuilder(
          stream: blocHome.getTrips,
          builder: (context, AsyncSnapshot<List<TripListModel>> snapshot) {
            if (!snapshot.hasData) return _buildShimmer();

            final trips = snapshot.data!;
            if (trips.isEmpty) return _buildEmpty();

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: trips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
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
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
      children: [
        Center(
          child: Lottie.asset(
            "assets/lottie/empty.json",
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text16h500w(title: translate("ketamiz.No_trip_found")),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.baseColor,
      highlightColor: AppTheme.highlightColor,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => Container(
          height: 150,
          decoration: BoxDecoration(
            color: AppTheme.baseColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
