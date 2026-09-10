import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/services/ai_image_service.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'result_screen.dart';

/// Full-screen violet state shown while the creative is being produced.
/// No AI/model names — rotating status lines plus a progress bar.
///
/// When [aiRequest] is given, this actually calls the AI backend and shows
/// the real generated image next, with an estimated percentage (OpenAI's
/// image API doesn't report real progress for a single request, so this
/// is paced off typical generation time and never claims 100% on its own
/// — only the actual response completes it). When [aiRequest] is null
/// (older call sites without a descriptive request), it falls back to the
/// short mock timer + synthetic preview card with an indeterminate bar.
class GeneratingScreen extends StatefulWidget {
  const GeneratingScreen({
    super.key,
    required this.category,
    required this.title,
    required this.priceText,
    this.format = CreativeFormat.post,
    this.aiRequest,
  });

  final CreativeCategory category;
  final String title;
  final String priceText;
  final CreativeFormat format;
  final String? aiRequest;

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen> {
  static const _statuses = [
    'Design choose kar rahe hain',
    'Text likh rahe hain',
    'Final touch',
  ];

  /// OpenAI's image API doesn't report real progress for a single request
  /// — this estimate is paced off how long a real generation actually
  /// takes (~2–2.5 min at "max" quality), and deliberately never reaches
  /// 100% on its own; it only completes when the image actually arrives.
  static const _estimatedTotal = Duration(seconds: 140);

  final _service = const AiImageService();
  final _stopwatch = Stopwatch();
  int _statusIndex = 0;
  double _progress = 0;
  Timer? _statusTimer;
  Timer? _progressTimer;
  Timer? _doneTimer;
  bool _failed = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _statusTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!mounted) return;
      setState(() => _statusIndex = (_statusIndex + 1) % _statuses.length);
    });

    if (widget.aiRequest != null) {
      _stopwatch.start();
      _progressTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (!mounted) return;
        final elapsed = _stopwatch.elapsed.inMilliseconds / _estimatedTotal.inMilliseconds;
        // Eases toward 92% and holds — the last stretch waits for the
        // real response instead of pretending to know when it lands.
        setState(() => _progress = (1 - (1 - elapsed).clamp(0.0, 1.0)) * 0.92);
      });
      _runRealGeneration(widget.aiRequest!);
    } else {
      _doneTimer = Timer(const Duration(milliseconds: 1800), _goToResult);
    }
  }

  Future<void> _runRealGeneration(String request) async {
    try {
      final bytes = await _service.generateImage(request);
      if (!mounted) return;
      _progressTimer?.cancel();
      setState(() => _progress = 1);
      _goToResult(imageBytes: Uint8List.fromList(bytes));
    } on AiImageException catch (e) {
      if (!mounted) return;
      _progressTimer?.cancel();
      setState(() {
        _failed = true;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      _progressTimer?.cancel();
      setState(() {
        _failed = true;
        _errorMessage = 'Kuch galat ho gaya. Dobara try karein.';
      });
    }
  }

  void _goToResult({Uint8List? imageBytes}) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          category: widget.category,
          title: widget.title,
          priceText: widget.priceText,
          format: widget.format,
          imageBytes: imageBytes,
          aiRequest: widget.aiRequest,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _progressTimer?.cancel();
    _doneTimer?.cancel();
    super.dispose();
  }

  void _cancel() {
    _progressTimer?.cancel();
    _doneTimer?.cancel();
    Navigator.of(context).pop();
  }

  void _retry() {
    _stopwatch
      ..reset()
      ..start();
    setState(() {
      _failed = false;
      _errorMessage = null;
      _progress = 0;
    });
    _progressTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      final elapsed = _stopwatch.elapsed.inMilliseconds / _estimatedTotal.inMilliseconds;
      setState(() => _progress = (1 - (1 - elapsed).clamp(0.0, 1.0)) * 0.92);
    });
    _runRealGeneration(widget.aiRequest!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet600,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: _failed ? _buildError() : _buildGenerating(),
        ),
      ),
    );
  }

  Widget _buildGenerating() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.violet600,
            size: 32,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Aapka creative ban raha hai…',
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionHeading.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          _statuses[_statusIndex],
          textAlign: TextAlign.center,
          style: AppTextStyles.fieldLabel.copyWith(color: AppColors.textOnViolet),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: widget.aiRequest != null
                ? LinearProgressIndicator(
                    value: _progress,
                    minHeight: 4,
                    backgroundColor: Colors.white24,
                    color: AppColors.yellow500,
                  )
                : const LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Colors.white24,
                    color: AppColors.yellow500,
                  ),
          ),
        ),
        if (widget.aiRequest != null) ...[
          const SizedBox(height: 8),
          Text(
            '${(_progress * 100).round()}%',
            style: AppTextStyles.fieldLabel.copyWith(color: AppColors.textOnViolet),
          ),
        ],
        const SizedBox(height: 24),
        TextButton(
          onPressed: _cancel,
          child: Text('Cancel', style: AppTextStyles.body.copyWith(color: Colors.white60)),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(Icons.error_outline_rounded, color: AppColors.violet600, size: 32),
        ),
        const SizedBox(height: 24),
        Text(
          'Creative nahi ban paya',
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionHeading.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage ?? 'Ek baar phir try karein.',
          textAlign: TextAlign.center,
          style: AppTextStyles.fieldLabel.copyWith(color: AppColors.textOnViolet),
        ),
        const SizedBox(height: 24),
        PrimaryButton(label: 'Try again', onPressed: _retry),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: AppTextStyles.body.copyWith(color: Colors.white60)),
        ),
      ],
    );
  }
}
