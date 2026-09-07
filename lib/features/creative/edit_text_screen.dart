import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'package:pehchaan/core/widgets/app_chip.dart';
import 'package:pehchaan/core/widgets/app_text_field.dart';
import 'package:pehchaan/core/widgets/creative_preview_card.dart';

enum _TextSize { s, m, l }

class EditTextScreen extends StatefulWidget {
  const EditTextScreen({
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
  State<EditTextScreen> createState() => _EditTextScreenState();
}

class _EditTextScreenState extends State<EditTextScreen> {
  late final _headlineController = TextEditingController(text: widget.title);
  late final _priceController = TextEditingController(text: widget.priceText);
  final _subController = TextEditingController();
  late final _businessController = TextEditingController(text: widget.businessName);
  late final _phoneController = TextEditingController(text: widget.phone);
  _TextSize _size = _TextSize.m;

  @override
  void initState() {
    super.initState();
    for (final c in [_headlineController, _priceController, _subController, _businessController, _phoneController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _priceController.dispose();
    _subController.dispose();
    _businessController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text edit karein')),
      backgroundColor: AppColors.violet050,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 260,
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    child: CreativePreviewCard(
                      tag: widget.category.label,
                      title: _headlineController.text,
                      priceText: _priceController.text,
                      businessName: _businessController.text,
                      phone: _phoneController.text,
                      aspectRatio: widget.format.aspectRatio,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    AppTextField(label: 'Headline', controller: _headlineController),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Offer / price line', controller: _priceController),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Sub line', controller: _subController),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Business name', controller: _businessController),
                    const SizedBox(height: 12),
                    AppTextField(label: 'Phone', controller: _phoneController),
                    const SizedBox(height: 16),
                    Text('Text size', style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: [
                        AppChip(label: 'S', selected: _size == _TextSize.s, onTap: () => setState(() => _size = _TextSize.s)),
                        AppChip(label: 'M', selected: _size == _TextSize.m, onTap: () => setState(() => _size = _TextSize.m)),
                        AppChip(label: 'L', selected: _size == _TextSize.l, onTap: () => setState(() => _size = _TextSize.l)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Save changes',
                onPressed: () => Navigator.of(context).pop((_headlineController.text, _priceController.text)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
