import 'package:flutter/material.dart';

import 'package:pehchaan/core/state/session.dart';
import 'package:pehchaan/features/onboarding/language_select_screen.dart';

/// Same layout as language select, pre-selected with the current language.
/// Saving refetches content for the new language and mirrors the choice to
/// the account (§4).
class LanguageChangeScreen extends StatelessWidget {
  const LanguageChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return LanguageSelectScreen(
      languages: session.languages,
      initial: session.lang,
      showBack: true,
      onContinue: (code) {
        session.chooseLanguage(code);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Language update ho gayi')),
        );
        Navigator.of(context).pop();
      },
    );
  }
}
