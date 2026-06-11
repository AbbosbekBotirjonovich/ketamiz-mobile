import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/ui/menu/history/trips_screen.dart';
import 'package:ketamiz/src/ui/menu/profile/profile_screen.dart';
import 'package:ketamiz/src/ui/menu/profile/wallet_screen.dart';
import 'package:ketamiz/src/utils/nav_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/ketamiz_bloc.dart';
import '../../model/api/driver_trips_list_model.dart';
import '../../theme/app_theme.dart';
import '../dialogs/center_dialog.dart';
import 'home/home_screen.dart';
import 'new_ketamiz/add_docs_screen.dart';
import 'new_ketamiz/create_new_ketamiz_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  bool _isRoleLoaded = false;
  bool _isDriver = false;

  // Drives the screen transition when switching tabs (fade + slide + scale).
  late final AnimationController _pageController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: 1.0,
  );

  // Index 2 is a placeholder — Create Trip is an action, not a screen.
  List<Widget> _buildScreens(String localeKey) => [
        HomeScreen(key: ValueKey('home_$localeKey')),
        TripsScreen(key: ValueKey('trips_$localeKey')),
        const SizedBox(),
        WalletScreen(key: ValueKey('wallet_$localeKey')),
        ProfileScreen(key: ValueKey('profile_$localeKey')),
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

  void _onTabTapped(int index) {
    if (index == 2) {
      _isDriver ? _handleCreateTrip() : _handleBecomeDriver();
      return;
    }
    if (index == _selectedIndex) return;
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
    _pageController.forward(from: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Docs already submitted and under review — tell the user to wait.
  void _showApplicationPending() {
    CenterDialog.showInfo(
      context,
      translate('profile.application_pending_title'),
      translate('profile.application_pending_msg'),
    );
  }

  Future<void> _handleCreateTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('driving_verification_status') ?? 'none';
    if (!mounted) return;
    if (status == 'pending') {
      _showApplicationPending();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => status == 'approved'
            ? CreateNewKetamizScreen(driverTrip: DriverTripModel.defaultTrip())
            : const AddDocsScreen(),
      ),
    );
  }

  Future<void> _handleBecomeDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString('driving_verification_status') ?? 'none';
    if (!mounted) return;
    if (status == 'pending') {
      _showApplicationPending();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddDocsScreen()),
    );
    // Role may have changed after submitting docs — refresh the button.
    _loadRole();
  }

  @override
  Widget build(BuildContext context) {
    final localeKey = Localizations.localeOf(context).languageCode;

    if (!_isRoleLoaded) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.purple)),
      );
    }

    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppTheme.light,
      body: Stack(
        children: [
          // Tab transition: incoming screen fades in while sliding from the
          // direction of travel with a subtle zoom — IndexedStack keeps state.
          AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(_pageController.value);
              final direction = _selectedIndex >= _previousIndex ? 1.0 : -1.0;
              return Opacity(
                opacity: t,
                child: Transform.translate(
                  offset: Offset(direction * 32 * (1 - t), 0),
                  child: Transform.scale(
                    scale: 0.98 + 0.02 * t,
                    child: child,
                  ),
                ),
              );
            },
            child: IndexedStack(
              index: _selectedIndex,
              children: _buildScreens(localeKey),
            ),
          ),
          Positioned(
            bottom: kNavBarBottomMargin + safeBottom,
            left: 16,
            right: 16,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 8),
            blurRadius: 24,
            color: AppTheme.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const indicatorSize = 44.0;
            final slotWidth = constraints.maxWidth / 5;
            final indicatorLeft =
                _selectedIndex * slotWidth + (slotWidth - indicatorSize) / 2;
            return Stack(
              children: [
                // Sliding pill that glides to the active tab.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 340),
                  curve: Curves.easeOutCubic,
                  left: indicatorLeft,
                  top: 0,
                  width: indicatorSize,
                  height: indicatorSize,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _navItem(
                      index: 0,
                      activeIcon: const Icon(Icons.home_rounded,
                          color: AppTheme.purple, size: 22),
                      inactiveIcon: const Icon(Icons.home_outlined,
                          color: AppTheme.gray, size: 22),
                      label: translate('nav.home'),
                    ),
                    _navItem(
                      index: 1,
                      activeIcon: const Icon(Icons.library_books_rounded,
                          color: AppTheme.purple, size: 22),
                      inactiveIcon: const Icon(Icons.library_books_outlined,
                          color: AppTheme.gray, size: 22),
                      label: translate('nav.bookings'),
                    ),
                    _createButton(),
                    _navItem(
                      index: 3,
                      activeIcon: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppTheme.purple,
                          size: 22),
                      inactiveIcon: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppTheme.gray,
                          size: 22),
                      label: translate('nav.wallet'),
                    ),
                    _navItem(
                      index: 4,
                      activeIcon: const Icon(Icons.person_rounded,
                          color: AppTheme.purple, size: 22),
                      inactiveIcon: const Icon(Icons.person_outline_rounded,
                          color: AppTheme.gray, size: 22),
                      label: translate('nav.profile'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Animated nav item — icon circle + label below ───────────────────────

  Widget _navItem({
    required int index,
    required Widget activeIcon,
    required Widget inactiveIcon,
    required String label,
  }) {
    final isActive = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circle background with icon — pops with a spring when selected
            AnimatedScale(
              duration: const Duration(milliseconds: 420),
              curve: isActive ? Curves.elasticOut : Curves.easeOut,
              scale: isActive ? 1.0 : 0.88,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: Tween<double>(begin: 0.7, end: 1.0)
                          .animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: isActive
                        ? KeyedSubtree(
                            key: ValueKey('a_$index'), child: activeIcon)
                        : KeyedSubtree(
                            key: ValueKey('i_$index'), child: inactiveIcon),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppTheme.purple : AppTheme.gray,
                height: 1,
              ),
              child: Text(label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }

  // ── Center button — solid purple circle + label ───────────────────────────
  // Drivers: "Create" (new trip). Clients: "Become a Driver" (docs flow).

  Widget _createButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _isDriver ? _handleCreateTrip : _handleBecomeDriver,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.purple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    color: AppTheme.purple.withOpacity(0.35),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _isDriver ? Icons.add_rounded : Icons.drive_eta_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isDriver
                  ? translate('nav.create')
                  : translate('nav.become_driver'),
              maxLines: 1,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppTheme.gray,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
