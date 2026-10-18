import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Disk cache for content images (§5.3). URLs are immutable, so a file is
/// valid forever — the only housekeeping is an LRU size ceiling, evicting
/// full-size `display` files before thumbnails.
class ImageStore {
  ImageStore._();

  static const _maxBytes = 250 * 1024 * 1024;

  static Directory? _dir;
  static final Map<String, Future<File?>> _inFlight = {};

  static Future<Directory?> _directory() async {
    if (_dir != null) return _dir;
    try {
      final base = await getApplicationCacheDirectory();
      final dir = Directory('${base.path}/images');
      await dir.create(recursive: true);
      return _dir = dir;
    } catch (_) {
      return null;
    }
  }

  /// `kind` is `t` (thumbnail/small) or `d` (display/large), used only to
  /// decide eviction order.
  static Future<File?> file(String url, {String kind = 't'}) {
    if (url.isEmpty) return Future.value(null);
    return _inFlight.putIfAbsent(url, () async {
      final dir = await _directory();
      if (dir == null) return null;
      final f = File('${dir.path}/${kind}_${_hash(url)}');
      try {
        if (await f.exists()) {
          // Touch for LRU; failure here is harmless.
          unawaited(f.setLastModified(DateTime.now()).catchError((_) {}));
          return f;
        }
        final res = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 30));
        if (res.statusCode != 200 || res.bodyBytes.isEmpty) return null;
        final tmp = File('${f.path}.tmp');
        await tmp.writeAsBytes(res.bodyBytes, flush: true);
        await tmp.rename(f.path);
        return f;
      } catch (_) {
        return null;
      }
    }).then((f) {
      // Failures aren't memoised — the next request tries again.
      if (f == null) _inFlight.remove(url);
      return f;
    });
  }

  static Future<Uint8List?> bytes(String url, {String kind = 'd'}) async {
    final f = await file(url, kind: kind);
    try {
      return await f?.readAsBytes();
    } catch (_) {
      return null;
    }
  }

  /// Trims the cache to the ceiling. Cheap enough to run once per launch.
  static Future<void> evictIfNeeded() async {
    final dir = await _directory();
    if (dir == null) return;
    try {
      final entries = <({File file, int size, DateTime used, bool display})>[];
      await for (final e in dir.list()) {
        if (e is! File || e.path.endsWith('.tmp')) continue;
        final stat = await e.stat();
        final name = e.uri.pathSegments.last;
        entries.add((
          file: e,
          size: stat.size,
          used: stat.modified,
          display: name.startsWith('d_'),
        ));
      }
      var total = entries.fold<int>(0, (s, e) => s + e.size);
      if (total <= _maxBytes) return;
      entries.sort((a, b) {
        if (a.display != b.display) return a.display ? -1 : 1;
        return a.used.compareTo(b.used);
      });
      for (final e in entries) {
        if (total <= _maxBytes * 0.8) break;
        try {
          await e.file.delete();
          total -= e.size;
        } catch (_) {}
      }
      _inFlight.clear();
    } catch (_) {}
  }

  /// FNV-1a 64-bit — stable across runs, unlike `String.hashCode`.
  static String _hash(String s) {
    var h = BigInt.parse('cbf29ce484222325', radix: 16);
    final prime = BigInt.parse('100000001b3', radix: 16);
    final mask = (BigInt.one << 64) - BigInt.one;
    for (final c in s.codeUnits) {
      h = ((h ^ BigInt.from(c)) * prime) & mask;
    }
    return h.toRadixString(16);
  }
}

/// A content image served from [ImageStore]. While loading it shows a soft
/// placeholder; if the image can't be fetched (e.g. 404) it renders
/// [onError] — by default nothing, so a broken tile just disappears (§12).
class CachedImage extends StatefulWidget {
  const CachedImage(
    this.url, {
    super.key,
    this.kind = 't',
    this.fit = BoxFit.cover,
    this.placeholderColor = const Color(0xFFF1EBFF),
    this.onError,
  });

  final String url;
  final String kind;
  final BoxFit fit;
  final Color placeholderColor;
  final Widget? onError;

  @override
  State<CachedImage> createState() => _CachedImageState();
}

class _CachedImageState extends State<CachedImage> {
  late Future<File?> _future = ImageStore.file(widget.url, kind: widget.kind);

  @override
  void didUpdateWidget(CachedImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) {
      _future = ImageStore.file(widget.url, kind: widget.kind);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return ColoredBox(color: widget.placeholderColor);
        }
        final file = snap.data;
        if (file == null) return widget.onError ?? const SizedBox.shrink();
        return Image.file(
          file,
          fit: widget.fit,
          gaplessPlayback: true,
          errorBuilder: (_, _, _) => widget.onError ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
