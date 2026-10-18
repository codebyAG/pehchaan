import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'package:pehchaan/core/models/business.dart';
import 'package:pehchaan/core/models/creative.dart';
import 'local_storage.dart';

/// Local state for the AI creative tools: the business profile in the
/// shape those screens use, and the creatives saved on this device.
class AppState extends ChangeNotifier {
  Business? business;
  final List<Creative> savedCreatives = [];

  String? _logoUrl;

  /// Loads the AI creatives saved on this device. The business profile is
  /// not read from here — the API (`GET /v1/me`) is its source of truth and
  /// arrives through [syncBusiness].
  Future<void> hydrate() async {
    final savedList = await LocalStorage.loadCreatives();
    if (savedList == null) return;
    savedCreatives
      ..clear()
      ..addAll(savedList);
    notifyListeners();
  }

  /// Mirrors the server profile. Keeps the already-downloaded logo when the
  /// logo URL hasn't changed.
  void syncBusiness(Business? value, {String? logoUrl}) {
    final keepLogo = value != null && logoUrl != null && logoUrl == _logoUrl;
    business = keepLogo ? value.copyWith(logoBytes: business?.logoBytes) : value;
    _logoUrl = value == null ? null : logoUrl;
    notifyListeners();
  }

  void setLogoBytes(String logoUrl, Uint8List bytes) {
    if (logoUrl != _logoUrl || business == null) return;
    business = business!.copyWith(logoBytes: bytes);
    notifyListeners();
  }

  void addCreative(Creative creative) {
    savedCreatives.insert(0, creative);
    notifyListeners();
    LocalStorage.saveCreatives(savedCreatives);
  }

  void removeCreative(Creative creative) {
    savedCreatives.remove(creative);
    notifyListeners();
    LocalStorage.saveCreatives(savedCreatives);
  }

  void removeCreatives(Iterable<Creative> creatives) {
    savedCreatives.removeWhere(creatives.toSet().contains);
    notifyListeners();
    LocalStorage.saveCreatives(savedCreatives);
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<AppStateScope>()
        : context.getInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in context');
    return scope!.notifier!;
  }
}
