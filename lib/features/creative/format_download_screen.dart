import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

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
    this.imageBytes,
  });

  final CreativeCategory category;
  final String title;
  final String priceText;
  final String businessName;
  final String phone;
  final CreativeFormat format;
  final Uint8List? imageBytes;

  @override
  State<FormatDownloadScreen> createState() => _FormatDownloadScreenState();
}

class _FormatDownloadScreenState extends State<FormatDownloadScreen> {
  late CreativeFormat _selectedFormat = widget.format;
  bool _busy = false;

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveToPhone() async {
    final bytes = widget.imageBytes;
    if (bytes == null) {
      _snack('Yeh creative save nahi ho sakti (koi real image nahi hai).');
      return;
    }
    setState(() => _busy = true);
    try {
      await Gal.putImageBytes(bytes, name: 'pehchaan_${DateTime.now().millisecondsSinceEpoch}');
      if (!mounted) return;
      _snack('Gallery mein save ho gaya');
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SuccessScreen()));
    } on GalException {
      if (!mounted) return;
      _snack('Save nahi ho paya. Photos permission check karein.');
    } catch (_) {
      if (!mounted) return;
      _snack('Save nahi ho paya. Dobara try karein.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    final bytes = widget.imageBytes;
    if (bytes == null) {
      _snack('Yeh creative share nahi ho sakti (koi real image nahi hai).');
      return;
    }
    try {
      await Share.shareXFiles(
        [XFile.fromData(bytes, name: 'pehchaan.png', mimeType: 'image/png')],
        text: widget.title,
      );
    } catch (_) {
      if (!mounted) return;
      _snack('Share nahi ho paya. Dobara try karein.');
    }
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
              label: _busy ? 'Saving…' : 'Save to phone',
              onTap: _busy ? null : _saveToPhone,
            ),
            const SizedBox(height: 12),
            _ActionRow(
              icon: Icons.chat_bubble_rounded,
              label: 'Share on WhatsApp',
              onTap: _share,
            ),
            const SizedBox(height: 12),
            _ActionRow(
              icon: Icons.camera_alt_rounded,
              label: 'Share on Instagram',
              onTap: _share,
            ),
            const SizedBox(height: 12),
            _ActionRow(
              icon: Icons.more_horiz_rounded,
              label: 'More apps',
              onTap: _share,
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
  final VoidCallback? onTap;

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
