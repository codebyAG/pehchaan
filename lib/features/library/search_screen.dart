import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/state/app_state.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'creative_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final List<String> _recentSearches = ['Offer', 'Diwali', 'Saree'];
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = AppStateScope.of(context).savedCreatives;
    final results = _query.isEmpty
        ? <Creative>[]
        : all
              .where(
                (c) => c.title.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.violet900,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: 'Offer, festival, product…',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.mutedText,
                        ),
                        filled: true,
                        fillColor: AppColors.violet100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.violet600,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_query.isEmpty) ...[
                Text('Recent searches', style: AppTextStyles.fieldLabel),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final s in _recentSearches)
                      GestureDetector(
                        onTap: () {
                          _controller.text = s;
                          setState(() => _query = s);
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.violet100,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            s,
                            style: AppTextStyles.fieldLabel.copyWith(
                              color: AppColors.violet900,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ] else if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Text('Kuch nahi mila', style: AppTextStyles.body),
                        TextButton(
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          child: Text(
                            'Clear search',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.violet600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: GridView.builder(
                    itemCount: results.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemBuilder: (context, i) {
                      final c = results[i];
                      return InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreativeDetailScreen(creative: c),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.violet600,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.category.label,
                                style: AppTextStyles.eyebrow.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                c.title,
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
