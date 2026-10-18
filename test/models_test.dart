import 'package:flutter_test/flutter_test.dart';

import 'package:pehchaan/core/api/models.dart';

Map<String, dynamic> _design(String id, {String band = 'always', String type = 'image', List<String> tags = const []}) => {
  'id': id,
  'category_id': 'c1',
  'media_type': type,
  'thumbnail_url': 'https://x/$id-t.webp',
  'display_url': 'https://x/$id-d.webp',
  'width': 1080,
  'height': 1350,
  'time_band': band,
  'tag_ids': tags,
  'slots': {
    'name': {'x': 120, 'y': 1500, 'w': 840, 'h': 90, 'color_options': ['#ffffff', '#ffd700']},
  },
  'sort_order': 0,
  'some_future_field': {'ignored': true},
};

ContentPayload _payload() => ContentPayload.fromJson({
  'version': 12,
  'time_bands': {
    'morning': [4, 11],
    'afternoon': [11, 16],
    'evening': [16, 20],
    'night': [20, 4],
  },
  'tags': [
    {'id': 't1', 'name': 'दिवाली', 'terms': ['diwali', 'दिवाली', 'Deepavali']},
  ],
  'designs': [
    _design('a'),
    _design('m', band: 'morning'),
    _design('n', band: 'night', tags: ['t1']),
    _design('v', type: 'video'),
  ],
  'plans': [
    {'key': 'growth', 'name': 'ग्रोथ', 'price_paise': 19900, 'period_days': 30, 'is_highlighted': true, 'sort_order': 1},
    {'key': 'basic', 'name': 'Basic', 'price_paise': 9950, 'period_days': 30, 'sort_order': 0},
  ],
  'trial': {'days': 3, 'plan_key': 'growth'},
});

void main() {
  group('content payload', () {
    test('skips unknown media types', () {
      expect(_payload().designs.map((d) => d.id), isNot(contains('v')));
    });

    test('"always" shows in every band; night wraps midnight', () {
      final p = _payload();
      List<String> at(int hour) =>
          p.visibleDesigns(now: DateTime(2026, 10, 18, hour)).map((d) => d.id).toList();

      expect(at(7), unorderedEquals(['a', 'm']));
      expect(at(13), ['a']);
      expect(at(23), unorderedEquals(['a', 'n']));
      expect(at(2), unorderedEquals(['a', 'n']));
      expect(at(4), unorderedEquals(['a', 'm']));
    });

    test('search matches tag terms, case-insensitive and partial', () {
      final p = _payload();
      expect(p.search('Diwali').map((d) => d.id), ['n']);
      expect(p.search('deepa').map((d) => d.id), ['n']);
      expect(p.search('दिवाली').map((d) => d.id), ['n']);
      expect(p.search('holi'), isEmpty);
      expect(p.search('  '), isEmpty);
    });

    test('plans sort by sort_order and format paise', () {
      final p = _payload();
      expect(p.plans.map((x) => x.key), ['basic', 'growth']);
      expect(p.plan('growth')!.priceLabel, '₹199');
      expect(p.plan('basic')!.priceLabel, '₹99.50');
    });

    test('parses slots and ignores unknown keys', () {
      final slot = _payload().designs.first.slots['name']!;
      expect(slot.w, 840);
      expect(slot.colorOptions, ['#ffffff', '#ffd700']);
    });
  });

  group('me', () {
    test('null business and unknown access state are safe', () {
      final me = Me.fromJson({
        'user': {'id': 'u', 'phone': '+919876543210'},
        'business': null,
        'access': {'state': 'something_new'},
        'welcome_video': null,
      });
      expect(me.business, isNull);
      expect(me.access.state, AccessState.none);
      expect(me.access.hasFullApp, isFalse);
      expect(me.welcomeVideo, isNull);
    });

    test('trial grants the full app', () {
      final me = Me.fromJson({
        'user': {'id': 'u'},
        'business': {'id': 'b', 'shop_name': 'Shree Sweets', 'trade_key': 'food', 'city': 'Pune'},
        'access': {'state': 'trial', 'ends_at': '2026-10-15T10:57:17.469Z'},
      });
      expect(me.access.hasFullApp, isTrue);
      expect(me.business!.shopName, 'Shree Sweets');
      expect(me.access.endsAt, isNotNull);
    });
  });

  group('phone helpers', () {
    test('normalises pasted Indian numbers', () {
      expect(normaliseIndianMobile('9876543210'), '9876543210');
      expect(normaliseIndianMobile('+91 98765-43210'), '9876543210');
      expect(normaliseIndianMobile('09876543210'), '9876543210');
      expect(normaliseIndianMobile('12345'), isNull);
      expect(normaliseIndianMobile('1234567890'), isNull);
    });

    test('formats for posters', () {
      expect(formatIndianPhone('+919123456789'), '+91 91234 56789');
      expect(formatIndianPhone(null), '');
    });
  });
}
