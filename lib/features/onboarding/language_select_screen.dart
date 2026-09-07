import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/user.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';

/// Set app + creative language before anything else.
class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({
    super.key,
    required this.onContinue,
    this.initial,
  });

  final ValueChanged<AppLanguage> onContinue;
  final AppLanguage? initial;

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  late AppLanguage? _selected = widget.initial ?? AppLanguage.hinglish;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose your language', style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              Text(
                'Aap ise baad mein badal sakte hain.',
                style: AppTextStyles.fieldLabel,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    for (final lang in AppLanguage.values) ...[
                      _LanguageRow(
                        label: lang.label,
                        selected: _selected == lang,
                        onTap: () => setState(() => _selected = lang),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _LanguageRow(
                      label: 'मराठी',
                      selected: false,
                      disabled: true,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _LanguageRow(
                      label: 'ગુજરાતી',
                      selected: false,
                      disabled: true,
                      onTap: () {},
                    ),
                  ],
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
    required this.selected,
    required this.onTap,
    this.disabled = false,
  });

  final String label;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: selected ? AppColors.violet600 : AppColors.violet100,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.violet900,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded, color: Colors.white)
              else if (disabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.violet200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Soon',
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: AppColors.violet600,
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
