import 'package:flutter/material.dart';

import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/core/services/ai_image_service.dart';
import 'package:pehchaan/core/state/session.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/trial_banner.dart';
import 'package:pehchaan/features/ai_image/ai_image_screen.dart';
import 'poster_search_screen.dart';
import 'poster_widgets.dart';

/// Full-app Home (§10): everything rendered from the stored content
/// payload. The time band is recomputed on every build, and the session
/// rebuilds on resume, so "good morning" turns into "good night" with no
/// fetch.
class PosterHomeScreen extends StatelessWidget {
  const PosterHomeScreen({super.key});

  static const _perStrip = 12;

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final content = session.content;
    final business = session.me?.business;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/pehchaanapp_logo.png', width: 32, height: 32),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                business?.shopName ?? 'Pehchaan',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sectionHeading,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.violet900),
            onPressed: content == null
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PosterSearchScreen()),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: !AiImageService.isAvailable
          ? null
          : FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AiImageScreen()),
        ),
        backgroundColor: AppColors.violet600,
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        label: Text(
          'AI Image',
          style: AppTextStyles.buttonLabel.copyWith(color: Colors.white, fontSize: 15),
        ),
      ),
      body: content == null
          ? const ContentUnavailable()
          : RefreshIndicator(
              // Pull-to-refresh re-checks the *version* only — it never
              // forces a payload download (§5.2).
              onRefresh: () async {
                await session.refreshMe();
                await session.syncContent();
              },
              child: _HomeBody(content: content, perStrip: _perStrip),
            ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.content, required this.perStrip});

  final ContentPayload content;
  final int perStrip;

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final now = DateTime.now();
    final visible = content.visibleDesigns(now: now);

    List<Design> inCategory(String id) {
      final ids = {
        id,
        ...content.categories.where((c) => c.parentId == id).map((c) => c.id),
      };
      return visible.where((d) => ids.contains(d.categoryId)).toList();
    }

    final carouselId = content.carouselCategoryId;
    final bandCategories = content.timeBandCategories(now);
    final upcoming = content.occasions
        .where((o) =>
            o.date != null &&
            !o.date!.isBefore(DateTime(now.year, now.month, now.day)) &&
            o.date!.difference(now).inDays <= 30)
        .toList()
      ..sort((a, b) => a.date!.compareTo(b.date!));

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 96),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TrialBanner(),
        ),
        ContentBannerCarousel(content: content),
        for (final cat in bandCategories)
          DesignStrip(
            title: cat.name,
            designs: inCategory(cat.id).take(perStrip).toList(),
            onSeeAll: () => openCategory(context, cat),
          ),
        if (carouselId != null && content.category(carouselId) != null)
          DesignStrip(
            title: content.category(carouselId)!.name,
            designs: inCategory(carouselId).take(perStrip).toList(),
            onSeeAll: () => openCategory(context, content.category(carouselId)!),
          ),
        if (upcoming.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              session.t('home.upcoming', 'Aane wale tyohaar'),
              style: AppTextStyles.sectionHeading,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: upcoming.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final o = upcoming[i];
                final cat = content.category(o.categoryId);
                return ActionChip(
                  avatar: const Icon(Icons.celebration_rounded, size: 18, color: AppColors.violet600),
                  label: Text('${o.name} · ${o.date!.day}/${o.date!.month}'),
                  backgroundColor: AppColors.yellow500.withValues(alpha: 0.25),
                  side: BorderSide.none,
                  labelStyle: AppTextStyles.fieldLabel.copyWith(
                    color: AppColors.violet900,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: cat == null ? null : () => openCategory(context, cat),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
        for (final cat in content.homeCategories())
          if (cat.id != carouselId && !bandCategories.contains(cat))
            DesignStrip(
              title: cat.name,
              designs: inCategory(cat.id).take(perStrip).toList(),
              onSeeAll: () => openCategory(context, cat),
            ),
      ],
    );
  }
}
