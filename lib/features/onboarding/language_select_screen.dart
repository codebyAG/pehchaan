import 'package:flutter/material.dart';

import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

/// First launch, before login (§4). The list comes from `/v1/languages`
/// with a bundled fallback so it's never empty.
class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({
    super.key,
    required this.languages,
    required this.onContinue,
    this.initial,
    this.showBack = false,
  });

  final List<Language> languages;
  final ValueChanged<String> onContinue;
  final String? initial;
  final bool showBack;

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  late String? _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final languages = widget.languages.isEmpty ? Language.bundled : widget.languages;
    return Scaffold(
      appBar: widget.showBack ? AppBar(leading: const BackButton()) : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('भाषा चुनें · Choose language', style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              Text(
                'Aap ise baad mein Settings mein badal sakte hain.',
                style: AppTextStyles.fieldLabel,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: languages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final lang = languages[i];
                    return _LanguageRow(
                      label: lang.label,
                      labelEn: lang.label == lang.labelEn ? null : lang.labelEn,
                      selected: _selected == lang.code,
                      onTap: () => setState(() => _selected = lang.code),
                    );
                  },
                ),
              ),
              PrimaryButton(
                label: 'Continue',
                onPressed: _selected == null
                    ? null
                    : () => widget.onContinue(_selected!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.labelEn,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? labelEn;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.violet900;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.violet600 : AppColors.violet100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  if (labelEn != null)
                    Text(
                      labelEn!,
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: selected ? AppColors.textOnViolet : AppColors.mutedText,
                      ),
                    ),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
