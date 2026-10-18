import 'package:flutter/material.dart';

import 'package:pehchaan/core/state/session.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'poster_widgets.dart';

/// Local tag search over the stored payload — there's no search endpoint
/// (§5.5). Tag `terms` already include every language plus aliases.
class PosterSearchScreen extends StatefulWidget {
  const PosterSearchScreen({super.key});

  @override
  State<PosterSearchScreen> createState() => _PosterSearchScreenState();
}

class _PosterSearchScreenState extends State<PosterSearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final results = session.content?.search(_query) ?? const [];
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: session.t('search.hint', 'Diwali, good morning, offer…'),
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedText),
            border: InputBorder.none,
          ),
        ),
      ),
      body: _query.trim().isEmpty
          ? const SizedBox.shrink()
          : results.isEmpty
          ? Center(
              child: Text(
                session.t('search.empty', 'Koi poster nahi mila'),
                style: AppTextStyles.body.copyWith(color: AppColors.mutedText),
              ),
            )
          : DesignGrid(designs: results),
    );
  }
}
