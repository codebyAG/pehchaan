import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pehchaan/core/api/image_store.dart';
import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/core/state/session.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'category_screen.dart';
import 'poster_viewer_screen.dart';

void openDesign(BuildContext context, Design design) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => PosterViewerScreen(design: design)),
  );
}

void openCategory(BuildContext context, ContentCategory category) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => CategoryScreen(category: category)),
  );
}

/// A poster thumbnail — always the ~30 KB `thumbnail_url`, never the
/// display or original image (§5.3).
class DesignTile extends StatelessWidget {
  const DesignTile({super.key, required this.design, this.width});

  final Design design;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openDesign(context, design),
      child: Container(
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.violet100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CachedImage(design.thumbnailUrl),
      ),
    );
  }
}

class DesignGrid extends StatelessWidget {
  const DesignGrid({super.key, required this.designs, this.padding});

  final List<Design> designs;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: designs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, i) => DesignTile(design: designs[i]),
    );
  }
}

/// Horizontal strip of posters with a header and "See all".
class DesignStrip extends StatelessWidget {
  const DesignStrip({
    super.key,
    required this.title,
    required this.designs,
    this.onSeeAll,
  });

  final String title;
  final List<Design> designs;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    if (designs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Text(title, style: AppTextStyles.sectionHeading)),
                if (onSeeAll != null)
                  GestureDetector(
                    onTap: onSeeAll,
                    child: Text(
                      SessionScope.of(context).t('common.see_all', 'Sab dekhein'),
                      style: AppTextStyles.fieldLabel.copyWith(
                        color: AppColors.violet600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: designs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) => DesignTile(design: designs[i], width: 136),
            ),
          ),
        ],
      ),
    );
  }
}

/// Server-driven banners. `target` decides where a tap goes; unknown
/// targets just don't navigate.
class ContentBannerCarousel extends StatefulWidget {
  const ContentBannerCarousel({super.key, required this.content});

  final ContentPayload content;

  @override
  State<ContentBannerCarousel> createState() => _ContentBannerCarouselState();
}

class _ContentBannerCarouselState extends State<ContentBannerCarousel> {
  int _page = 0;

  void _onTap(ContentBanner b) {
    final c = widget.content;
    switch (b.target) {
      case 'category':
        final cat = c.category(b.targetRef);
        if (cat != null) openCategory(context, cat);
      case 'design':
        for (final d in c.designs) {
          if (d.id == b.targetRef) return openDesign(context, d);
        }
      case 'url':
        final uri = Uri.tryParse(b.targetRef ?? '');
        if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.content.banners;
    if (banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.9),
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => _onTap(banners[i]),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedImage(banners[i].imageUrl),
                  ),
                ),
              ),
            ),
          ),
          if (banners.length > 1) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < banners.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _page ? AppColors.violet600 : AppColors.violet200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown when there's no stored content yet — first launch offline, or the
/// first download is still running.
class ContentUnavailable extends StatelessWidget {
  const ContentUnavailable({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: session.contentLoading
            ? const CircularProgressIndicator(color: AppColors.violet600)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.mutedText),
                  const SizedBox(height: 12),
                  Text(
                    'Posters load nahi hue. Internet check karein.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => session.syncContent(force: true),
                    child: Text(
                      'Dobara try karein',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.violet600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
