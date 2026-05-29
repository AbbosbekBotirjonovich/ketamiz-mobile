import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:ketamiz/src/lan_localization/load_places.dart';
import 'package:ketamiz/src/ui/auth/login_screen.dart';
import 'package:ketamiz/src/ui/language/language_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../menu/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;

  @override
  void initState() {
    super.initState();
    _setLanguage();
    LocationData.loadPlaces(context);
    _nextScreen();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1270),
    )..forward();
    offset = Tween<Offset>(
      begin: const Offset(0.0, 4.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.purple,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              const Spacer(),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LOADING...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: AppTheme.fontFamily,
                        letterSpacing: 0.14,
                        color: AppTheme.purple.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Center(
            child: SlideTransition(
              position: offset,
              child: const SizedBox(
                height: 60,
                child: Text(
                  'Qadam',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _setLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('language');
    if (savedLang != null && mounted) {
      final localizationDelegate = LocalizedApp.of(context).delegate;
      await localizationDelegate.changeLocale(Locale(savedLang));
    }
  }

  Future<void> _nextScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final hasLanguage = prefs.getString('language') != null;
    final isLoggedIn = !(prefs.getBool('isFirst') ?? true);

    Timer(
      const Duration(milliseconds: 2270),
      () {
        if (!mounted) return;
        Widget destination;
        if (!hasLanguage) {
          destination = const LanguageSelectionScreen();
        } else if (isLoggedIn) {
          destination = const MainScreen();
        } else {
          destination = const LoginScreen();
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
    );
  }
}
