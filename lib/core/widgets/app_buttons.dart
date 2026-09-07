import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

/// Fill #6614F5, white label. The default call-to-action everywhere in the app.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet600,
              disabledBackgroundColor: AppColors.violet600.withValues(
                alpha: 0.4,
              ),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.all(AppColors.violetPressed),
            ),
        child: _ButtonContent(label: label, icon: icon, color: Colors.white),
      ),
    );
  }
}

/// Fill #FBBA1B, ink label. Reserved for the "Generate creative" action.
class AccentButton extends StatelessWidget {
  const AccentButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.yellow500,
          foregroundColor: AppColors.violet900,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _ButtonContent(
          label: label,
          icon: icon,
          color: AppColors.violet900,
          weight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Fill #1E0A46, white label. Used for "Create creative" on Home.
class DarkButton extends StatelessWidget {
  const DarkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet900,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _ButtonContent(label: label, icon: icon, color: Colors.white),
      ),
    );
  }
}

/// Fill #F1EBFF, violet label. Secondary action beside a primary button.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet100,
          foregroundColor: AppColors.violet600,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _ButtonContent(
          label: label,
          icon: icon,
          color: AppColors.violet600,
          weight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.color,
    this.icon,
    this.weight,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final FontWeight? weight;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.buttonLabel.copyWith(
      color: color,
      fontWeight: weight ?? FontWeight.w600,
    );
    if (icon == null) {
      return Text(label, style: style);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(label, style: style),
      ],
    );
  }
}
