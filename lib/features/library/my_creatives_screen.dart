import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/state/app_state.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'creative_detail_screen.dart';
import 'package:pehchaan/features/creative/creative_input_screen.dart';
import 'search_screen.dart';
import 'package:pehchaan/features/creative/type_picker_sheet.dart';

class MyCreativesScreen extends StatefulWidget {
  const MyCreativesScreen({super.key});

  @override
  State<MyCreativesScreen> createState() => _MyCreativesScreenState();
}

class _MyCreativesScreenState extends State<MyCreativesScreen> {
  CreativeCategory? _filter;
  final Set<int> _selected = {};

  bool get _selectionMode => _selected.isNotEmpty;

  Future<void> _newCreative() async {
    final category = await TypePickerSheet.show(context);
    if (category != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreativeInputScreen(category: category),
        ),
      );
    }
  }

  void _deleteSelected(List<Creative> visible) {
    final toDelete = _selected.map((i) => visible[i]).toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          toDelete.length == 1
              ? 'Creative delete kar dein?'
              : '${toDelete.length} creatives delete kar dein?',
          style: AppTextStyles.sectionHeading,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(color: AppColors.violet600),
            ),
          ),
          TextButton(
            onPressed: () {
              AppStateScope.of(
                context,
                listen: false,
              ).removeCreatives(toDelete);
              setState(_selected.clear);
              Navigator.of(context).pop();
            },
            child: Text(
              'Delete',
              style: AppTextStyles.body.copyWith(
                color: const Color(0xFFD94A2B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareSelected() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Share sheet khul raha hai')));
    setState(_selected.clear);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final all = appState.savedCreatives;
    final creatives = _filter == null
        ? all
        : all.where((c) => c.category == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode ? '${_selected.length} selected' : 'My creatives',
        ),
        actions: _selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: () => _deleteSelected(creatives),
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: _shareSelected,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
              ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final c in CreativeCategory.values) ...[
                      const SizedBox(width: 10),
                      _FilterChip(
                        label: c.label,
                        selected: _filter == c,
                        onTap: () => setState(() => _filter = c),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: creatives.isEmpty
                    ? _EmptyState(onCreate: _newCreative)
                    : GridView.builder(
                        itemCount: creatives.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                        itemBuilder: (context, i) {
                          final creative = creatives[i];
                          return _CreativeTile(
                            creative: creative,
                            selected: _selected.contains(i),
                            onTap: () {
                              if (_selectionMode) {
                                setState(
                                  () => _selected.contains(i)
                                      ? _selected.remove(i)
                                      : _selected.add(i),
                                );
                                return;
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CreativeDetailScreen(creative: creative),
                                ),
                              );
                            },
                            onLongPress: () => setState(() => _selected.add(i)),
                          );
                        },
                      ),
              ),
              if (!_selectionMode) ...[
                const SizedBox(height: 16),
                PrimaryButton(label: 'New creative', onPressed: _newCreative),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.violet600 : AppColors.violet100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.violet900,
          ),
        ),
      ),
    );
  }
}

class _CreativeTile extends StatelessWidget {
  const _CreativeTile({
    required this.creative,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final Creative creative;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final hasImage = creative.imageBytes != null;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.violet600,
          borderRadius: BorderRadius.circular(16),
          border: selected
              ? Border.all(color: AppColors.yellow500, width: 3)
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.memory(creative.imageBytes!, fit: BoxFit.cover),
            if (hasImage)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.yellow500,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      creative.category.label,
                      style: AppTextStyles.eyebrow.copyWith(
                        color: AppColors.violet900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!hasImage) ...[
                    Text(
                      creative.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      creative.priceText,
                      style: AppTextStyles.sectionHeading.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    _formatDate(creative.createdAt),
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: AppColors.textOnViolet,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.violet200,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_rounded,
                color: AppColors.violet600,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text('Abhi koi creative nahi', style: AppTextStyles.sectionHeading),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Create your first creative',
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}
