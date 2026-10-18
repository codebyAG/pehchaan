import 'package:flutter/material.dart';

import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/core/services/sales_contact.dart';
import 'package:pehchaan/core/state/session.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

/// Countdown during the free trial, and a renewal nudge in the last days
/// of a paid plan (§7). Renders nothing otherwise.
class TrialBanner extends StatelessWidget {
  const TrialBanner({super.key});

  static const _renewNudgeWindow = Duration(days: 5);

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final access = session.me?.access;
    final endsAt = access?.endsAt;
    if (access == null || endsAt == null) return const SizedBox.shrink();

    final left = endsAt.difference(DateTime.now());
    if (left.isNegative) return const SizedBox.shrink();
    final isTrial = access.state == AccessState.trial;
    if (!isTrial &&
        (access.state != AccessState.active || left > _renewNudgeWindow)) {
      return const SizedBox.shrink();
    }

    final days = (left.inHours / 24).ceil();
    final when = days <= 1
        ? session.t('trial.ends_today', 'aaj')
        : '$days ${session.t('trial.days', 'din')}';
    final text = isTrial
        ? session.t('trial.banner', 'Free trial ke {when} baaki').replaceAll('{when}', when)
        : session.t('plan.renew_banner', 'Plan {when} mein khatam — renew karein')
            .replaceAll('{when}', when);
    final plan = session.content?.plan(access.planKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.yellow500,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_rounded, color: AppColors.yellowInk),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.violet900,
              ),
            ),
          ),
          TextButton(
            onPressed: () => contactSales(
              context,
              planName: plan?.name,
              shopName: session.me?.business?.shopName,
            ),
            child: Text(
              session.t('plan.upgrade_cta', 'Plan lein'),
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.violet900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
