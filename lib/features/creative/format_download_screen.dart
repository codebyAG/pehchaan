import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'success_screen.dart';

class FormatDownloadScreen extends StatefulWidget {
  const FormatDownloadScreen({
    super.key,
    required this.category,
    required this.title,
    required this.priceText,
    required this.businessName,
    required this.phone,
    this.format = CreativeFormat.post,
  });

  final CreativeCategory category;
  final String title;
  final String priceText;
  final String businessName;
  final String phone;
  final CreativeFormat format;

  @override
  State<FormatDownloadScreen> createState() => _FormatDownloadScreenState();
}

class _FormatDownloadScreenState extends State<FormatDownloadScreen> {
  late CreativeFormat _selectedFormat = widget.format;

  void _saveToPhone() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Gallery mein save ho gaya')));
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SuccessScreen()));
  }

  void _share(String appName) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$appName khul raha hai')));
  }

  void _moreApps() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share sheet khul raha hai')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Format & download')),
      backgroundColor: AppColors.violet050,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            Text('Choose the size you need', style: AppTextStyles.screenTitle),
            const SizedBox(height: 20),
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: CreativeFormat.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final f = CreativeFormat.values[i];
                  return _FormatTile(
                    format: f,
                    selected: _selectedFormat == f,
                    onTap: () => setState(() => _selectedFormat = f),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Text('Save & share', style: AppTextStyles.sectionHeading),
            const SizedBox(height: 12),
            _ActionRow(
              icon: Icons.download_rounded,
              label: 'Save to phone',
              onTap: _saveToPhone,
            ),
            const SizedBox(height: 12),
            _ActionRow(
              icon: Icons.chat_bubble_rounded,
              label: 'Share on WhatsApp',
              onTap: () => _share('WhatsApp'),
            ),
            const SizedBox(height: 12),
            _ActionRow(
              icon: Icons.camera_alt_rounded,
              label: 'Share on Instagram',
              onTap: () => _share('Instagram'),
            ),
            const SizedBox(height: 12),
            _ActionRow(
              icon: Icons.more_horiz_rounded,
              label: 'More apps',
              onTap: _moreApps,
            ),
            const SizedBox(height: 20),
            Text(
              'Pehchaan aapki taraf se kuch post nahi karta — control aapke paas rehta hai.',
              style: AppTextStyles.fieldLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatTile extends StatelessWidget {
  const _FormatTile({
    required this.format,
    required this.selected,
    required this.onTap,
  });

  final CreativeFormat format;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = format == CreativeFormat.post
        ? 130.0
        : (format == CreativeFormat.poster ? 118.0 : 96.0);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.violet600 : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: format.aspectRatio,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.violet200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              format.label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            Text(format.ratioLabel, style: AppTextStyles.fieldLabel),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.violet100,
          borderRadius: BorderRadius.circular(16),
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
