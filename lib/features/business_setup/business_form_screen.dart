import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pehchaan/core/api/api_client.dart';
import 'package:pehchaan/core/api/api_config.dart';
import 'package:pehchaan/core/api/image_store.dart';
import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/core/api/pehchaan_api.dart';
import 'package:pehchaan/core/services/image_picker_helper.dart';
import 'package:pehchaan/core/state/session.dart';
import 'package:pehchaan/core/theme/app_colors.dart';
import 'package:pehchaan/core/theme/app_text_styles.dart';
import 'package:pehchaan/core/widgets/app_buttons.dart';
import 'package:pehchaan/core/widgets/app_text_field.dart';
import 'package:pehchaan/core/widgets/video_slot.dart';
import 'package:pehchaan/features/auth/phone_login_screen.dart';

/// Onboarding (§8.1) and, with [isEdit], the Edit profile screen — both
/// submit the same full-replace `PUT /v1/me/business`.
class BusinessFormScreen extends StatefulWidget {
  const BusinessFormScreen({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends State<BusinessFormScreen> {
  static const _maxPhotos = 6;

  final _owner = TextEditingController();
  final _shop = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();
  final _phone = TextEditingController();
  final _tagline = TextEditingController();

  String? _tradeKey;
  String? _logoUrl;
  final List<String> _photoUrls = [];

  // Not editable here yet (no location picker), but the PUT is a full
  // replace, so existing values must be sent back or they'd be cleared.
  double? _latitude;
  double? _longitude;

  bool _uploadingLogo = false;
  bool _uploadingPhoto = false;
  bool _submitting = false;
  bool _showErrors = false;
  String? _serverError;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final me = SessionScope.of(context, listen: false).me;
    final b = me?.business;
    _owner.text = me?.user.name ?? '';
    final loginPhone = normaliseIndianMobile(me?.user.phone ?? '') ?? '';
    if (b != null) {
      _shop.text = b.shopName;
      _tradeKey = b.tradeKey;
      _city.text = b.city;
      _address.text = b.address ?? '';
      _pincode.text = b.pincode ?? '';
      _phone.text = normaliseIndianMobile(b.displayPhone ?? '') ?? '';
      _tagline.text = b.tagline ?? '';
      _logoUrl = b.logoUrl;
      _photoUrls.addAll(b.photoUrls);
      _latitude = b.latitude;
      _longitude = b.longitude;
    } else {
      _phone.text = loginPhone;
    }
  }

  @override
  void dispose() {
    for (final c in [_owner, _shop, _city, _address, _pincode, _phone, _tagline]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Validation (mirrors the server rules in §8.1) ───────────────────

  String? get _ownerError =>
      _owner.text.trim().isEmpty ? 'Apna naam daaliye' : null;
  String? get _shopError =>
      _shop.text.trim().isEmpty ? 'Shop ka naam daaliye' : null;
  String? get _tradeError => _tradeKey == null ? 'Apna kaam chuniye' : null;
  String? get _cityError => _city.text.trim().isEmpty ? 'Shehar daaliye' : null;
  String? get _pincodeError {
    final p = _pincode.text.trim();
    if (p.isEmpty) return null;
    return RegExp(r'^[1-9]\d{5}$').hasMatch(p) ? null : '6 ankon ka sahi pincode';
  }

  String? get _phoneError {
    final p = _phone.text.trim();
    if (p.isEmpty) return null;
    return normaliseIndianMobile(p) == null ? 'Sahi mobile number daaliye' : null;
  }

  bool get _valid =>
      [_ownerError, _shopError, _tradeError, _cityError, _pincodeError, _phoneError]
          .every((e) => e == null);

  String? _shown(String? error) => _showErrors ? error : null;

  // ── Uploads (§8.3) ──────────────────────────────────────────────────

  Future<String?> _upload(String kind, Uint8List bytes) async {
    try {
      return await PehchaanApi.upload(kind: kind, bytes: bytes);
    } on ApiException catch (e) {
      if (!mounted) return null;
      final msg = e.statusCode == 0
          ? 'Internet nahi hai — photo baad mein add kar sakte hain'
          : 'Upload nahi ho paaya, aap ise baad mein add kar sakte hain';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return null;
    }
  }

  Future<void> _pickLogo() async {
    final bytes = await pickImageFromGallery(maxDimension: 1024);
    if (bytes == null) return;
    setState(() => _uploadingLogo = true);
    final url = await _upload('logo', bytes);
    if (!mounted) return;
    setState(() {
      _uploadingLogo = false;
      if (url != null) _logoUrl = url;
    });
  }

  Future<void> _pickPhoto() async {
    if (_photoUrls.length >= _maxPhotos) return;
    final bytes = await pickImageFromGallery(maxDimension: 2048);
    if (bytes == null) return;
    setState(() => _uploadingPhoto = true);
    final url = await _upload('shop_photo', bytes);
    if (!mounted) return;
    setState(() {
      _uploadingPhoto = false;
      if (url != null) _photoUrls.add(url);
    });
  }

  // ── Submit (§8.2) ───────────────────────────────────────────────────

  String? _opt(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _submit() async {
    setState(() {
      _showErrors = true;
      _serverError = null;
    });
    if (!_valid || _submitting) return;
    setState(() => _submitting = true);

    final session = SessionScope.of(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await PehchaanApi.putBusiness({
        'owner_name': _owner.text.trim(),
        'shop_name': _shop.text.trim(),
        'trade_key': _tradeKey,
        'city': _city.text.trim(),
        'address': _opt(_address),
        'pincode': _opt(_pincode),
        'latitude': _latitude,
        'longitude': _longitude,
        'display_phone': _opt(_phone) == null ? null : normaliseIndianMobile(_phone.text),
        'tagline': _opt(_tagline),
        'logo_url': _logoUrl,
        'photo_urls': _photoUrls,
      });
      session.onBusinessSaved(result.me, created: result.created);
      if (widget.isEdit && navigator.canPop()) {
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile update ho gayi')),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _serverError = e.statusCode == 0
          ? 'Internet connection check karein'
          : e.statusCode == 400
          ? e.message
          : 'Save nahi ho paaya, dobara try karein');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    final s = session.t;
    return Scaffold(
      appBar: widget.isEdit
          ? AppBar(title: Text(s('profile.edit_title', 'Business details')))
          : null,
      body: SafeArea(
        top: !widget.isEdit,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            if (!widget.isEdit) ...[
              VideoSlot(
                url: ApiConfig.onboardingVideoUrl,
                caption: s('onboarding.video_caption', 'Yeh details kyun chahiye?'),
                subtitle: s(
                  'onboarding.video_subtitle',
                  'Aapke posters par aapki shop ka naam aur number aayega',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                s('onboarding.title', 'Apni shop ke baare mein batayein'),
                style: AppTextStyles.screenTitle,
              ),
              const SizedBox(height: 20),
            ],
            AppTextField(
              label: s('onboarding.owner_name', 'Aapka naam'),
              hint: 'e.g. Ramesh Patil',
              controller: _owner,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              errorText: _shown(_ownerError),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: s('onboarding.shop_name', 'Shop / business ka naam'),
              hint: 'e.g. Shree Sweets',
              controller: _shop,
              maxLength: 80,
              textCapitalization: TextCapitalization.words,
              errorText: _shown(_shopError),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(s('onboarding.trade', 'Aapka kaam'), style: AppTextStyles.fieldLabel),
            const SizedBox(height: 8),
            _TradeGrid(
              trades: session.content?.trades ?? const [],
              loading: session.contentLoading,
              selected: _tradeKey,
              onSelected: (k) => setState(() => _tradeKey = k),
              onRetry: () => session.syncContent(force: true),
            ),
            if (_shown(_tradeError) != null) ...[
              const SizedBox(height: 6),
              Text(
                _tradeError!,
                style: AppTextStyles.fieldLabel.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 20),
            AppTextField(
              label: s('onboarding.city', 'Shehar'),
              hint: 'e.g. Pune',
              controller: _city,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              errorText: _shown(_cityError),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: s('onboarding.display_phone', 'Posters par aane wala number'),
              hint: '98765 43210',
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [IndianMobileFormatter()],
              errorText: _shown(_phoneError),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text(
              s('onboarding.optional', 'Optional — baad mein bhi bhar sakte hain'),
              style: AppTextStyles.sectionHeading.copyWith(fontSize: 17),
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: s('onboarding.address', 'Address'),
              hint: 'Shop no, street, landmark',
              controller: _address,
              maxLength: 200,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: s('onboarding.pincode', 'Pincode'),
              hint: '411001',
              controller: _pincode,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              errorText: _shown(_pincodeError),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: s('onboarding.tagline', 'Tagline'),
              hint: 'e.g. Since 1985',
              controller: _tagline,
              maxLength: 80,
            ),
            const SizedBox(height: 20),
            _LogoTile(
              url: _logoUrl,
              uploading: _uploadingLogo,
              onTap: _uploadingLogo ? null : _pickLogo,
              onRemove: () => setState(() => _logoUrl = null),
              label: s('onboarding.logo', 'Logo (optional)'),
            ),
            const SizedBox(height: 20),
            Text(
              s('onboarding.photos', 'Shop ki photos (optional, max 6)'),
              style: AppTextStyles.fieldLabel,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < _photoUrls.length; i++)
                  _PhotoTile(
                    url: _photoUrls[i],
                    onRemove: () => setState(() => _photoUrls.removeAt(i)),
                  ),
                if (_photoUrls.length < _maxPhotos)
                  _AddTile(
                    uploading: _uploadingPhoto,
                    onTap: _uploadingPhoto ? null : _pickPhoto,
                  ),
              ],
            ),
            if (_serverError != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _serverError!,
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                ),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: _submitting
                  ? s('common.saving', 'Save ho raha hai…')
                  : widget.isEdit
                  ? s('common.save', 'Save')
                  : s('onboarding.submit', 'Aage badhein'),
              onPressed: _submitting || _uploadingLogo || _uploadingPhoto ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bundled icon per trade key, then a generic one (§5.1).
IconData tradeIcon(String key) => switch (key) {
  'kirana' => Icons.local_grocery_store_rounded,
  'food' => Icons.restaurant_rounded,
  'fashion' => Icons.checkroom_rounded,
  'beauty' => Icons.face_retouching_natural_rounded,
  'electronics' => Icons.phone_android_rounded,
  'manufacturing' => Icons.factory_rounded,
  _ => Icons.storefront_rounded,
};

class _TradeGrid extends StatelessWidget {
  const _TradeGrid({
    required this.trades,
    required this.loading,
    required this.selected,
    required this.onSelected,
    required this.onRetry,
  });

  final List<Trade> trades;
  final bool loading;
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (trades.isEmpty) {
      return Container(
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.violet050,
          borderRadius: BorderRadius.circular(14),
        ),
        child: loading
            ? const CircularProgressIndicator(color: AppColors.violet600)
            : TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, color: AppColors.violet600),
                label: Text(
                  'List load nahi hui — dobara try karein',
                  style: AppTextStyles.body.copyWith(color: AppColors.violet600),
                ),
              ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trades.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.9,
      ),
      itemBuilder: (context, i) {
        final t = trades[i];
        final isSelected = t.key == selected;
        final fg = isSelected ? Colors.white : AppColors.violet900;
        return InkWell(
          onTap: () => onSelected(t.key),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.violet600 : AppColors.violet100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: t.iconUrl != null
                      ? CachedImage(
                          t.iconUrl!,
                          fit: BoxFit.contain,
                          placeholderColor: Colors.transparent,
                          onError: Icon(tradeIcon(t.key), color: fg),
                        )
                      : Icon(tradeIcon(t.key), color: fg),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.fieldLabel.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LogoTile extends StatelessWidget {
  const _LogoTile({
    required this.url,
    required this.uploading,
    required this.onTap,
    required this.onRemove,
    required this.label,
  });

  final String? url;
  final bool uploading;
  final VoidCallback? onTap;
  final VoidCallback onRemove;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 64,
            height: 64,
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.violet100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: uploading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : url != null
                ? CachedImage(url!, fit: BoxFit.cover)
                : const Icon(Icons.add_rounded, color: AppColors.violet600),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.body)),
        if (url != null && !uploading)
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, color: AppColors.mutedText),
          ),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 96,
          height: 96,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.violet200,
            borderRadius: BorderRadius.circular(14),
          ),
          child: CachedImage(url),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.violet900,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.uploading, required this.onTap});

  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.violet050,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB9A6F0), width: 1.5),
        ),
        child: uploading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_a_photo_rounded, color: AppColors.violet600),
      ),
    );
  }
}
