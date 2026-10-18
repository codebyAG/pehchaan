import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:pehchaan/core/api/models.dart';

/// What gets stamped onto a design. Interim slot mapping (§10): `name` →
/// shop name, `photo` → logo, `message` → display phone.
class PosterBranding {
  const PosterBranding({this.shopName, this.phone, this.logo});

  final String? shopName;
  final String? phone;
  final File? logo;

  factory PosterBranding.fromBusiness(ApiBusiness b, {File? logo}) => PosterBranding(
    shopName: b.shopName,
    phone: b.displayPhone == null ? null : formatIndianPhone(b.displayPhone),
    logo: logo,
  );
}

/// Renders a design at its own pixel size ([Design.width] ×
/// [Design.height]) with branding laid into its slots. Wrap in a
/// [FittedBox] to display; capture via [renderPosterPng] to share.
class BrandedPoster extends StatelessWidget {
  const BrandedPoster({
    super.key,
    required this.design,
    required this.base,
    this.branding,
    this.colors = const {},
  });

  final Design design;
  final File base;

  /// Null renders the plain design (free browsing on the landing page).
  final PosterBranding? branding;

  /// Per-slot colour picked by the user from that slot's `color_options`.
  final Map<String, String> colors;

  static const _fonts = {'Poppins', 'Baloo2'};

  @override
  Widget build(BuildContext context) {
    final b = branding;
    return SizedBox(
      width: design.width.toDouble(),
      height: design.height.toDouble(),
      child: Stack(
        children: [
          Positioned.fill(child: Image.file(base, fit: BoxFit.cover)),
          if (b != null) ...[
            if (b.shopName != null && design.slots['name'] != null)
              _text('name', design.slots['name']!, b.shopName!),
            if (b.phone != null && design.slots['message'] != null)
              _text('message', design.slots['message']!, b.phone!),
            if (b.logo != null && design.slots['photo'] != null)
              _image(design.slots['photo']!, b.logo!),
          ],
        ],
      ),
    );
  }

  Widget _text(String key, DesignSlot slot, String value) {
    final color = parseHexColor(colors[key] ?? slot.color) ?? Colors.white;
    final align = switch (slot.align) {
      'left' => TextAlign.left,
      'right' => TextAlign.right,
      _ => TextAlign.center,
    };
    final alignment = switch (slot.align) {
      'left' => Alignment.centerLeft,
      'right' => Alignment.centerRight,
      _ => Alignment.center,
    };
    final maxLines = slot.maxLines ?? 1;
    final style = TextStyle(
      fontFamily: _fonts.contains(slot.font) ? slot.font : 'Poppins',
      fontSize: slot.size ?? slot.h * 0.6,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1.2,
    );
    final text = Text(
      value,
      textAlign: align,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    return Positioned(
      left: slot.x,
      top: slot.y,
      width: slot.w,
      height: slot.h,
      child: Align(
        alignment: alignment,
        // Single-line slots shrink long names to fit rather than clip.
        child: maxLines == 1
            ? FittedBox(fit: BoxFit.scaleDown, alignment: alignment, child: text)
            : text,
      ),
    );
  }

  Widget _image(DesignSlot slot, File file) {
    final img = Image.file(file, fit: BoxFit.contain, width: slot.w, height: slot.h);
    return Positioned(
      left: slot.x,
      top: slot.y,
      width: slot.w,
      height: slot.h,
      child: slot.shape == 'circle'
          ? ClipOval(child: ColoredBox(color: Colors.white, child: img))
          : img,
    );
  }
}

Color? parseHexColor(String? hex) {
  if (hex == null) return null;
  var h = hex.replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final v = int.tryParse(h, radix: 16);
  return v == null ? null : Color(v);
}

/// Captures a [RepaintBoundary] wrapping a [BrandedPoster] as a PNG at the
/// design's native resolution.
Future<List<int>?> renderPosterPng(GlobalKey boundaryKey, Design design) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;
  final logicalWidth = boundary.size.width;
  if (logicalWidth <= 0) return null;
  final image = await boundary.toImage(pixelRatio: design.width / logicalWidth);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
