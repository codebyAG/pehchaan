import 'package:flutter/widgets.dart';

import 'package:pehchaan/core/models/business.dart';
import 'package:pehchaan/core/models/creative.dart';
import 'package:pehchaan/core/models/user.dart';
import 'local_storage.dart';

class AppState extends ChangeNotifier {
  AppUser? user;
  Business? business;
  final List<Creative> savedCreatives = [];

  AppState();

  /// Pre-seeded with a sample business and creatives so the app opens
  /// straight into a populated Home — no login or setup gate for this
  /// mock, Play‑Store‑listing build. [hydrate] then overlays anything the
  /// user has actually saved on this device, if any.
  factory AppState.withMockData() {
    final state = AppState();
    const business = Business(
      name: 'Raju Tailor',
      category: 'Tailor Shop',
      phone: '+91 98765 43210',
      city: 'Kanpur',
      area: 'Naveen Market',
      address: '',
    );
    state.business = business;
    state._seedMockCreatives(business);
    return state;
  }

  /// Loads whatever the user previously filled in/saved on this device
  /// (business details, creatives) and replaces the seeded mock data with
  /// it. Safe to call once at startup; no-ops if nothing was saved yet.
  Future<void> hydrate() async {
    final savedBusiness = await LocalStorage.loadBusiness();
    final savedList = await LocalStorage.loadCreatives();

    if (savedBusiness == null && savedList == null) return;

    if (savedBusiness != null) business = savedBusiness;
    if (savedList != null) {
      savedCreatives
        ..clear()
        ..addAll(savedList);
    }
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    user = (user ?? const AppUser(phone: '')).copyWith(language: language);
    notifyListeners();
  }

  void login(String phone) {
    user = AppUser(phone: phone);
    notifyListeners();
  }

  void setupBusiness(Business value) {
    final isFirstSetup = business == null;
    business = value;
    if (isFirstSetup) _seedMockCreatives(value);
    notifyListeners();
    LocalStorage.saveBusiness(value);
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

  void _seedMockCreatives(Business business) {
    final phone = business.phone.isNotEmpty
        ? business.phone
        : '+91 98765 43210';
    savedCreatives.addAll([
      Creative(
        category: CreativeCategory.offer,
        title: 'Festive Special',
        priceText: '₹999',
        businessName: business.name,
        phone: phone,
        format: CreativeFormat.post,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Creative(
        category: CreativeCategory.newArrival,
        title: 'Festive Collection 2026',
        priceText: '₹1499',
        businessName: business.name,
        phone: phone,
        format: CreativeFormat.story,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Creative(
        category: CreativeCategory.service,
        title: 'Hair Spa',
        priceText: '₹499',
        businessName: business.name,
        phone: phone,
        format: CreativeFormat.post,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Creative(
        category: CreativeCategory.festival,
        title: 'Diwali Combo',
        priceText: '₹799',
        businessName: business.name,
        phone: phone,
        format: CreativeFormat.status,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ]);
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
