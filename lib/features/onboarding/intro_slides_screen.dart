import 'package:flutter/material.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

class IntroSlidesScreen extends StatefulWidget {
  const IntroSlidesScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<IntroSlidesScreen> createState() => _IntroSlidesScreenState();
}

class _Slide {
  const _Slide(this.title, this.sub);
  final String title;
  final String sub;
}

class _IntroSlidesScreenState extends State<IntroSlidesScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    _Slide(
      'Business ki post, minutes mein',
      'Designer ke bina professional creatives.',
    ),
    _Slide(
      'Offer, festival, product — sab',
      'Jo promote karna hai, bas likh do.',
    ),
    _Slide(
      'Download karo, kahin bhi use karo',
      'Instagram, WhatsApp, print — aapki choice.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index == _slides.length - 1) {
      widget.onDone();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet600,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 20, 0),
                child: TextButton(
                  onPressed: widget.onDone,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _index;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.yellow500
                        : const Color(0xFF8B6BE8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.violet600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _index == _slides.length - 1 ? 'Get started' : 'Next',
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: AppColors.violet600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            flex: 45,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 220),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.sub,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textOnViolet,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
