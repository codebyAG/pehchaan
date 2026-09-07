import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'language_change_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _festivalReminders = true;
  bool _offerIdeas = true;
  bool _autoSaveGallery = false;
  double _cacheMb = 12;

  void _clearCache() {
    setState(() => _cacheMb = 0);
    _snack('Cache clear ho gaya');
  }

  void _snack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Account delete kar dein?',
          style: AppTextStyles.sectionHeading,
        ),
        content: Text(
          'Yeh action wapas nahi ho sakta.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(color: AppColors.violet600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Delete',
              style: AppTextStyles.body.copyWith(
                color: const Color(0xFFD94A2B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            _SwitchRow(
              label: 'Festival reminders',
              value: _festivalReminders,
              onChanged: (v) => setState(() => _festivalReminders = v),
            ),
            _SwitchRow(
              label: 'Offer ideas notification',
              value: _offerIdeas,
              onChanged: (v) => setState(() => _offerIdeas = v),
            ),
            _SwitchRow(
              label: 'Save to gallery automatically',
              value: _autoSaveGallery,
              onChanged: (v) => setState(() => _autoSaveGallery = v),
            ),
            const SizedBox(height: 8),
            _Row(
              label: 'Language',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageChangeScreen()),
              ),
            ),
            _Row(
              label: 'Clear cache (${_cacheMb.toStringAsFixed(0)} MB)',
              onTap: _clearCache,
            ),
            _Row(
              label: 'Privacy Policy',
              onTap: () => _snack('Privacy Policy khul rahi hai'),
            ),
            _Row(
              label: 'Terms of Service',
              onTap: () => _snack('Terms of Service khul rahe hain'),
            ),
            const SizedBox(height: 16),
            _Row(label: 'Delete account', danger: true, onTap: _confirmDelete),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.violet600,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.onTap, this.danger = false});

  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: danger ? const Color(0xFFD94A2B) : AppColors.violet900,
                ),
              ),
            ),
            if (!danger)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.mutedText,
              ),
          ],
        ),
      ),
    );
  }
}
