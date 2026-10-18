import 'package:flutter/material.dart';

import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/core/state/session.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'poster_widgets.dart';

/// All posters in a category (and its sub-categories), from the stored
/// payload — no fetch on open (§5.2).
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key, required this.category});

  final ContentCategory category;

  @override
  Widget build(BuildContext context) {
    final content = SessionScope.of(context).content;
    final children = content?.categories
            .where((c) => c.parentId == category.id)
            .toList() ??
        const <ContentCategory>[];
    final ids = {category.id, ...children.map((c) => c.id)};
    final designs = content
            ?.visibleDesigns()
            .where((d) => ids.contains(d.categoryId))
            .toList() ??
        const <Design>[];

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: Column(
        children: [
          if (children.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: children.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ActionChip(
                  label: Text(children[i].name),
                  backgroundColor: AppColors.violet100,
                  side: BorderSide.none,
                  labelStyle: AppTextStyles.fieldLabel.copyWith(
                    color: AppColors.violet900,
                    fontWeight: FontWeight.w600,
                  ),
                  onPressed: () => openCategory(context, children[i]),
                ),
              ),
            ),
          Expanded(
            child: designs.isEmpty
                ? Center(
                    child: Text(
                      'Abhi is category mein posters nahi hain',
                      style: AppTextStyles.body.copyWith(color: AppColors.mutedText),
                    ),
                  )
                : DesignGrid(designs: designs),
          ),
        ],
      ),
    );
  }
}
