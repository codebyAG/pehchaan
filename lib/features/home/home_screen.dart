import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/state/app_state.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_top_bar.dart';
import 'package:pehchaan/core/widgets/business_header_row.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'package:pehchaan/core/widgets/category_tile.dart';
import 'package:pehchaan/core/widgets/home_banner_carousel.dart';
import 'package:pehchaan/features/creative/creative_input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSeeAllCreatives});

  final VoidCallback onSeeAllCreatives;

  static const _categories = [
    (category: CreativeCategory.offer, icon: Icons.local_offer_rounded, style: CategoryTileStyle.violet),
    (category: CreativeCategory.festival, icon: Icons.celebration_rounded, style: CategoryTileStyle.yellow),
    (category: CreativeCategory.product, icon: Icons.shopping_bag_rounded, style: CategoryTileStyle.neutral),
    (category: CreativeCategory.service, icon: Icons.content_cut_rounded, style: CategoryTileStyle.neutral),
    (category: CreativeCategory.newArrival, icon: Icons.fiber_new_rounded, style: CategoryTileStyle.neutral),
    (category: CreativeCategory.announcement, icon: Icons.campaign_rounded, style: CategoryTileStyle.neutral),
  ];

  void _openCreate(BuildContext context, CreativeCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CreativeInputScreen(category: category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final business = appState.business;
    final recent = appState.savedCreatives.take(3).toList();

    return Scaffold(
      appBar: const AppTopBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          children: [
            if (business != null)
              BusinessHeaderRow(
                businessName: business.name,
                category: business.category,
                location: business.location,
              ),
            const SizedBox(height: 20),
            HomeBannerCarousel(
              banners: [
                HomeBanner(
                  asset: 'assets/banners/banner-1-festival.png',
                  onTap: () => _openCreate(context, CreativeCategory.festival),
                ),
                HomeBanner(
                  asset: 'assets/banners/banner-2-offer.png',
                  onTap: () => _openCreate(context, CreativeCategory.offer),
                ),
                HomeBanner(
                  asset: 'assets/banners/banner-3-free-plan.png',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Har mahine 5 creatives free — bina watermark ke')),
                  ),
                ),
                HomeBanner(
                  asset: 'assets/banners/banner-4-photo.png',
                  onTap: () => _openCreate(context, CreativeCategory.product),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Aaj kya promote karna hai?',
              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.violet900),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (context, i) {
                final item = _categories[i];
                return CategoryTile(
                  label: item.category.label,
                  icon: item.icon,
                  style: item.style,
                  onTap: () => _openCreate(context, item.category),
                );
              },
            ),
            const SizedBox(height: 20),
            _FestivalNudgeCard(onCreate: () => _openCreate(context, CreativeCategory.festival)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent creatives', style: AppTextStyles.fieldLabel),
                if (recent.isNotEmpty)
                  GestureDetector(
                    onTap: onSeeAllCreatives,
                    child: Text(
                      'See all',
                      style: AppTextStyles.fieldLabel.copyWith(color: AppColors.violet600, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.violet100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('Pehla creative banaiye — 1 minute lagega.', style: AppTextStyles.body),
              )
            else
              SizedBox(
                height: 84,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    return Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.violet600,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        recent[i].category.label,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.fieldLabel.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 28),
            DarkButton(
              label: 'Create creative',
              onPressed: () => _openCreate(context, CreativeCategory.offer),
            ),
          ],
        ),
      ),
    );
  }
}

class _FestivalNudgeCard extends StatelessWidget {
  const _FestivalNudgeCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.violet200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Diwali 12 din mein — creative bana lein?',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: onCreate,
            child: Text(
              'Create',
              style: AppTextStyles.body.copyWith(color: AppColors.violet600, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
