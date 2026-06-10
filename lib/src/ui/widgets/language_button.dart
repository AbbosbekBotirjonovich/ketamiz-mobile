import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../resources/repository.dart';
import '../../theme/app_theme.dart';
import 'texts/text_16h_500w.dart';

const _kLanguages = [
  {'code': 'uz', 'name': "O'zbek", 'flag': '🇺🇿'},
  {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
  {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
];

String _flagFor(String code) => _kLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => _kLanguages.first,
    )['flag']!;

/// A circular flag button (sized to match the notification bell) that opens a
/// language picker. Lets users switch language from the top bar instead of
/// hunting for it in the profile section.
class LanguageButton extends StatefulWidget {
  const LanguageButton({super.key, this.size = 44});

  final double size;

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  String _code = 'uz';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _code = prefs.getString('language') ?? 'uz');
  }

  Future<void> _openPicker() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LanguagePickerSheet(currentCode: _code),
    );
    // Refresh the flag in case the user changed the language.
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openPicker,
      child: Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          _flagFor(_code),
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
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
    // Best-effort sync of language to the backend.
    try {
      Repository().fetchUpdateLanguage(_selected);
    } catch (_) {}
    if (!mounted) return;
    await changeLocale(context, _selected);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: AppTheme.gray,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text16h500w(title: translate("profile.language")),
            const SizedBox(height: 20),
            ..._kLanguages.map(
              (lang) => GestureDetector(
                onTap: () => setState(() => _selected = lang['code']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              ),
            ),
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
      ),
    );
  }
}
