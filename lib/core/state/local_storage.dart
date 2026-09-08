import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pehchaan/core/models/business.dart';
import 'package:pehchaan/core/models/creative.dart';

/// Simple key-value persistence for what the user has already filled in —
/// business details and saved creatives — so they survive an app restart.
/// A stand-in for a real backend/database until this app has one.
class LocalStorage {
  LocalStorage._();

  static const _businessKey = 'pehchaan.business';
  static const _creativesKey = 'pehchaan.creatives';

  static Future<void> saveBusiness(Business business) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessKey, jsonEncode(business.toJson()));
  }

  static Future<Business?> loadBusiness() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_businessKey);
    if (raw == null) return null;
    try {
      return Business.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveCreatives(List<Creative> creatives) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(creatives.map((c) => c.toJson()).toList());
    await prefs.setString(_creativesKey, raw);
  }

  static Future<List<Creative>?> loadCreatives() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_creativesKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => Creative.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }
}
