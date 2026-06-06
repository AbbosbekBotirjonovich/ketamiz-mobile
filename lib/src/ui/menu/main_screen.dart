import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
import 'home/home_screen.dart';
import 'new_ketamiz/add_docs_screen.dart';
import 'new_ketamiz/create_new_ketamiz_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isDriver = false;
  bool _isRoleLoaded = false;
  String _balance = '0';
  String _lockedBalance = '0';
  String _currency = 'UZS';

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
    WidgetsBinding.instance.addObserver(this);
    resetHomeBloc();
    resetProfileBloc();
    resetKetamizBloc();
    _loadRole();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadBalance();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isDriver = prefs.getString('role') == 'driver';
        _isRoleLoaded = true;
      });
    }
    await _loadBalance();
  }

  Future<void> _loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _balance = prefs.getString('balance') ?? '0';
      _lockedBalance = prefs.getString('balance_locked') ?? '0';
      _currency = prefs.getString('balance_currency') ?? 'UZS';
    });
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      _handleCreateTrip();
      return;
    }
    setState(() => _selectedIndex = index);
    _loadBalance();
  }

  Future<void> _handleCreateTrip() async {
    final prefs = await SharedPreferences.getInstance();
    final isVerified =
        prefs.getString('driving_verification_status') == 'approved';
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isVerified
            ? CreateNewKetamizScreen(driverTrip: DriverTripModel.defaultTrip())
            : const AddDocsScreen(),
      ),
    );
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
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _buildScreens(localeKey),
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
    final formattedBalance = _formatBalance(_balance);
    final formattedLocked = _formatBalance(_lockedBalance);
    final hasLocked = (double.tryParse(_lockedBalance) ?? 0) > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.black,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 8),
            blurRadius: 32,
            color: Colors.black.withOpacity(0.28),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Balance row ─────────────────────────────────────────────────
          GestureDetector(
            onTap: () => _onTabTapped(3),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.purple.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppTheme.purple,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        translate('nav.balance'),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.gray,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        '$formattedBalance $_currency',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (hasLocked) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.lock_outline_rounded,
                              color: AppTheme.gray, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '$formattedLocked $_currency',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  const Icon(Icons.chevron_right_rounded,
                      color: AppTheme.gray, size: 18),
                ],
              ),
            ),
          ),
          // ── Divider ─────────────────────────────────────────────────────
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white.withOpacity(0.08),
          ),
          // ── Tabs row ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _navItem(
                  index: 0,
                  activeIcon: SvgPicture.asset('assets/icons/home_full.svg',
                      width: 22, height: 22,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn)),
                  inactiveIcon: SvgPicture.asset('assets/icons/home.svg',
                      width: 22, height: 22,
                      colorFilter: const ColorFilter.mode(
                          AppTheme.gray, BlendMode.srcIn)),
                  label: translate('nav.home'),
                ),
                _navItem(
                  index: 1,
                  activeIcon: const Icon(Icons.library_books_rounded,
                      color: Colors.white, size: 22),
                  inactiveIcon: const Icon(Icons.library_books_outlined,
                      color: AppTheme.gray, size: 22),
                  label: translate('nav.bookings'),
                ),
                _createButton(),
                _navItem(
                  index: 3,
                  activeIcon: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 22),
                  inactiveIcon: const Icon(Icons.account_balance_wallet_outlined,
                      color: AppTheme.gray, size: 22),
                  label: translate('nav.wallet'),
                ),
                _navItem(
                  index: 4,
                  activeIcon: SvgPicture.asset('assets/icons/profile_full.svg',
                      width: 22, height: 22,
                      colorFilter: const ColorFilter.mode(
                          Colors.white, BlendMode.srcIn)),
                  inactiveIcon: SvgPicture.asset('assets/icons/profile.svg',
                      width: 22, height: 22,
                      colorFilter: const ColorFilter.mode(
                          AppTheme.gray, BlendMode.srcIn)),
                  label: translate('nav.profile'),
                ),
              ],
            ),
          ),
        ],
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
            // Circle background with icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withOpacity(0.14)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: isActive
                      ? KeyedSubtree(key: ValueKey('a_$index'), child: activeIcon)
                      : KeyedSubtree(key: ValueKey('i_$index'), child: inactiveIcon),
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
                color: isActive ? Colors.white : AppTheme.gray,
                height: 1,
              ),
              child: Text(label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }

  // ── Create button — always solid purple circle + label ────────────────────

  Widget _createButton() {
    return Expanded(
      child: GestureDetector(
        onTap: _handleCreateTrip,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppTheme.purple,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.add_rounded, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              translate('nav.create'),
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

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatBalance(String raw) {
    final trimmed = raw.contains('.') ? raw.split('.')[0] : raw;
    return trimmed.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
