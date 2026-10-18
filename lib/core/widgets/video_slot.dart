import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';

/// A 16:9 video. With no [url] (or if it fails to load) it shows a branded
/// placeholder card instead, captioned with [caption] so a fallback still
/// feels personal (§9).
class VideoSlot extends StatefulWidget {
  const VideoSlot({super.key, required this.url, this.caption, this.subtitle});

  final String? url;
  final String? caption;
  final String? subtitle;

  @override
  State<VideoSlot> createState() => _VideoSlotState();
}

class _VideoSlotState extends State<VideoSlot> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(VideoSlot old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _controller?.dispose();
      _controller = null;
      _failed = false;
      _load();
    }
  }

  void _load() {
    final url = widget.url;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _failed = true;
      return;
    }
    final c = VideoPlayerController.networkUrl(uri);
    _controller = c;
    c.initialize().then((_) {
      if (mounted) setState(() {});
    }).catchError((Object _) {
      if (mounted) setState(() => _failed = true);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: c == null || _failed
            ? _Placeholder(caption: widget.caption, subtitle: widget.subtitle)
            : !c.value.isInitialized
            ? const ColoredBox(
                color: AppColors.violet900,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            : GestureDetector(
                onTap: () => setState(
                  () => c.value.isPlaying ? c.pause() : c.play(),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: Colors.black,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: c.value.size.width,
                          height: c.value.size.height,
                          child: VideoPlayer(c),
                        ),
                      ),
                    ),
                    if (!c.value.isPlaying)
                      const Center(child: _PlayBadge()),
                    if (widget.caption != null)
                      Positioned(
                        left: 12,
                        bottom: 12,
                        right: 12,
                        child: _Caption(widget.caption!),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.caption, this.subtitle});

  final String? caption;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.violet600, AppColors.violet900],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Center(child: _PlayBadge()),
          if (caption != null || subtitle != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (caption != null) _Caption(caption!),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.fieldLabel.copyWith(
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

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.sectionHeading.copyWith(
        color: Colors.white,
        shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: const Icon(Icons.play_arrow_rounded, color: AppColors.violet600, size: 34),
    );
  }
}
