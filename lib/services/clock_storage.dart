import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/world_clock.dart';

/// Persists the user's list of clocks locally so custom clocks
/// survive an app restart.
class ClockStorage {
  static const _key = 'world_clocks_v1';

  static Future<List<WorldClock>?> loadClocks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((e) => WorldClock.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveClocks(List<WorldClock> clocks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(clocks.map((c) => c.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
