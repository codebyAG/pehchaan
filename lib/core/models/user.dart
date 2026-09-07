enum AppLanguage { hindi, hinglish, english }

extension AppLanguageLabel on AppLanguage {
  String get label {
    switch (this) {
      case AppLanguage.hindi:
        return 'हिंदी';
      case AppLanguage.hinglish:
        return 'Hinglish';
      case AppLanguage.english:
        return 'English';
    }
  }
}

enum AppPlan { free, paid }

class AppUser {
  const AppUser({required this.phone, this.language = AppLanguage.hinglish, this.plan = AppPlan.free});

  final String phone;
  final AppLanguage language;
  final AppPlan plan;

  AppUser copyWith({String? phone, AppLanguage? language, AppPlan? plan}) {
    return AppUser(
      phone: phone ?? this.phone,
      language: language ?? this.language,
      plan: plan ?? this.plan,
    );
  }
}
