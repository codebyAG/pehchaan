import 'dart:async';

import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'result_screen.dart';

/// Full-screen violet state shown while the creative is being produced.
/// No percentages, no AI/model names — just rotating status lines and an
/// indeterminate yellow bar.
class GeneratingScreen extends StatefulWidget {
  const GeneratingScreen({
    super.key,
    required this.category,
    required this.title,
    required this.priceText,
    this.format = CreativeFormat.post,
  });

  final CreativeCategory category;
  final String title;
  final String priceText;
  final CreativeFormat format;

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen> {
  static const _statuses = ['Design choose kar rahe hain', 'Text likh rahe hain', 'Final touch'];
  int _statusIndex = 0;
  Timer? _statusTimer;
  Timer? _doneTimer;

  @override
  void initState() {
    super.initState();
    _statusTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted) return;
      setState(() => _statusIndex = (_statusIndex + 1) % _statuses.length);
    });
    _doneTimer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            category: widget.category,
            title: widget.title,
            priceText: widget.priceText,
            format: widget.format,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _doneTimer?.cancel();
    super.dispose();
  }

  void _cancel() {
    _doneTimer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet600,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.violet600, size: 32),
              ),
              const SizedBox(height: 28),
              Text(
                'Aapka creative ban raha hai…',
                textAlign: TextAlign.center,
                style: AppTextStyles.sectionHeading.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                _statuses[_statusIndex],
                textAlign: TextAlign.center,
                style: AppTextStyles.fieldLabel.copyWith(color: AppColors.textOnViolet),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Colors.white24,
                    color: AppColors.yellow500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _cancel,
                child: Text('Cancel', style: AppTextStyles.body.copyWith(color: Colors.white60)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
