import 'package:shared_preferences/shared_preferences.dart';

class FirstLaunchService {
  static const String _firstLaunchKey = 'is_first_launch';

  // ⭐ Premium key
  static const String _isPremiumKey = 'is_premium_user';

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Get SharedPreferences instance
  static Future<SharedPreferences> get _instance async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ✅ Check if user is opening app for first time
  static Future<bool> isFirstLaunch() async {
    final prefs = await _instance;
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  // ✅ Set first launch completed
  static Future<void> setFirstLaunchDone() async {
    final prefs = await _instance;
    await prefs.setBool(_firstLaunchKey, false);
  }

  // ✅ Reset first launch (for testing)
  static Future<void> resetFirstLaunch() async {
    final prefs = await _instance;
    await prefs.setBool(_firstLaunchKey, true);
  }

  // ===============================
  // ⭐ PREMIUM USER METHODS
  // ===============================

  // ✅ Check if user is premium
  static Future<bool> isUserPremium() async {
    final prefs = await _instance;
    return prefs.getBool(_isPremiumKey) ?? false; // Default: NOT premium
  }

  // ✅ Set user as premium
  static Future<void> setUserPremium(bool value) async {
    final prefs = await _instance;
    await prefs.setBool(_isPremiumKey, value);
  }

  // ✅ Remove premium (logout / subscription expired)
  static Future<void> resetPremium() async {
    final prefs = await _instance;
    await prefs.remove(_isPremiumKey);
  }
}
