import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:pehchaan/core/services/image_picker_helper.dart';
import 'package:pehchaan/core/state/app_state.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'package:pehchaan/core/widgets/app_text_field.dart';

class EditBusinessScreen extends StatefulWidget {
  const EditBusinessScreen({super.key});

  @override
  State<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  late final _appState = AppStateScope.of(context, listen: false);
  late final _nameController = TextEditingController(
    text: _appState.business?.name,
  );
  late final _categoryController = TextEditingController(
    text: _appState.business?.category,
  );
  late final _phoneController = TextEditingController(
    text: _appState.business?.phone,
  );
  late final _cityController = TextEditingController(
    text: _appState.business?.city,
  );
  late final _areaController = TextEditingController(
    text: _appState.business?.area,
  );
  late final _addressController = TextEditingController(
    text: _appState.business?.address,
  );
  late Uint8List? _logoBytes = _appState.business?.logoBytes;

  Future<void> _pickLogo() async {
    final bytes = await pickImageFromGallery(maxDimension: 800);
    if (bytes != null) setState(() => _logoBytes = bytes);
  }

  void _removeLogo() => setState(() => _logoBytes = null);

  void _save() {
    final business = _appState.business;
    if (business == null) return;
    _appState.setupBusiness(
      business.copyWith(
        name: _nameController.text.trim(),
        category: _categoryController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        address: _addressController.text.trim(),
        logoBytes: _logoBytes,
        clearLogo: _logoBytes == null,
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Business update ho gaya')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit business')),
      backgroundColor: AppColors.violet050,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text('Business logo', style: AppTextStyles.fieldLabel),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        InkWell(
                          onTap: _pickLogo,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.violet100,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: _logoBytes != null
                                ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                                : const Icon(Icons.add_rounded, color: AppColors.violet600),
                          ),
                        ),
                        const SizedBox(width: 14),
                        TextButton(
                          onPressed: _pickLogo,
                          child: Text(
                            _logoBytes != null ? 'Replace' : 'Upload logo',
                            style: AppTextStyles.body.copyWith(color: AppColors.violet600, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (_logoBytes != null)
                          TextButton(
                            onPressed: _removeLogo,
                            child: Text(
                              'Remove',
                              style: AppTextStyles.body.copyWith(color: const Color(0xFFD94A2B)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Business name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Category',
                      controller: _categoryController,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Phone to show on creatives',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(label: 'City', controller: _cityController),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Area / market name',
                      controller: _areaController,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Full address (optional)',
                      controller: _addressController,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Save changes', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
