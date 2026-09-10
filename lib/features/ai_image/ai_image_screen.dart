import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/services/ai_image_service.dart';
import 'package:pehchaan/core/state/app_state.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'package:pehchaan/core/widgets/app_chip.dart';

enum _State { idle, generating, done, error }

/// Very small MVP screen: user types what they want in one line, we ask
/// GPT to turn it into a detailed image prompt and generate the image —
/// the user never sees or writes that prompt themselves.
class AiImageScreen extends StatefulWidget {
  const AiImageScreen({super.key});

  @override
  State<AiImageScreen> createState() => _AiImageScreenState();
}

class _AiImageScreenState extends State<AiImageScreen> {
  /// Paced off typical "max" quality generation time; see
  /// GeneratingScreen for why this is an estimate, not real progress.
  static const _estimatedTotal = Duration(seconds: 140);

  final _service = const AiImageService();
  final _controller = TextEditingController();
  final _stopwatch = Stopwatch();

  CreativeCategory? _selectedCategory;
  _State _state = _State.idle;
  Uint8List? _imageBytes;
  String? _errorMessage;
  double _progress = 0;
  Timer? _progressTimer;

  @override
  void dispose() {
    _controller.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  /// Folds in the same context the app's own creative forms collect —
  /// category and business details — so GPT has more to work with than
  /// just the one-line request, without asking the user to fill a form.
  String _buildEnrichedRequest() {
    final userText = _controller.text.trim();
    final business = AppStateScope.of(context, listen: false).business;
    final parts = <String>[];

    if (_selectedCategory != null) {
      parts.add('Creative type: ${_selectedCategory!.label}.');
    }
    parts.add(userText);
    if (business != null) {
      final bizBits = <String>[business.name];
      if (business.category.isNotEmpty) bizBits.add(business.category);
      if (business.location.isNotEmpty) bizBits.add(business.location);
      if (business.address.isNotEmpty) bizBits.add(business.address);
      parts.add('For the business: ${bizBits.join(', ')}.');
      if (business.phone.isNotEmpty) parts.add('Contact: ${business.phone}.');
    }
    return parts.join(' ');
  }

  Future<void> _generate() async {
    final request = _buildEnrichedRequest();
    if (_controller.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _state = _State.generating;
      _errorMessage = null;
      _progress = 0;
    });

    _stopwatch
      ..reset()
      ..start();
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      final elapsed = _stopwatch.elapsed.inMilliseconds / _estimatedTotal.inMilliseconds;
      setState(() => _progress = (1 - (1 - elapsed).clamp(0.0, 1.0)) * 0.92);
    });

    try {
      final bytes = await _service.generateImage(request);
      if (!mounted) return;
      _progressTimer?.cancel();
      setState(() {
        _imageBytes = Uint8List.fromList(bytes);
        _state = _State.done;
        _progress = 1;
      });
    } on AiImageException catch (e) {
      if (!mounted) return;
      _progressTimer?.cancel();
      setState(() {
        _errorMessage = e.message;
        _state = _State.error;
      });
    } catch (_) {
      if (!mounted) return;
      _progressTimer?.cancel();
      setState(() {
        _errorMessage = 'Kuch galat ho gaya. Dobara try karein.';
        _state = _State.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Image (Beta)')),
      backgroundColor: AppColors.violet050,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kaisi image chahiye?', style: AppTextStyles.screenTitle),
              const SizedBox(height: 8),
              Text(
                'Ek line mein batayein — jaise "Jeera ka premium poster banao".',
                style: AppTextStyles.fieldLabel,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 3,
                minLines: 2,
                style: AppTextStyles.body,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _generate(),
                decoration: InputDecoration(
                  hintText: 'e.g. Diwali offer poster banao',
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedText),
                  filled: true,
                  fillColor: AppColors.violet100,
                  contentPadding: const EdgeInsets.all(16),
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
                    borderSide: const BorderSide(color: AppColors.violet600, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Type (optional)', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final category in CreativeCategory.values)
                    AppChip(
                      label: category.label,
                      selected: _selectedCategory == category,
                      onTap: () => setState(() {
                        _selectedCategory = _selectedCategory == category ? null : category;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              AccentButton(
                label: _state == _State.generating ? 'Generating…' : 'Generate Image',
                onPressed: _state == _State.generating ? null : _generate,
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildResult()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    switch (_state) {
      case _State.idle:
        return const SizedBox.shrink();
      case _State.generating:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: _progress,
                  color: AppColors.violet600,
                ),
              ),
              const SizedBox(height: 16),
              Text('Aapki image ban rahi hai…', style: AppTextStyles.body),
              const SizedBox(height: 4),
              Text(
                '${(_progress * 100).round()}%',
                style: AppTextStyles.fieldLabel,
              ),
            ],
          ),
        );
      case _State.error:
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.violet100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_errorMessage ?? 'Kuch galat ho gaya.', style: AppTextStyles.body),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _generate,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  'Try again',
                  style: AppTextStyles.buttonLabel.copyWith(color: AppColors.violet600),
                ),
              ),
            ],
          ),
        );
      case _State.done:
        final bytes = _imageBytes;
        if (bytes == null) return const SizedBox.shrink();
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColors.softShadow,
            ),
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
        );
    }
  }
}
