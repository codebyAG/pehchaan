import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/state/app_state.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'package:pehchaan/core/widgets/creative_preview_card.dart';
import 'creative_input_screen.dart';
import 'format_download_screen.dart';
import 'generating_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.category,
    required this.title,
    required this.priceText,
    this.format = CreativeFormat.post,
    this.imageBytes,
    this.aiRequest,
  });

  final CreativeCategory category;
  final String title;
  final String priceText;
  final CreativeFormat format;

  /// The real AI-generated image, when this result came from a real
  /// request. Null falls back to the synthetic text/price preview card
  /// (used by older mock call sites that have no image).
  final Uint8List? imageBytes;

  /// The original descriptive request sent to the AI, kept so
  /// "Regenerate" can ask for a real new image again.
  final String? aiRequest;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String _title = widget.title;
  late String _priceText = widget.priceText;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSave());
  }

  void _autoSave() {
    if (_saved) return;
    final business = AppStateScope.of(context).business;
    AppStateScope.of(context).addCreative(
      Creative(
        category: widget.category,
        title: _title,
        priceText: _priceText,
        businessName: business?.name ?? 'Your Business',
        phone: business?.phone.isNotEmpty == true
            ? business!.phone
            : '+91 98765 43210',
        format: widget.format,
        imageBytes: widget.imageBytes,
      ),
    );
    _saved = true;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved in My creatives')));
  }

  @override
  Widget build(BuildContext context) {
    final business = AppStateScope.of(context).business;
    final businessName = business?.name ?? 'Your Business';
    final phone = business?.phone.isNotEmpty == true
        ? business!.phone
        : '+91 98765 43210';

    return Scaffold(
      appBar: AppBar(title: const Text('Your creative')),
      backgroundColor: AppColors.violet050,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: CreativePreviewCard(
                          tag: widget.category.label,
                          title: _title,
                          priceText: _priceText,
                          businessName: businessName,
                          phone: phone,
                          logoBytes: business?.logoBytes,
                          aspectRatio: widget.format.aspectRatio,
                          imageBytes: widget.imageBytes,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) =>
                            CreativeInputScreen(category: widget.category),
                      ),
                    );
                  },
                  child: Text(
                    'Change format',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.violet600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      label: 'Regenerate',
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => GeneratingScreen(
                              category: widget.category,
                              title: _title,
                              priceText: _priceText,
                              format: widget.format,
                              aiRequest: widget.aiRequest,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PrimaryButton(
                      label: 'Download',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FormatDownloadScreen(
                              category: widget.category,
                              title: _title,
                              priceText: _priceText,
                              businessName: businessName,
                              phone: phone,
                              format: widget.format,
                              imageBytes: widget.imageBytes,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
