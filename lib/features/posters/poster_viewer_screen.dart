import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pehchaan/core/api/event_queue.dart';
import 'package:pehchaan/core/api/image_store.dart';
import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/core/services/sales_contact.dart';
import 'package:pehchaan/core/state/session.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'branded_poster.dart';

/// The viewer/editor (§10). With a trial/active plan the design is
/// pre-filled with the shop's branding — the user only picks colours from
/// the slot's `color_options`. Without one it's the plain free design.
class PosterViewerScreen extends StatefulWidget {
  const PosterViewerScreen({super.key, required this.design});

  final Design design;

  @override
  State<PosterViewerScreen> createState() => _PosterViewerScreenState();
}

class _PosterViewerScreenState extends State<PosterViewerScreen> {
  final _boundaryKey = GlobalKey();
  final Map<String, String> _colors = {};

  File? _base;
  File? _logo;
  bool _loading = true;
  bool _busy = false;
  bool _personalizedLogged = false;

  Design get _design => widget.design;

  @override
  void initState() {
    super.initState();
    EventQueue.designView(_design.id);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final session = SessionScope.of(context, listen: false);
    final business = session.me?.business;
    final branded = session.me?.access.hasFullApp == true && business != null;

    final base = await ImageStore.file(_design.displayUrl, kind: 'd');
    File? logo;
    if (branded && business.logoUrl != null) {
      logo = await ImageStore.file(business.logoUrl!, kind: 'd');
    }
    // Decode up front so the captured PNG never has a blank layer.
    if (mounted && base != null) {
      try {
        await precacheImage(FileImage(base), context);
        if (logo != null && mounted) await precacheImage(FileImage(logo), context);
      } catch (_) {
        logo = null;
      }
    }
    if (!mounted) return;
    setState(() {
      _base = base;
      _logo = logo;
      _loading = false;
    });
  }

  Future<Uint8List?> _render(bool branded) async {
    final bytes = await renderPosterPng(_boundaryKey, _design);
    if (bytes != null && branded && !_personalizedLogged) {
      _personalizedLogged = true;
      EventQueue.personalizeComplete(_design.id);
    }
    return bytes == null ? null : Uint8List.fromList(bytes);
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _download(bool branded) async {
    setState(() => _busy = true);
    try {
      final bytes = await _render(branded);
      if (bytes == null) throw StateError('render failed');
      await Gal.putImageBytes(bytes, name: 'pehchaan_${DateTime.now().millisecondsSinceEpoch}');
      EventQueue.downloadComplete(_design.id);
      if (mounted) _snack('Gallery mein save ho gaya');
    } on GalException {
      if (mounted) _snack('Save nahi ho paya. Photos permission check karein.');
    } catch (_) {
      if (mounted) _snack('Save nahi ho paya. Dobara try karein.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share(bool branded) async {
    setState(() => _busy = true);
    try {
      final bytes = await _render(branded);
      if (bytes == null) throw StateError('render failed');
      // Fire the event once the share is invoked, never blocking it.
      final sharing = Share.shareXFiles([
        XFile.fromData(bytes, name: 'pehchaan.png', mimeType: 'image/png'),
      ]);
      EventQueue.shareComplete(_design.id);
      await sharing;
    } catch (_) {
      if (mounted) _snack('Share nahi ho paya. Dobara try karein.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final business = session.me?.business;
    final branded = session.me?.access.hasFullApp == true && business != null;
    final branding = branded
        ? PosterBranding.fromBusiness(business, logo: _logo)
        : null;

    final colourSlots = branded
        ? [
            for (final key in const ['name', 'message'])
              if (_design.slots[key]?.colorOptions.isNotEmpty == true) key,
          ]
        : const <String>[];

    return Scaffold(
      appBar: AppBar(),
      backgroundColor: AppColors.violet050,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Center(
                  child: _loading
                      ? const CircularProgressIndicator(color: AppColors.violet600)
                      : _base == null
                      ? Text(
                          'Poster load nahi hua. Internet check karke dobara kholiye.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body,
                        )
                      : AspectRatio(
                          aspectRatio: _design.aspectRatio,
                          child: Container(
                            decoration: const BoxDecoration(boxShadow: AppColors.softShadow),
                            child: FittedBox(
                              child: RepaintBoundary(
                                key: _boundaryKey,
                                child: BrandedPoster(
                                  design: _design,
                                  base: _base!,
                                  branding: branding,
                                  colors: _colors,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
            for (final key in colourSlots)
              _ColourRow(
                label: key == 'name' ? 'Naam ka rang' : 'Number ka rang',
                options: _design.slots[key]!.colorOptions,
                selected: _colors[key] ?? _design.slots[key]!.color,
                onSelected: (hex) => setState(() => _colors[key] = hex),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                children: [
                  if (!branded) ...[
                    _UpsellNote(
                      text: session.t(
                        'landing.branding_upsell',
                        'Is poster par apni shop ka naam, logo aur number lagwayein',
                      ),
                      onTap: () => contactSales(
                        context,
                        shopName: business?.shopName,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Download',
                          icon: Icons.download_rounded,
                          onPressed: _base == null || _busy ? null : () => _download(branded),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Share',
                          icon: Icons.share_rounded,
                          onPressed: _base == null || _busy ? null : () => _share(branded),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColourRow extends StatelessWidget {
  const _ColourRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: AppTextStyles.fieldLabel)),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final hex in options)
                  GestureDetector(
                    onTap: () => onSelected(hex),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: parseHexColor(hex) ?? Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hex.toLowerCase() == selected?.toLowerCase()
                              ? AppColors.violet600
                              : AppColors.divider,
                          width: hex.toLowerCase() == selected?.toLowerCase() ? 3 : 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpsellNote extends StatelessWidget {
  const _UpsellNote({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.violet200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.storefront_rounded, color: AppColors.violet600),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.fieldLabel.copyWith(
                  color: AppColors.violet900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.violet600),
          ],
        ),
      ),
    );
  }
}
