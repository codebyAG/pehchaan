import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'contact_support_screen.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final _searchController = TextEditingController();
  int? _expanded;

  static const _faqs = [
    (
      'Creative kaise banaye?',
      'Home par category choose karein, details bharein aur "Generate creative" dabayein.',
    ),
    (
      'Photo kaise upload karein?',
      'Creative input screen par photo strip mein "+" par tap karein.',
    ),
    (
      'Download kahan jata hai?',
      'Aapki phone ki Gallery ke "Pehchaan" folder mein.',
    ),
    (
      'Instagram par kaise post karein?',
      'Download screen par "Share on Instagram" choose karein.',
    ),
    (
      'Language kaise badle?',
      'Profile > Language mein jaakar apni pasand ki language choose karein.',
    ),
    ('Refund policy', 'Pehchaan free plan par refund applicable nahi hai.'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Apna sawaal search karein',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.mutedText,
                  ),
                  filled: true,
                  fillColor: AppColors.violet100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.violet600,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _faqs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final expanded = _expanded == i;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.violet100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () =>
                                setState(() => _expanded = expanded ? null : i),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _faqs[i].$1,
                                    style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  expanded
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  color: AppColors.violet600,
                                ),
                              ],
                            ),
                          ),
                          if (expanded) ...[
                            const SizedBox(height: 8),
                            Text(_faqs[i].$2, style: AppTextStyles.fieldLabel),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text('Aur madad chahiye?', style: AppTextStyles.body),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Contact support',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ContactSupportScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
