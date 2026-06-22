import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../theme/app_theme.dart';
import '../../../utils/terms_data.dart';
import '../../widgets/containers/leading_back.dart';
import '../../widgets/texts/text_14h_400w.dart';
import '../../widgets/texts/text_16h_500w.dart';
import '../../widgets/texts/text_18h_500w.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  TermsContent? _terms;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'uz';
    if (mounted) setState(() => _terms = termsForLanguage(lang));
  }

  @override
  Widget build(BuildContext context) {
    final terms = _terms;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const LeadingBack(),
        title: Text16h500w(title: translate("profile.terms")),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: terms == null
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.purple),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                Text18h500w(title: terms.title),
                const SizedBox(height: 8),
                Text14h400w(title: terms.subtitle, color: AppTheme.gray),
                const SizedBox(height: 20),
                ...terms.sections.map(_buildSection),
              ],
            ),
    );
  }

  Widget _buildSection(TermsSection section) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: AppTheme.black.withOpacity(0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text16h500w(title: section.title),
          const SizedBox(height: 10),
          ...section.content.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7, right: 10),
                    height: 5,
                    width: 5,
                    decoration: const BoxDecoration(
                      color: AppTheme.purple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.dark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
