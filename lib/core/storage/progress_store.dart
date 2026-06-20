import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressStore {
  static const _keyCurrentLevel = 'currentLevel';
  static const _keyStars = 'stars';
  static const _keyHints = 'hints';
  static const _keySoundOn = 'soundOn';
  static const _keyHapticsOn = 'hapticsOn';
  static const _keyDailyDone = 'dailyDone';
  static const _keyOnboarded = 'onboarded';

  final SharedPreferences _prefs;

  ProgressStore._(this._prefs);

  static Future<ProgressStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressStore._(prefs);
  }

  int get currentLevel => _prefs.getInt(_keyCurrentLevel) ?? 1;
  set currentLevel(int v) => _prefs.setInt(_keyCurrentLevel, v);

  bool get soundEnabled => _prefs.getBool(_keySoundOn) ?? true;
  set soundEnabled(bool v) => _prefs.setBool(_keySoundOn, v);

  bool get hapticsEnabled => _prefs.getBool(_keyHapticsOn) ?? true;
  set hapticsEnabled(bool v) => _prefs.setBool(_keyHapticsOn, v);

  bool get onboarded => _prefs.getBool(_keyOnboarded) ?? false;
  set onboarded(bool v) => _prefs.setBool(_keyOnboarded, v);

  int get hints => _prefs.getInt(_keyHints) ?? 3;
  set hints(int v) => _prefs.setInt(_keyHints, v);

  Map<int, int> get allStars {
    final raw = _prefs.getString(_keyStars);
    if (raw == null) return {};
    final Map<String, dynamic> m = jsonDecode(raw);
    return m.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  void setLevelStars(int level, int stars) {
    final m = allStars;
    if ((m[level] ?? 0) < stars) {
      m[level] = stars;
      _prefs.setString(_keyStars, jsonEncode(m.map((k, v) => MapEntry(k.toString(), v))));
    }
  }

  int getLevelStars(int level) => allStars[level] ?? 0;

  Set<String> get dailyDone {
    final raw = _prefs.getStringList(_keyDailyDone) ?? [];
    return raw.toSet();
  }

  void markDailyDone(String dateKey) {
    final s = dailyDone;
    s.add(dateKey);
    _prefs.setStringList(_keyDailyDone, s.toList());
  }

  bool isDailyDone(String dateKey) => dailyDone.contains(dateKey);

  Future<void> resetProgress() async {
    await _prefs.clear();
  }
}
