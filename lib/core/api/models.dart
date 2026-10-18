// Shapes returned by the Pehchaan API. Every parser is lenient: unknown
// keys are ignored and missing ones fall back to safe defaults, because
// fields get added server-side without an app release (§3).

String _s(Object? v, [String fallback = '']) => v is String ? v : fallback;
String? _sn(Object? v) => v is String && v.isNotEmpty ? v : null;
int _i(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
double? _d(Object? v) => v is num ? v.toDouble() : null;
bool _b(Object? v) => v == true;
Map<String, dynamic> _m(Object? v) =>
    v is Map ? v.cast<String, dynamic>() : const <String, dynamic>{};
List<T> _l<T>(Object? v, T Function(Map<String, dynamic>) parse) => v is List
    ? v.whereType<Map>().map((e) => parse(e.cast<String, dynamic>())).toList()
    : <T>[];
List<String> _ls(Object? v) =>
    v is List ? v.whereType<String>().toList() : const <String>[];

// ── Languages ──────────────────────────────────────────────────────────

class Language {
  const Language({required this.code, required this.label, required this.labelEn});

  final String code;
  final String label;
  final String labelEn;

  factory Language.fromJson(Map<String, dynamic> j) => Language(
    code: _s(j['code']),
    label: _s(j['label'], _s(j['code'])),
    labelEn: _s(j['label_en'], _s(j['label'])),
  );

  Map<String, dynamic> toJson() => {'code': code, 'label': label, 'label_en': labelEn};

  /// Offline fallback so the picker is never empty (§4).
  static const bundled = [
    Language(code: 'hi', label: 'हिन्दी', labelEn: 'Hindi'),
    Language(code: 'en', label: 'English', labelEn: 'English'),
    Language(code: 'mr', label: 'मराठी', labelEn: 'Marathi'),
  ];
}

// ── Content payload ────────────────────────────────────────────────────

class ContentCategory {
  const ContentCategory({
    required this.id,
    required this.parentId,
    required this.name,
    required this.iconUrl,
    required this.coverUrl,
    required this.layout,
    required this.sortOrder,
  });

  final String id;
  final String? parentId;
  final String name;
  final String? iconUrl;
  final String? coverUrl;
  final String layout;
  final int sortOrder;

  factory ContentCategory.fromJson(Map<String, dynamic> j) => ContentCategory(
    id: _s(j['id']),
    parentId: _sn(j['parent_id']),
    name: _s(j['name']),
    iconUrl: _sn(j['icon_url']),
    coverUrl: _sn(j['cover_url']),
    layout: _s(j['layout'], 'grid'),
    sortOrder: _i(j['sort_order']),
  );
}

class ContentBanner {
  const ContentBanner({
    required this.id,
    required this.imageUrl,
    required this.target,
    required this.targetRef,
    required this.sortOrder,
  });

  final String id;
  final String imageUrl;
  final String target;
  final String? targetRef;
  final int sortOrder;

  factory ContentBanner.fromJson(Map<String, dynamic> j) => ContentBanner(
    id: _s(j['id']),
    imageUrl: _s(j['image_url']),
    target: _s(j['target']),
    targetRef: _sn(j['target_ref']),
    sortOrder: _i(j['sort_order']),
  );
}

class ContentTag {
  const ContentTag({required this.id, required this.name, required this.terms});

  final String id;
  final String name;
  final List<String> terms;

  factory ContentTag.fromJson(Map<String, dynamic> j) => ContentTag(
    id: _s(j['id']),
    name: _s(j['name']),
    terms: _ls(j['terms']).map((t) => t.toLowerCase()).toList(),
  );
}

/// A text or image placement on a design, in the design's own pixel space.
class DesignSlot {
  const DesignSlot({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.font,
    this.size,
    this.color,
    this.align,
    this.colorOptions = const [],
    this.maxLines,
    this.shape,
  });

  final double x;
  final double y;
  final double w;
  final double h;
  final String? font;
  final double? size;
  final String? color;
  final String? align;
  final List<String> colorOptions;
  final int? maxLines;
  final String? shape;

  factory DesignSlot.fromJson(Map<String, dynamic> j) => DesignSlot(
    x: _d(j['x']) ?? 0,
    y: _d(j['y']) ?? 0,
    w: _d(j['w']) ?? 0,
    h: _d(j['h']) ?? 0,
    font: _sn(j['font']),
    size: _d(j['size']),
    color: _sn(j['color']),
    align: _sn(j['align']),
    colorOptions: _ls(j['color_options']),
    maxLines: j['max_lines'] is num ? _i(j['max_lines']) : null,
    shape: _sn(j['shape']),
  );
}

class Design {
  const Design({
    required this.id,
    required this.categoryId,
    required this.mediaType,
    required this.thumbnailUrl,
    required this.displayUrl,
    required this.width,
    required this.height,
    required this.timeBand,
    required this.tagIds,
    required this.slots,
    required this.sortOrder,
  });

  final String id;
  final String? categoryId;
  final String mediaType;
  final String thumbnailUrl;
  final String displayUrl;
  final int width;
  final int height;
  final String timeBand;
  final List<String> tagIds;
  final Map<String, DesignSlot> slots;
  final int sortOrder;

  double get aspectRatio => width > 0 && height > 0 ? width / height : 1;

  factory Design.fromJson(Map<String, dynamic> j) => Design(
    id: _s(j['id']),
    categoryId: _sn(j['category_id']),
    mediaType: _s(j['media_type']),
    thumbnailUrl: _s(j['thumbnail_url'], _s(j['display_url'])),
    displayUrl: _s(j['display_url'], _s(j['thumbnail_url'])),
    width: _i(j['width'], 1080),
    height: _i(j['height'], 1080),
    timeBand: _s(j['time_band'], 'always'),
    tagIds: _ls(j['tag_ids']),
    slots: {
      for (final e in _m(j['slots']).entries)
        if (e.value is Map) e.key: DesignSlot.fromJson(_m(e.value)),
    },
    sortOrder: _i(j['sort_order']),
  );
}

class Occasion {
  const Occasion({
    required this.id,
    required this.name,
    required this.date,
    required this.categoryId,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final DateTime? date;
  final String? categoryId;
  final String? imageUrl;

  factory Occasion.fromJson(Map<String, dynamic> j) => Occasion(
    id: _s(j['id']),
    name: _s(j['name']),
    date: DateTime.tryParse(_s(j['date'])),
    categoryId: _sn(j['category_id']),
    imageUrl: _sn(j['image_url']),
  );
}

class Trade {
  const Trade({
    required this.id,
    required this.key,
    required this.name,
    required this.iconUrl,
    required this.sortOrder,
  });

  final String id;
  final String key;
  final String name;
  final String? iconUrl;
  final int sortOrder;

  factory Trade.fromJson(Map<String, dynamic> j) => Trade(
    id: _s(j['id']),
    key: _s(j['key']),
    name: _s(j['name'], _s(j['key'])),
    iconUrl: _sn(j['icon_url']),
    sortOrder: _i(j['sort_order']),
  );
}

class Plan {
  const Plan({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.features,
    required this.pricePaise,
    required this.periodDays,
    required this.isHighlighted,
    required this.sortOrder,
  });

  final String id;
  final String key;
  final String name;
  final String description;
  final List<String> features;
  final int pricePaise;
  final int periodDays;
  final bool isHighlighted;
  final int sortOrder;

  /// `19900` → `₹199`; keeps paise only when there are any.
  String get priceLabel {
    final rupees = pricePaise ~/ 100;
    final paise = pricePaise % 100;
    return paise == 0
        ? '₹$rupees'
        : '₹$rupees.${paise.toString().padLeft(2, '0')}';
  }

  factory Plan.fromJson(Map<String, dynamic> j) => Plan(
    id: _s(j['id']),
    key: _s(j['key']),
    name: _s(j['name'], _s(j['key'])),
    description: _s(j['description']),
    features: _ls(j['features']),
    pricePaise: _i(j['price_paise']),
    periodDays: _i(j['period_days']),
    isHighlighted: _b(j['is_highlighted']),
    sortOrder: _i(j['sort_order']),
  );
}

class Trial {
  const Trial({required this.days, required this.planKey});

  final int days;
  final String? planKey;

  factory Trial.fromJson(Map<String, dynamic> j) =>
      Trial(days: _i(j['days']), planKey: _sn(j['plan_key']));
}

/// `[start, end)` in hours; `end < start` wraps midnight (§5.4).
class TimeBand {
  const TimeBand(this.name, this.start, this.end);

  final String name;
  final int start;
  final int end;

  bool contains(int hour) =>
      start <= end ? hour >= start && hour < end : hour >= start || hour < end;
}

class ContentPayload {
  ContentPayload({
    required this.raw,
    required this.version,
    required this.languages,
    required this.timeBands,
    required this.home,
    required this.strings,
    required this.banners,
    required this.categories,
    required this.tags,
    required this.designs,
    required this.occasions,
    required this.trades,
    required this.plans,
    required this.trial,
  });

  /// The exact JSON the server sent, stored as-is so new fields survive.
  final Map<String, dynamic> raw;
  final int version;
  final List<Language> languages;
  final List<TimeBand> timeBands;
  final Map<String, dynamic> home;
  final Map<String, String> strings;
  final List<ContentBanner> banners;
  final List<ContentCategory> categories;
  final List<ContentTag> tags;

  /// Only designs this build can show — unknown `media_type`s are dropped.
  final List<Design> designs;
  final List<Occasion> occasions;
  final List<Trade> trades;
  final List<Plan> plans;
  final Trial trial;

  factory ContentPayload.fromJson(Map<String, dynamic> j) {
    int bySort(dynamic a, dynamic b) =>
        (a.sortOrder as int).compareTo(b.sortOrder as int);
    final bands = <TimeBand>[
      for (final e in _m(j['time_bands']).entries)
        if (e.value is List && (e.value as List).length == 2)
          TimeBand(e.key, _i((e.value as List)[0]), _i((e.value as List)[1])),
    ];
    return ContentPayload(
      raw: j,
      version: _i(j['version']),
      languages: _l(j['languages'], Language.fromJson),
      timeBands: bands,
      home: _m(j['home']),
      strings: {
        for (final e in _m(j['strings']).entries)
          if (e.value is String) e.key: e.value as String,
      },
      banners: _l(j['banners'], ContentBanner.fromJson)..sort(bySort),
      categories: _l(j['categories'], ContentCategory.fromJson)..sort(bySort),
      tags: _l(j['tags'], ContentTag.fromJson),
      designs: _l(j['designs'], Design.fromJson)
          .where((d) => d.mediaType == 'image')
          .toList()
        ..sort(bySort),
      occasions: _l(j['occasions'], Occasion.fromJson),
      trades: _l(j['trades'], Trade.fromJson)..sort(bySort),
      plans: _l(j['plans'], Plan.fromJson)..sort(bySort),
      trial: Trial.fromJson(_m(j['trial'])),
    );
  }

  String? currentBand([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    for (final b in timeBands) {
      if (b.contains(hour)) return b.name;
    }
    return null;
  }

  /// `always` is not a clock band — it shows at every hour (§5.4).
  List<Design> visibleDesigns({String? categoryId, DateTime? now}) {
    final band = currentBand(now);
    return designs
        .where((d) => d.timeBand == 'always' || d.timeBand == band)
        .where((d) => categoryId == null || d.categoryId == categoryId)
        .toList();
  }

  /// Tag-term search, no endpoint (§5.5). Matches a term that contains the
  /// query so partial typing ("diwa") still finds Diwali.
  List<Design> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final tagIds = {
      for (final t in tags)
        if (t.terms.any((term) => term.contains(q)) ||
            t.name.toLowerCase().contains(q))
          t.id,
    };
    return designs.where((d) => d.tagIds.any(tagIds.contains)).toList();
  }

  ContentCategory? category(String? id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Trade? trade(String? key) {
    for (final t in trades) {
      if (t.key == key) return t;
    }
    return null;
  }

  Plan? plan(String? key) {
    for (final p in plans) {
      if (p.key == key) return p;
    }
    return null;
  }

  /// Home category order: the server's `home.category_order` first, then
  /// any remaining top-level categories by `sort_order`.
  List<ContentCategory> homeCategories() {
    final order = _ls(home['category_order']);
    final top = categories.where((c) => c.parentId == null).toList();
    final ordered = <ContentCategory>[
      for (final id in order)
        ...top.where((c) => c.id == id),
    ];
    return [...ordered, ...top.where((c) => !order.contains(c.id))];
  }

  /// Categories to surface for the current time of day, if configured.
  List<ContentCategory> timeBandCategories([DateTime? now]) {
    final band = currentBand(now);
    if (band == null) return const [];
    final ids = _ls(_m(home['time_band_categories'])[band]);
    return [
      for (final id in ids)
        if (category(id) != null) category(id)!,
    ];
  }

  String? get carouselCategoryId => _sn(home['carousel_category_id']);
}

// ── Me / business / access ─────────────────────────────────────────────

class MeUser {
  const MeUser({
    required this.id,
    required this.phone,
    required this.name,
    required this.language,
    required this.profileComplete,
  });

  final String id;
  final String phone;
  final String? name;
  final String? language;
  final bool profileComplete;

  factory MeUser.fromJson(Map<String, dynamic> j) => MeUser(
    id: _s(j['id']),
    phone: _s(j['phone']),
    name: _sn(j['name']),
    language: _sn(j['language']),
    profileComplete: _b(j['profile_complete']),
  );
}

class ApiBusiness {
  const ApiBusiness({
    required this.id,
    required this.shopName,
    required this.tradeKey,
    required this.city,
    this.address,
    this.pincode,
    this.latitude,
    this.longitude,
    this.displayPhone,
    this.tagline,
    this.logoUrl,
    this.photoUrls = const [],
  });

  final String id;
  final String shopName;
  final String tradeKey;
  final String city;
  final String? address;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? displayPhone;
  final String? tagline;
  final String? logoUrl;
  final List<String> photoUrls;

  factory ApiBusiness.fromJson(Map<String, dynamic> j) => ApiBusiness(
    id: _s(j['id']),
    shopName: _s(j['shop_name']),
    tradeKey: _s(j['trade_key']),
    city: _s(j['city']),
    address: _sn(j['address']),
    pincode: _sn(j['pincode']),
    latitude: _d(j['latitude']),
    longitude: _d(j['longitude']),
    displayPhone: _sn(j['display_phone']),
    tagline: _sn(j['tagline']),
    logoUrl: _sn(j['logo_url']),
    photoUrls: _ls(j['photo_urls']),
  );
}

enum AccessState { none, trial, active, expired }

class Entitlements {
  const Entitlements({
    required this.postersPerDay,
    required this.videosPerWeek,
    required this.autoPosting,
  });

  final int postersPerDay;
  final int videosPerWeek;
  final bool autoPosting;

  factory Entitlements.fromJson(Map<String, dynamic> j) => Entitlements(
    postersPerDay: _i(j['posters_per_day']),
    videosPerWeek: _i(j['videos_per_week']),
    autoPosting: _b(j['auto_posting']),
  );
}

class Access {
  const Access({
    required this.state,
    required this.kind,
    required this.planKey,
    required this.endsAt,
    required this.entitlements,
  });

  final AccessState state;
  final String? kind;
  final String? planKey;
  final DateTime? endsAt;
  final Entitlements entitlements;

  bool get hasFullApp => state == AccessState.trial || state == AccessState.active;

  factory Access.fromJson(Map<String, dynamic> j) => Access(
    // Unknown states fall back to `none` — the safe, landing-page side.
    state: AccessState.values.firstWhere(
      (s) => s.name == j['state'],
      orElse: () => AccessState.none,
    ),
    kind: _sn(j['kind']),
    planKey: _sn(j['plan_key']),
    endsAt: DateTime.tryParse(_s(j['ends_at']))?.toLocal(),
    entitlements: Entitlements.fromJson(_m(j['entitlements'])),
  );
}

class WelcomeVideo {
  const WelcomeVideo({required this.status, required this.url});

  final String status;
  final String? url;

  bool get isReady => status == 'ready' && url != null;
  bool get isPending => status == 'pending';

  factory WelcomeVideo.fromJson(Map<String, dynamic> j) =>
      WelcomeVideo(status: _s(j['status']), url: _sn(j['url']));
}

class Me {
  Me({
    required this.raw,
    required this.user,
    required this.business,
    required this.access,
    required this.welcomeVideo,
  });

  final Map<String, dynamic> raw;
  final MeUser user;
  final ApiBusiness? business;
  final Access access;
  final WelcomeVideo? welcomeVideo;

  factory Me.fromJson(Map<String, dynamic> j) => Me(
    raw: j,
    user: MeUser.fromJson(_m(j['user'])),
    business: j['business'] is Map ? ApiBusiness.fromJson(_m(j['business'])) : null,
    access: Access.fromJson(_m(j['access'])),
    welcomeVideo: j['welcome_video'] is Map
        ? WelcomeVideo.fromJson(_m(j['welcome_video']))
        : null,
  );
}

/// Formats an Indian mobile for display on posters: `+91 91234 56789`.
String formatIndianPhone(String? phone) {
  if (phone == null) return '';
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  final ten = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
  if (ten.length != 10) return phone;
  return '+91 ${ten.substring(0, 5)} ${ten.substring(5)}';
}

/// Normalises pasted `+91 98765-43210` / `09876543210` to ten digits, or
/// returns null when it can't be an Indian mobile.
String? normaliseIndianMobile(String input) {
  var digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 12 && digits.startsWith('91')) digits = digits.substring(2);
  if (digits.length == 11 && digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length != 10 || !RegExp(r'^[6-9]').hasMatch(digits)) return null;
  return digits;
}
