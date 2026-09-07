import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'package:pehchaan/core/widgets/app_chip.dart';
import 'package:pehchaan/core/widgets/app_text_field.dart';
import 'generating_screen.dart';
import 'photo_picker_screen.dart';

enum CreativeLanguage { hinglish, hindi, english }

extension on CreativeLanguage {
  String get label {
    switch (this) {
      case CreativeLanguage.hinglish:
        return 'Hinglish';
      case CreativeLanguage.hindi:
        return 'हिंदी';
      case CreativeLanguage.english:
        return 'English';
    }
  }
}

class CreativeInputScreen extends StatefulWidget {
  const CreativeInputScreen({super.key, required this.category});

  final CreativeCategory category;

  @override
  State<CreativeInputScreen> createState() => _CreativeInputScreenState();
}

class _CreativeInputScreenState extends State<CreativeInputScreen> {
  final _primaryController = TextEditingController();
  final _priceController = TextEditingController();
  final _secondaryController = TextEditingController();

  CreativeFormat _format = CreativeFormat.post;
  CreativeLanguage _language = CreativeLanguage.hinglish;
  final List<String> _photos = [];

  @override
  void dispose() {
    _primaryController.dispose();
    _priceController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  String get _screenTitle {
    switch (widget.category) {
      case CreativeCategory.offer:
        return 'Create offer';
      case CreativeCategory.festival:
        return 'Create festival creative';
      case CreativeCategory.product:
        return 'Create product creative';
      case CreativeCategory.service:
        return 'Create service creative';
      case CreativeCategory.newArrival:
        return 'Create new arrival';
      case CreativeCategory.announcement:
        return 'Create announcement';
    }
  }

  void _addPhoto() async {
    final photo = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const PhotoPickerScreen()),
    );
    if (photo != null) setState(() => _photos.add(photo));
  }

  void _generate() {
    final title = _primaryController.text.trim().isEmpty
        ? '${widget.category.label} Special'
        : _primaryController.text.trim();
    final priceText = _priceController.text.trim().isEmpty ? '₹999' : '₹${_priceController.text.trim()}';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GeneratingScreen(
          category: widget.category,
          title: title,
          priceText: priceText,
          format: _format,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_screenTitle)),
      backgroundColor: AppColors.violet050,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ..._typeFields(),
                    const SizedBox(height: 24),
                    Text('Format', style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final f in CreativeFormat.values)
                          AppChip(
                            label: f == CreativeFormat.post
                                ? 'Insta post'
                                : f.label,
                            selected: _format == f,
                            onTap: () => setState(() => _format = f),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Language', style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final l in CreativeLanguage.values)
                          AppChip(
                            label: l.label,
                            selected: _language == l,
                            onTap: () => setState(() => _language = l),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pehchaan aapke business ki details khud add kar lega.',
                      style: AppTextStyles.fieldLabel,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AccentButton(label: 'Generate creative', onPressed: _generate),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _typeFields() {
    switch (widget.category) {
      case CreativeCategory.offer:
        return [
          AppTextField(label: 'Offer text', hint: 'e.g. Shirt + Pant Stitching', controller: _primaryController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(label: 'Price', hint: '999', controller: _priceController, keyboardType: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(label: 'Occasion', hint: 'e.g. Diwali', controller: _secondaryController),
              ),
            ],
          ),
        ];
      case CreativeCategory.festival:
        return [
          Text('Festival', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final f in ['Diwali', 'Holi', 'Eid', 'Rakhi', 'Christmas'])
                AppChip(label: f, selected: _secondaryController.text == f, onTap: () => setState(() => _secondaryController.text = f)),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(label: 'Greeting or offer text', hint: 'e.g. Festive Special', controller: _primaryController),
          const SizedBox(height: 16),
          AppTextField(label: 'Price (optional)', hint: '999', controller: _priceController, keyboardType: TextInputType.number),
        ];
      case CreativeCategory.product:
        return [
          AppTextField(label: 'Product name', hint: 'e.g. Festive Saree', controller: _primaryController),
          const SizedBox(height: 16),
          AppTextField(label: 'Price', hint: '999', controller: _priceController, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _photoStrip(),
        ];
      case CreativeCategory.service:
        return [
          AppTextField(label: 'Service name', hint: 'e.g. Hair Spa', controller: _primaryController),
          const SizedBox(height: 16),
          AppTextField(label: 'Starting price', hint: '499', controller: _priceController, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          AppTextField(label: 'One benefit line', hint: 'e.g. Perfect fit, quality service', controller: _secondaryController),
        ];
      case CreativeCategory.newArrival:
        return [
          AppTextField(label: 'Collection / product name', hint: 'e.g. Festive Collection 2026', controller: _primaryController),
          const SizedBox(height: 16),
          _photoStrip(),
          const SizedBox(height: 16),
          AppTextField(label: 'One line', hint: 'e.g. Visit our store', controller: _secondaryController),
        ];
      case CreativeCategory.announcement:
        return [
          Text('What to announce', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          TextField(
            controller: _primaryController,
            maxLines: 3,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'e.g. Shop will remain closed on Monday',
              filled: true,
              fillColor: AppColors.violet100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.violet600, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(label: 'Date / time (optional)', hint: 'e.g. 12 Oct, 10 AM', controller: _secondaryController),
        ];
    }
  }

  Widget _photoStrip() {
    return SizedBox(
      height: 84,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final _ in _photos)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(color: AppColors.violet200, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.image_rounded, color: AppColors.violet600),
              ),
            ),
          InkWell(
            onTap: _addPhoto,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.violet100, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.add_rounded, color: AppColors.violet600),
            ),
          ),
        ],
      ),
    );
  }
}
