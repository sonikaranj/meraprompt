// lib/comman/featchdata/app_config.dart
class AppConfig {
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
