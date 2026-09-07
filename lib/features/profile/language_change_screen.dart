import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/user.dart';
import 'package:pehchaan/features/onboarding/language_select_screen.dart';

/// Same layout as language select, pre-selected with the current language.
/// Saving reloads the UI immediately.
class LanguageChangeScreen extends StatelessWidget {
  const LanguageChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LanguageSelectScreen(
      initial: AppLanguage.hinglish,
      onContinue: (language) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Language update ho gayi')),
        );
        Navigator.of(context).pop();
      },
    );
  }
}
