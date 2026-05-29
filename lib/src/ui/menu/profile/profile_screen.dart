import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/ui/auth/login_screen.dart';
import 'package:ketamiz/src/ui/menu/profile/edit_profile_screen.dart';
import 'package:ketamiz/src/ui/menu/profile/my_vehicles_screen.dart';
import 'package:ketamiz/src/ui/menu/profile/top_up_screen.dart';
import 'package:ketamiz/src/ui/menu/profile/transaction_history_screen.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_12h_400w.dart';
import 'package:ketamiz/src/ui/widgets/texts/text_16h_500w.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../bloc/profile_bloc.dart';
import '../../../model/settings_model.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/utils.dart';
import '../../widgets/containers/settings_container.dart';
import '../../widgets/texts/text_14h_400w.dart';
import '../../widgets/texts/text_18h_500w.dart';

const _kLanguages = [
  {'code': 'uz', 'name': "O'zbek", 'flag': '🇺🇿'},
  {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
  {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String balance = "";
  String _myImage = '';
  String _myName = '';
  String _myPhone = '';
  bool _isDriver = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    await blocProfile.fetchMe();
    await getBalance();
    await _getInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text16h500w(title: translate("profile.my_profile")),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppTheme.purple,
        onRefresh: _refresh,
        child: ListView(
        padding: const EdgeInsets.only(
          top: 22,
          bottom: 92,
          left: 16,
          right: 16,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.purple),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 100,
                  spreadRadius: 0,
                  color: AppTheme.black.withOpacity(0.05),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: _myImage,
                    placeholder: (context, url) => Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: AppTheme.gray,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: AppTheme.light,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.error,
                          color: AppTheme.purple,
                          size: 24,
                        ),
                      ),
                    ),
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text18h500w(
                        title: _myName,
                      ),
                      const SizedBox(height: 4),
                      Text12h400w(
                        title: _myPhone,
                        color: AppTheme.gray,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.light,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        Text14h400w(title: translate("profile.edit_profile")),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 100,
                  spreadRadius: 0,
                  color: AppTheme.black.withOpacity(0.05),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text16h500w(
                        title: translate("profile.my_balance"),
                        color: AppTheme.light,
                      ),
                      const SizedBox(height: 16),
                      Text18h500w(
                        title:
                            "${Utils.priceFormat(balance)} ${translate("currency")}",
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TopUpScreen(),
                      ),
                    ).then((_) {
                      setState(() {
                        blocProfile.fetchMe();
                        getBalance();
                      });
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Text14h400w(
                          title: translate("profile.top_up"),
                          color: AppTheme.purple,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.monetization_on_outlined,
                          color: AppTheme.purple,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 100,
                    color: AppTheme.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 22, color: AppTheme.purple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text16h500w(
                      title: translate("profile.transactions"),
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 20, color: AppTheme.gray),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text16h500w(
            title: translate("profile.settings"),
          ),
          if (_isDriver)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyVehiclesScreen(),
                  ),
                );
              },
              child: SettingsContainer(
                  settingsModel: SettingsModel(
                icon: Icons.directions_car_outlined,
                title: translate("profile.my_vehicles"),
              )),
            ),
          SettingsContainer(
              settingsModel: SettingsModel(
            icon: Icons.lock_clock,
            title: translate("profile.change_password"),
          )),
          GestureDetector(
            onTap: () => _showLanguagePicker(),
            child: SettingsContainer(
                settingsModel: SettingsModel(
              icon: Icons.language,
              title: translate("profile.language"),
            )),
          ),
          SettingsContainer(
              settingsModel: SettingsModel(
            icon: Icons.notifications,
            title: translate("profile.notifications"),
          )),
          const SizedBox(height: 16),
          Text16h500w(
            title: translate("profile.about_us"),
          ),
          SettingsContainer(
              settingsModel: SettingsModel(
            icon: Icons.info,
            title: translate("profile.info"),
          )),
          SettingsContainer(
              settingsModel: SettingsModel(
            icon: Icons.privacy_tip,
            title: translate("profile.privacy_security"),
          )),
          SettingsContainer(
              settingsModel: SettingsModel(
            icon: Icons.contact_support,
            title: translate("profile.contact_us"),
          )),
          const SizedBox(height: 16),
          Text16h500w(
            title: translate("profile.other"),
          ),
          SettingsContainer(
              settingsModel: SettingsModel(
            icon: Icons.share,
            title: translate("profile.share"),
          )),
          GestureDetector(
            onTap: () async {
              await wipeSharedPreferences();
              if (!mounted) return;
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
            child: SettingsContainer(
                settingsModel: SettingsModel(
              icon: Icons.logout_outlined,
              title: translate("profile.logout"),
            )),
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _showLanguagePicker() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString('language') ?? 'uz';

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LanguagePickerSheet(currentCode: current),
    );

    // Rebuild so the locale change is reflected immediately in this screen
    if (mounted) setState(() {});
  }

  Future<void> getBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      balance = prefs.getString('balance') ?? "0";
    });
  }

  Future<void> _getInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firstName = prefs.getString('first_name') ?? '';
    String lastName = prefs.getString('last_name') ?? '';
    setState(() {
      _myImage = prefs.getString('avatar') ?? '';
      _myName = '$firstName $lastName';
      _myPhone = prefs.getString('phone') ?? '';
      _isDriver = prefs.getString('role') == 'driver';
    });
  }

  Future<void> wipeSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class _LanguagePickerSheet extends StatefulWidget {
  const _LanguagePickerSheet({required this.currentCode});
  final String currentCode;

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentCode;
  }

  Future<void> _apply() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selected);
    if (!mounted) return;
    final delegate = LocalizedApp.of(context).delegate;
    await delegate.changeLocale(Locale(_selected));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text16h500w(title: translate("profile.language")),
          const SizedBox(height: 20),
          ..._kLanguages.map((lang) => GestureDetector(
                onTap: () => setState(() => _selected = lang['code']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _selected == lang['code']
                        ? AppTheme.purple.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selected == lang['code']
                          ? AppTheme.purple
                          : AppTheme.border,
                      width: _selected == lang['code'] ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          lang['name']!,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _selected == lang['code']
                                ? AppTheme.purple
                                : AppTheme.black,
                          ),
                        ),
                      ),
                      if (_selected == lang['code'])
                        const Icon(Icons.check_circle,
                            color: AppTheme.purple, size: 20),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                translate("home.save"),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
