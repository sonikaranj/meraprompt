// lib/comman/featchdata/app_config.dart
import 'package:get_storage/get_storage.dart';

class AppConfig {
  // Persistent cache so server-driven theme colors apply on the very next
  // launch (before the network call returns) instead of flashing defaults.
  static final GetStorage _box = GetStorage();
  static const String _kThemeCacheKey = 'theme_colors';

  // ---- Server-driven theme colors (hex strings like 'FF2563EB') ----
  // Defaults are the Ocean Blue (dark) palette; used until the server overrides.
  static String themePrimary = 'FF2563EB'; // primary blue
  static String themeAccent = 'FF06B6D4'; // cyan accent
  static String themeBackground = 'FF0A0E1A'; // dark navy bg
  static String themeSurface = 'FF131A2B'; // navy surface / cards
  static String themeText = 'FFFFFFFF'; // primary text

  // App info
  static int version = 0;
  static String privacyPolicyUrl = '/privacy.html';
  static String termsAndConditionsUrl = '/terms-and-conditions.html';
  static String supportEmail = '';
  static String appShareLink = '';
  static String telegram = '';
  static String instraggram = '';
  static String whatsapplink = '';
  static String popupAds = '';
  static String popupMessage = '';

  // Feature toggles
  static bool showAds = false;
  static bool IsPrimiumUser = false; // maps from 'show_premium'

  // SDK / keys
  static String sdkKey = '';

  // Ad unit IDs
  static String interstitialAdUnitId = '';
  static String rewardedAdUnitId =  '';
  static String bannerAdUnitId =  '';
  static String appOpen = '';
  static String mrecAdUnitId = ''; // MREC test
  static String nativeAdUnitId =  '';

  static bool _readBool(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }

  static String _readString(dynamic value, String fallback) {
    if (value == null) return fallback;
    final parsed = value.toString().trim();
    return parsed.isEmpty ? fallback : parsed;
  }

  static String _readStringAllowEmpty(dynamic value, String fallback) {
    if (value == null) return fallback;
    return value.toString().trim();
  }

  // Normalize a hex color from the server into an 8-digit ARGB string.
  // Accepts '#2563EB', '0xFF2563EB', '2563eb', 'FF2563EB', etc.
  // Returns [fallback] if the value is missing or unparseable.
  static String _readColor(dynamic value, String fallback) {
    if (value == null) return fallback;
    var hex = value.toString().trim().toUpperCase();
    hex = hex.replaceAll('#', '').replaceAll('0X', '');
    if (hex.length == 6) hex = 'FF$hex'; // add full opacity if alpha omitted
    if (hex.length != 8 || int.tryParse(hex, radix: 16) == null) {
      return fallback;
    }
    return hex;
  }

  // Apply remote config JSON
  static void applyFromJson(Map<String, dynamic> json) {
    version = json['version'] ?? version;
    privacyPolicyUrl = json['privacyPolicyUrl'] ?? privacyPolicyUrl;
    termsAndConditionsUrl = json['termsAndConditionsUrl'] ?? termsAndConditionsUrl;
    supportEmail = json['email'] ?? supportEmail;
    showAds = _readBool(json['showAds'] ?? json['showads'], showAds);
    IsPrimiumUser = _readBool(
      json['show_premium'] ?? json['show_primium'],
      IsPrimiumUser,
    );
    sdkKey = json['sdk_key'] ?? sdkKey;
    appOpen = json['appOpen'] ?? appOpen;

    // Ads
    interstitialAdUnitId = json['interstitialAdUnitId'] ?? interstitialAdUnitId;
    rewardedAdUnitId = json['rewardedAdUnitId'] ?? rewardedAdUnitId;
    bannerAdUnitId = json['bannerAdUnitId'] ?? bannerAdUnitId;
    mrecAdUnitId = json['mrecAdUnitId'] ?? mrecAdUnitId;
    nativeAdUnitId = json['nativeAdUnitId'] ?? nativeAdUnitId;

    appShareLink = _readString(
      json['appShareLink'] ?? json['appsharelink'],
      appShareLink,
    );
    telegram = _readString(json['telegram'], telegram);
    instraggram = _readString(
      json['instraggram'] ?? json['instagram'],
      instraggram,
    );
    whatsapplink = _readString(
      json['whatsapplink'] ?? json['whatsappLink'] ?? json['whatsapp'],
      whatsapplink,
    );
    popupAds = _readStringAllowEmpty(
      json['popupads'] ?? json['popupAds'],
      popupAds,
    );
    popupMessage = _readStringAllowEmpty(
      json['popupmessage'] ?? json['popupMessage'] ?? json['popup_message'],
      popupMessage,
    );

    // ---- Theme colors (server-driven) ----
    // Supports a nested "theme": { "primary": "...", ... } object or flat keys.
    final theme = (json['theme'] is Map)
        ? json['theme'] as Map<String, dynamic>
        : json;
    themePrimary = _readColor(
      theme['primary'] ?? theme['primaryColor'] ?? theme['themeColor'],
      themePrimary,
    );
    themeAccent = _readColor(
      theme['accent'] ?? theme['accentColor'] ?? theme['secondary'],
      themeAccent,
    );
    themeBackground = _readColor(
      theme['background'] ?? theme['backgroundColor'] ?? theme['bg'],
      themeBackground,
    );
    themeSurface = _readColor(
      theme['surface'] ?? theme['surfaceColor'] ?? theme['card'],
      themeSurface,
    );
    themeText = _readColor(
      theme['text'] ?? theme['textColor'],
      themeText,
    );

    _saveThemeCache();
  }

  // Persist the current theme colors so the next launch can apply them
  // immediately, before the network fetch completes.
  static void _saveThemeCache() {
    _box.write(_kThemeCacheKey, {
      'primary': themePrimary,
      'accent': themeAccent,
      'background': themeBackground,
      'surface': themeSurface,
      'text': themeText,
    });
  }

  // Load cached theme colors. Call this in main() before runApp() so the
  // last server-provided theme is in memory for the first frame.
  static void loadThemeCache() {
    final cached = _box.read(_kThemeCacheKey);
    if (cached is Map) {
      themePrimary = _readColor(cached['primary'], themePrimary);
      themeAccent = _readColor(cached['accent'], themeAccent);
      themeBackground = _readColor(cached['background'], themeBackground);
      themeSurface = _readColor(cached['surface'], themeSurface);
      themeText = _readColor(cached['text'], themeText);
    }
  }

  // Reset to default values
  static void reset() {
    version = 0;
    privacyPolicyUrl = '';
    termsAndConditionsUrl = '';
    supportEmail = '';
    showAds = false;
    IsPrimiumUser = false;
    sdkKey = '';
    interstitialAdUnitId = '';
    rewardedAdUnitId = '';
    bannerAdUnitId = '';
    mrecAdUnitId = '';
    nativeAdUnitId = '';
    appShareLink = '';
    telegram = '';
    instraggram = '';
    whatsapplink = '';
    popupAds = '';
    popupMessage = '';
    appOpen = '';
  }
}
