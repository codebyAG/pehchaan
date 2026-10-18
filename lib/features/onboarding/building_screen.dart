import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pehchaan/core/state/session.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

/// Shown after the first onboarding submit (`201`). If a personalised
/// welcome video is generating, polls `GET /v1/me` until it's ready, fails
/// or times out; otherwise holds a few seconds for effect (§8.4).
class BuildingScreen extends StatefulWidget {
  const BuildingScreen({super.key});

  @override
  State<BuildingScreen> createState() => _BuildingScreenState();
}

class _BuildingScreenState extends State<BuildingScreen> {
  static const _holdFor = Duration(seconds: 4);
  static const _pollEvery = Duration(seconds: 3);
  static const _pollFor = Duration(seconds: 90);

  static const _lines = [
    'Aapki shop ki details padh rahe hain',
    'Aapke liye posters chun rahe hain',
    'Aapka naam aur number laga rahe hain',
    'Bas ho gaya…',
  ];

  Timer? _lineTimer;
  int _line = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _lineTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted) setState(() => _line = (_line + 1) % _lines.length);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final session = SessionScope.of(context, listen: false);
    final video = session.me?.welcomeVideo;

    if (video == null || !video.isPending) {
      await Future<void>.delayed(_holdFor);
    } else {
      final deadline = DateTime.now().add(_pollFor);
      while (mounted && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(_pollEvery);
        if (!mounted) return;
        await session.refreshMe();
        final v = session.me?.welcomeVideo;
        // `ready` → landing/home plays it; `failed` → go anyway with the
        // fallback video.
        if (v == null || !v.isPending) break;
      }
    }
    _finish(session);
  }

  void _finish(SessionController session) {
    if (_done || !mounted) return;
    _done = true;
    session.finishBuilding();
  }

  @override
  void dispose() {
    _lineTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final shop = session.me?.business?.shopName;
    return Scaffold(
      backgroundColor: AppColors.violet600,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    color: AppColors.yellow500,
                    strokeWidth: 5,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  shop != null
                      ? session.t(
                          'building.title_shop',
                          '$shop ke liye kuch khaas bana rahe hain…',
                        ).replaceAll('{shop}', shop)
                      : session.t('building.title', 'Aapke liye kuch khaas bana rahe hain…'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionHeading.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _lines[_line],
                    key: ValueKey(_line),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.fieldLabel.copyWith(color: AppColors.textOnViolet),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
