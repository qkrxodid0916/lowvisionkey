import 'package:shared_preferences/shared_preferences.dart';

class FontPrefs {
  static String _kHasScale(String uid) => 'has_font_scale__$uid';
  static String _kScale(String uid) => 'font_scale__$uid';

  static Future<bool> hasFontScale(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kHasScale(uid)) ?? false;
  }

  static Future<double> getFontScale(String uid, {double fallback = 1.0}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_kScale(uid)) ?? fallback;
  }

  static Future<void> setFontScale(String uid, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kScale(uid), value);
    await prefs.setBool(_kHasScale(uid), true);
  }

  static Future<void> clearFontScale(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kScale(uid));
    await prefs.remove(_kHasScale(uid));
  }
}