import 'package:flutter/material.dart';

import 'package:pehchaan/core/api/api_config.dart';
import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/core/services/sales_contact.dart';
import 'package:pehchaan/core/state/session.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'package:pehchaan/core/widgets/video_slot.dart';
import 'package:pehchaan/features/business_setup/business_form_screen.dart';
import 'package:pehchaan/features/posters/poster_widgets.dart';
import 'package:pehchaan/features/profile/language_change_screen.dart';

/// Sales page for `none` / `expired` (§9), personalised to the shop. Free
/// posters can still be browsed and shared from here — branding is the
/// paid part.
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const _freePosterCount = 12;

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final s = session.t;
    final me = session.me;
    final business = me?.business;
    final content = session.content;
    final access = me?.access;
    final expired = access?.state == AccessState.expired;
    final wasPaid = expired && access?.kind != null && access?.kind != 'trial';
    final welcome = me?.welcomeVideo;
    final testimonials = ApiConfig.testimonialVideoUrls
        .split(',')
        .map((u) => u.trim())
        .where((u) => u.isNotEmpty)
        .toList();
    final plans = [...?content?.plans]
      ..sort((a, b) {
        // Highlighted plan first, otherwise server order.
        if (a.isHighlighted != b.isHighlighted) return a.isHighlighted ? -1 : 1;
        return a.sortOrder.compareTo(b.sortOrder);
      });

    final freeDesigns =
        content?.visibleDesigns().take(_freePosterCount).toList() ?? const <Design>[];

    void buy([Plan? plan]) => contactSales(
      context,
      planName: plan?.name,
      shopName: business?.shopName,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(business?.shopName ?? 'Pehchaan', style: AppTextStyles.sectionHeading),
        actions: [_LandingMenu()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          if (expired) ...[
            Text(
              wasPaid
                  ? s('landing.plan_ended', 'Aapka plan khatam ho gaya — posters milte rehne ke liye renew karein')
                  : s('landing.trial_ended', 'Aapka free trial khatam ho gaya'),
              style: AppTextStyles.screenTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 16),
          ],

          // 1. Their video — personalised when ready, else a fallback
          //    captioned with their shop name.
          VideoSlot(
            url: welcome?.isReady == true ? welcome!.url : ApiConfig.fallbackWelcomeVideoUrl,
            caption: business?.shopName,
            subtitle: welcome?.isReady == true
                ? null
                : s('landing.video_subtitle', 'Aapke business ke liye banaya gaya'),
          ),
          const SizedBox(height: 16),

          // 2. CTA
          AccentButton(
            label: s('landing.create_more', 'Apne business ke liye aur banwayein'),
            icon: Icons.auto_awesome_rounded,
            onPressed: () => buy(content?.plan(content.trial.planKey)),
          ),
          const SizedBox(height: 28),

          // 3. Testimonials
          Text(s('landing.testimonials', 'Dukaandaar kya kehte hain'), style: AppTextStyles.sectionHeading),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: testimonials.isEmpty ? 2 : testimonials.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => SizedBox(
                width: 284,
                child: VideoSlot(
                  url: testimonials.isEmpty ? null : testimonials[i],
                  subtitle: testimonials.isEmpty
                      ? s('landing.testimonial_soon', 'Jaldi aa raha hai')
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // 4. How we help
          Text(s('landing.how_title', 'Hum aapke business ko kaise badhate hain'),
              style: AppTextStyles.sectionHeading),
          const SizedBox(height: 12),
          _HowRow(
            icon: Icons.calendar_today_rounded,
            text: s('landing.how_1', 'Har din naya poster — tyohaar, offer aur good morning'),
          ),
          _HowRow(
            icon: Icons.storefront_rounded,
            text: s('landing.how_2', 'Har poster par aapki shop ka naam, logo aur number'),
          ),
          _HowRow(
            icon: Icons.share_rounded,
            text: s('landing.how_3', 'Ek tap mein WhatsApp, Instagram aur Facebook par share'),
          ),
          const SizedBox(height: 28),

          // 5. Plans
          if (plans.isNotEmpty) ...[
            Text(s('landing.plans_title', 'Plan chuniye'), style: AppTextStyles.sectionHeading),
            const SizedBox(height: 12),
            for (final plan in plans) ...[
              _PlanCard(
                plan: plan,
                recommendedLabel: s('landing.recommended', 'Recommended'),
                ctaLabel: expired
                    ? s('landing.renew_cta', 'Renew karein')
                    : s('landing.plan_cta', 'Yeh plan lein'),
                onTap: () => buy(plan),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 16),
          ],

          // Free posters — the free hook (§9.2).
          if (freeDesigns.isNotEmpty) ...[
            Text(s('landing.free_posters', 'Free posters'), style: AppTextStyles.sectionHeading),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: freeDesigns.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, i) => DesignTile(design: freeDesigns[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _HowRow extends StatelessWidget {
  const _HowRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.violet100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.violet600, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(text, style: AppTextStyles.body),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.recommendedLabel,
    required this.ctaLabel,
    required this.onTap,
  });

  final Plan plan;
  final String recommendedLabel;
  final String ctaLabel;
  final VoidCallback onTap;

  String get _period => switch (plan.periodDays) {
    30 || 31 => '/month',
    7 => '/week',
    365 || 366 => '/year',
    0 => '',
    final d => '/$d din',
  };

  @override
  Widget build(BuildContext context) {
    final hl = plan.isHighlighted;
    final fg = hl ? Colors.white : AppColors.violet900;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: hl ? AppColors.violet600 : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: hl ? null : Border.all(color: AppColors.divider, width: 1.5),
        boxShadow: hl ? AppColors.softShadow : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: AppTextStyles.sectionHeading.copyWith(color: fg),
                ),
              ),
              if (hl)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.yellow500,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    recommendedLabel,
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: AppColors.violet900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: plan.priceLabel,
                  style: AppTextStyles.screenTitle.copyWith(color: fg, fontSize: 30),
                ),
                TextSpan(
                  text: _period,
                  style: AppTextStyles.body.copyWith(
                    color: hl ? AppColors.textOnViolet : AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          if (plan.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              plan.description,
              style: AppTextStyles.body.copyWith(
                color: hl ? AppColors.textOnViolet : AppColors.mutedText,
                fontSize: 15,
              ),
            ),
          ],
          const SizedBox(height: 10),
          for (final f in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded,
                      size: 18, color: hl ? AppColors.yellow500 : AppColors.violet600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(f, style: AppTextStyles.body.copyWith(color: fg, fontSize: 15)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          hl
              ? AccentButton(label: ctaLabel, onPressed: onTap)
              : PrimaryButton(label: ctaLabel, onPressed: onTap),
        ],
      ),
    );
  }
}

class _LandingMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context, listen: false);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.violet900),
      onSelected: (v) {
        switch (v) {
          case 'edit':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BusinessFormScreen(isEdit: true)),
            );
          case 'lang':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LanguageChangeScreen()),
            );
          case 'logout':
            session.signOut();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Business details')),
        PopupMenuItem(value: 'lang', child: Text('Language')),
        PopupMenuItem(value: 'logout', child: Text('Log out')),
      ],
    );
  }
}
