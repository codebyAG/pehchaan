import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/business.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'package:pehchaan/core/widgets/app_text_field.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({
    super.key,
    required this.onComplete,
    this.prefilledPhone = '',
  });

  final ValueChanged<Business> onComplete;
  final String prefilledPhone;

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  int _step = 1;

  final _nameController = TextEditingController();
  late final _phoneController = TextEditingController(text: widget.prefilledPhone);
  String? _category;

  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();

  final List<String> _photos = [];

  static const _categories = [
    'Tailor', 'Salon', 'Barber shop', 'Boutique', 'Kirana', 'Sweet shop',
    'Mechanic', 'Mobile repair', 'Beauty parlour', 'Home business',
    'Food / restaurant', 'Mehndi artist', 'Photographer', 'Retail shop', 'Other service',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _pickCategory() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final c in _categories)
                  ListTile(
                    title: Text(c, style: AppTextStyles.body),
                    onTap: () => Navigator.of(context).pop(c),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null) setState(() => _category = selected);
  }

  void _useMyLocation() {
    setState(() {
      _cityController.text = 'Mumbai';
      _areaController.text = 'Andheri West';
    });
  }

  void _finish() {
    widget.onComplete(
      Business(
        name: _nameController.text.trim().isEmpty ? 'Mera Business' : _nameController.text.trim(),
        category: _category ?? 'Business',
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        address: _addressController.text.trim(),
        photos: _photos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text('Step $_step of 3', style: AppTextStyles.fieldLabel),
              ),
              const SizedBox(height: 8),
              Text(_title(), style: AppTextStyles.screenTitle),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(child: _stepBody()),
              ),
              const SizedBox(height: 12),
              _bottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  String _title() {
    switch (_step) {
      case 1:
        return 'Tell us about your shop';
      case 2:
        return 'Aapki shop kahan hai?';
      default:
        return 'Shop aur product ki photos';
    }
  }

  Widget _stepBody() {
    switch (_step) {
      case 1:
        return _stepOne();
      case 2:
        return _stepTwo();
      default:
        return _stepThree();
    }
  }

  Widget _stepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(label: 'Business name', hint: 'e.g. Raju Tailor', controller: _nameController),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Category',
          hint: 'Select category',
          readOnly: true,
          controller: TextEditingController(text: _category ?? ''),
          suffixIcon: const Icon(Icons.expand_more_rounded, color: AppColors.mutedText),
          onTap: _pickCategory,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Phone to show on creatives',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _stepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecondaryButton(
          label: 'Use my location',
          icon: Icons.location_on_rounded,
          onPressed: _useMyLocation,
        ),
        const SizedBox(height: 16),
        AppTextField(label: 'City', hint: 'e.g. Mumbai', controller: _cityController),
        const SizedBox(height: 16),
        AppTextField(label: 'Area / market name', hint: 'e.g. Andheri West', controller: _areaController),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Full address (optional)',
          hint: 'Shop no, street, landmark',
          controller: _addressController,
        ),
        const SizedBox(height: 8),
        Text('Yeh address creatives ke bottom par aayega.', style: AppTextStyles.fieldLabel),
      ],
    );
  }

  Widget _stepThree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('2–3 photos se creative achha banta hai.', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(3, (i) {
            final filled = i < _photos.length;
            return _PhotoSlot(
              filled: filled,
              onTap: () => setState(() => _photos.add('photo_$i')),
              onRemove: filled ? () => setState(() => _photos.removeAt(i)) : null,
            );
          }),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.violet100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.violet600),
            ),
            const SizedBox(width: 12),
            Text('Add your logo (optional)', style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 24),
        Text('Brand colour (optional)', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final c in [AppColors.violet600, AppColors.yellow500, AppColors.violet900, Colors.teal, Colors.pink])
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.violet100,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Use Pehchaan colours',
                style: AppTextStyles.fieldLabel.copyWith(color: AppColors.violet600, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bottomActions() {
    if (_step == 1) {
      return PrimaryButton(label: 'Continue', onPressed: () => setState(() => _step = 2));
    }
    if (_step == 2) {
      return Column(
        children: [
          PrimaryButton(label: 'Continue', onPressed: () => setState(() => _step = 3)),
          TextButton(
            onPressed: () => setState(() => _step = 3),
            child: Text('Skip', style: AppTextStyles.body.copyWith(color: AppColors.mutedText)),
          ),
        ],
      );
    }
    return Column(
      children: [
        PrimaryButton(label: 'Finish setup', onPressed: _finish),
        TextButton(
          onPressed: _finish,
          child: Text('Skip for now', style: AppTextStyles.body.copyWith(color: AppColors.mutedText)),
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  const _PhotoSlot({required this.filled, required this.onTap, this.onRemove});

  final bool filled;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return Stack(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: AppColors.violet200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.storefront_rounded, color: AppColors.violet600, size: 32),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.violet900, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: const Color(0xFFB9A6F0), radius: 16),
        child: Container(
          width: 104,
          height: 104,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.violet050,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add_rounded, color: AppColors.violet600, size: 26),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}
