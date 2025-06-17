import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vogu_health/core/interfaces/local_storage.dart';

class LocalStorageImpl implements LocalStorage {
  final SharedPreferences _prefs;
  static const String _sleepDataKey = 'pending_sleep_data';
  static const String _heartRateDataKey = 'pending_heart_rate_data';
  static const String _weightDataKey = 'pending_weight_data';

  LocalStorageImpl(this._prefs);

  @override
  Future<void> insertSleepData(dynamic data) async {
    final List<String> existing = _prefs.getStringList(_sleepDataKey) ?? [];
    existing.add(jsonEncode(data));
    await _prefs.setStringList(_sleepDataKey, existing);
  }

  @override
  Future<void> insertHeartRateData(dynamic data) async {
    final List<String> existing = _prefs.getStringList(_heartRateDataKey) ?? [];
    existing.add(jsonEncode(data));
    await _prefs.setStringList(_heartRateDataKey, existing);
  }

  @override
  Future<void> insertWeightData(dynamic data) async {
    final List<String> existing = _prefs.getStringList(_weightDataKey) ?? [];
    existing.add(jsonEncode(data));
    await _prefs.setStringList(_weightDataKey, existing);
  }

  @override
  Future<List<dynamic>> getPendingSleepData() async {
    final List<String>? data = _prefs.getStringList(_sleepDataKey);
    return data?.map((e) => jsonDecode(e)).toList() ?? [];
  }

  @override
  Future<List<dynamic>> getPendingHeartRateData() async {
    final List<String>? data = _prefs.getStringList(_heartRateDataKey);
    return data?.map((e) => jsonDecode(e)).toList() ?? [];
  }

  @override
  Future<List<dynamic>> getPendingWeightData() async {
    final List<String>? data = _prefs.getStringList(_weightDataKey);
    return data?.map((e) => jsonDecode(e)).toList() ?? [];
  }

  @override
  Future<void> clearPendingSleepData() async {
    await _prefs.remove(_sleepDataKey);
  }

  @override
  Future<void> clearPendingHeartRateData() async {
    await _prefs.remove(_heartRateDataKey);
  }

  @override
  Future<void> clearPendingWeightData() async {
    await _prefs.remove(_weightDataKey);
  }
} 