import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/ui/menu/history/history.dart';
import 'package:ketamiz/src/ui/menu/new_ketamiz/new_ketamiz.dart';
import 'package:ketamiz/src/ui/menu/profile/profile_screen.dart';
import 'package:ketamiz/src/ui/menu/profile/wallet_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/ketamiz_bloc.dart';
import '../../model/api/driver_trips_list_model.dart';
import '../../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'new_ketamiz/add_docs_screen.dart';
import 'new_ketamiz/create_new_ketamiz_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isDriver = false;
  bool _isRoleLoaded = false;

  // Client tabs: Home, Bookings, Wallet, Profile
  static const List<Widget> _clientScreens = [
    HomeScreen(),
    History(),
    WalletScreen(),
    ProfileScreen(),
  ];

  // Driver tabs: Home, My Trips, [Create — handled via push], Profile
  static const List<Widget> _driverScreens = [
    HomeScreen(),
    NewKetamiz(),
    SizedBox(), // placeholder; tapping tab 2 pushes CreateNewKetamizScreen
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    resetHomeBloc();
    resetProfileBloc();
    resetKetamizBloc();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isDriver = prefs.getString('role') == 'driver';
        _isRoleLoaded = true;
      });
    }
  }

  List<Widget> get _screens =>
      _isDriver ? _driverScreens : _clientScreens;

  void _onTabTapped(int index) {
    // Driver tab 2 = Create Trip action (push, not switch)
    if (_isDriver && index == 2) {
      _handleCreateTrip();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _handleCreateTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final isVerified =
        prefs.getString('driving_verification_status') == 'approved';

    if (!mounted) return;
    if (isVerified) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateNewKetamizScreen(
            driverTrip: DriverTripModel.defaultTrip(),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddDocsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRoleLoaded) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.purple),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),
          Positioned(
            bottom: 0,
            left: 0,
            child: _buildBottomNav(size.width),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(double width) {
    return Container(
      height: 82,
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 25,
            color: AppTheme.dark.withOpacity(0.2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _isDriver
            ? _buildDriverTabs()
            : _buildClientTabs(),
      ),
    );
  }

  // ── Client tabs ──────────────────────────────────────────────────────────

  List<Widget> _buildClientTabs() => [
        _navItem(
          index: 0,
          activeIcon: SvgPicture.asset('assets/icons/home_full.svg',
              colorFilter: const ColorFilter.mode(
                  AppTheme.purple, BlendMode.srcIn)),
          inactiveIcon: SvgPicture.asset('assets/icons/home.svg',
              colorFilter: const ColorFilter.mode(
                  AppTheme.gray, BlendMode.srcIn)),
          label: translate("nav.home"),
        ),
        _navItem(
          index: 1,
          activeIcon: const Icon(Icons.library_books_rounded,
              color: AppTheme.purple, size: 24),
          inactiveIcon: const Icon(Icons.library_books_outlined,
              color: AppTheme.gray, size: 24),
          label: translate("nav.bookings"),
        ),
        _navItem(
          index: 2,
          activeIcon: const Icon(Icons.account_balance_wallet_rounded,
              color: AppTheme.purple, size: 24),
          inactiveIcon: const Icon(Icons.account_balance_wallet_outlined,
              color: AppTheme.gray, size: 24),
          label: translate("nav.wallet"),
        ),
        _navItem(
          index: 3,
          activeIcon: SvgPicture.asset('assets/icons/profile_full.svg',
              colorFilter: const ColorFilter.mode(
                  AppTheme.purple, BlendMode.srcIn)),
          inactiveIcon: SvgPicture.asset('assets/icons/profile.svg',
              colorFilter: const ColorFilter.mode(
                  AppTheme.gray, BlendMode.srcIn)),
          label: translate("nav.profile"),
        ),
      ];

  // ── Driver tabs ──────────────────────────────────────────────────────────

  List<Widget> _buildDriverTabs() => [
        _navItem(
          index: 0,
          activeIcon: SvgPicture.asset('assets/icons/home_full.svg',
              colorFilter: const ColorFilter.mode(
                  AppTheme.purple, BlendMode.srcIn)),
          inactiveIcon: SvgPicture.asset('assets/icons/home.svg',
              colorFilter: const ColorFilter.mode(
                  AppTheme.gray, BlendMode.srcIn)),
          label: translate("nav.home"),
        ),
        _navItem(
          index: 1,
          activeIcon: const Icon(
              CupertinoIcons.arrow_right_arrow_left_circle_fill,
              color: AppTheme.purple,
              size: 24),
          inactiveIcon: const Icon(
              CupertinoIcons.arrow_right_arrow_left_circle,
              color: AppTheme.gray,
              size: 24),
          label: translate("nav.my_trips"),
        ),
        // Create button (action, not a sticky tab)
        GestureDetector(
          onTap: () => _handleCreateTrip(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppTheme.purple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 2),
              Text(
                translate("nav.create"),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        _navItem(
          index: 3,
          activeIcon: SvgPicture.asset('assets/icons/profile_full.svg',
              colorFilter: const ColorFilter.mode(
                  AppTheme.purple, BlendMode.srcIn)),
          inactiveIcon: SvgPicture.asset('assets/icons/profile.svg',
              colorFilter: const ColorFilter.mode(
                  AppTheme.gray, BlendMode.srcIn)),
          label: translate("nav.profile"),
        ),
      ];

  // ── Shared nav item ───────────────────────────────────────────────────────

  Widget _navItem({
    required int index,
    required Widget activeIcon,
    required Widget inactiveIcon,
    required String label,
  }) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isActive ? activeIcon : inactiveIcon,
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppTheme.bg : AppTheme.gray,
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.normal,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
