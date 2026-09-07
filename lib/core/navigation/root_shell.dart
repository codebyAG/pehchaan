import 'package:flutter/material.dart';

import 'package:pehchaan/core/widgets/app_bottom_nav.dart';
import 'package:pehchaan/features/creative/creative_input_screen.dart';
import 'package:pehchaan/features/home/home_screen.dart';
import 'package:pehchaan/features/library/my_creatives_screen.dart';
import 'package:pehchaan/features/profile/profile_screen.dart';
import 'package:pehchaan/features/creative/type_picker_sheet.dart';

/// 4-tab shell. "Create" (index 1) always pushes the create flow rather than
/// swapping tab content, since it is an action, not a destination.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tabIndex = 0;

  static const _tabToPage = {0: 0, 2: 1, 3: 2};

  Future<void> _startCreateFlow() async {
    final category = await TypePickerSheet.show(context);
    if (category != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreativeInputScreen(category: category),
        ),
      );
    }
  }

  void _onNavTap(int index) {
    if (index == 1) {
      _startCreateFlow();
      return;
    }
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = _tabToPage[_tabIndex] ?? 0;
    return Scaffold(
      body: IndexedStack(
        index: pageIndex,
        children: [
          HomeScreen(onSeeAllCreatives: () => setState(() => _tabIndex = 2)),
          const MyCreativesScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tabIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
