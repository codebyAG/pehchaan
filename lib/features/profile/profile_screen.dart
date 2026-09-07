import 'package:flutter/material.dart';

import 'package:pehchaan/core/state/app_state.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/rate_prompt_dialog.dart';
import 'about_screen.dart';
import 'contact_support_screen.dart';
import 'edit_business_screen.dart';
import 'help_faq_screen.dart';
import 'language_change_screen.dart';
import 'manage_photos_screen.dart';
import 'package:pehchaan/features/library/my_creatives_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log out karna hai?', style: AppTextStyles.sectionHeading),
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
              'Log out',
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
    final appState = AppStateScope.of(context);
    final business = appState.business;
    final creativeCount = appState.savedCreatives.length;
    final thisMonth = appState.savedCreatives
        .where(
          (c) =>
              c.createdAt.month == DateTime.now().month &&
              c.createdAt.year == DateTime.now().year,
        )
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.violet100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.violet200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      business != null && business.name.isNotEmpty
                          ? business.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.violet600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business?.name ?? 'Your Business',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.violet900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${business?.category ?? ''} · ${business?.location ?? ''}',
                          style: AppTextStyles.fieldLabel,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditBusinessScreen(),
                      ),
                    ),
                    child: Text(
                      'Edit',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.violet600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Creatives banaye',
                    value: '$creativeCount',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(label: 'Is mahine', value: '$thisMonth'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(label: 'Saved', value: '$creativeCount'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Row(
              icon: Icons.image_rounded,
              label: 'My creatives',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyCreativesScreen()),
              ),
            ),
            _Row(
              icon: Icons.photo_library_rounded,
              label: 'Manage photos',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManagePhotosScreen()),
              ),
            ),
            _Row(
              icon: Icons.language_rounded,
              label: 'Language',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LanguageChangeScreen()),
              ),
            ),
            _Row(
              icon: Icons.settings_rounded,
              label: 'Settings',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            _Row(
              icon: Icons.help_rounded,
              label: 'Help & FAQ',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HelpFaqScreen())),
            ),
            _Row(
              icon: Icons.support_agent_rounded,
              label: 'Contact support',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
              ),
            ),
            _Row(
              icon: Icons.star_rounded,
              label: 'Rate Pehchaan',
              onTap: () => RatePromptDialog.show(context),
            ),
            _Row(
              icon: Icons.share_rounded,
              label: 'Share Pehchaan',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share sheet khul raha hai')),
              ),
            ),
            _Row(
              icon: Icons.info_rounded,
              label: 'About',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => _confirmLogout(context),
                child: Text(
                  'Log out',
                  style: AppTextStyles.body.copyWith(
                    color: const Color(0xFFD94A2B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                'v1.0.0',
                style: AppTextStyles.fieldLabel.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.violet050,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.violet900,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.fieldLabel),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.violet600, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText),
          ],
        ),
      ),
    );
  }
}
