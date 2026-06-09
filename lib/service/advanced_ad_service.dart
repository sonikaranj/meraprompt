import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:async';

class AdvancedAdService {
  static final AdvancedAdService _instance = AdvancedAdService._internal();

  factory AdvancedAdService() {
    return _instance;
  }

  AdvancedAdService._internal();

  final GetStorage _box = GetStorage();
  int _impressionCount = 0;
  int _rewardedAdCount = 0;
  DateTime _sessionStart = DateTime.now();

  // High value moments for showing interstitials
  bool isHighValueMoment() {
    // Show interstitials on important actions
    // Adjust based on your app flow
    return _impressionCount % 5 == 0; // Every 5 impressions
  }

  // Track impressions for analytics
  void trackImpression(String adType) {
    _impressionCount++;
    _box.write('total_impressions', (_box.read('total_impressions') ?? 0) + 1);
    _box.write('last_impression_time', DateTime.now().millisecondsSinceEpoch);

    print('Impression #$_impressionCount - Type: $adType');
  }

  // Track rewarded ads separately (higher value)
  void trackRewardedAdShown() {
    _rewardedAdCount++;
    _box.write('rewarded_ad_count', _rewardedAdCount);
    trackImpression('rewarded');
  }

  // Get session duration (for frequency capping)
  Duration getSessionDuration() {
    return DateTime.now().difference(_sessionStart);
  }

  // Recommended ad mix for better eCPM
  Map<String, int> getRecommendedAdMix() {
    final sessionMinutes = getSessionDuration().inMinutes;

    if (sessionMinutes < 5) {
      return {
        'banner': 1,
        'interstitial': 0,
        'rewarded': 0,
        'native': 0,
      };
    } else if (sessionMinutes < 15) {
      return {
        'banner': 1,
        'interstitial': 1,
        'rewarded': 0,
        'native': 1,
      };
    } else {
      return {
        'banner': 1,
        'interstitial': 2,
        'rewarded': 1,
        'native': 2,
      };
    }
  }

  // Best performing ad format for low eCPM
  // Priority: Rewarded > Interstitial > Native > Banner
  String getRecommendedAdFormat() {
    if (_rewardedAdCount < 2) return 'rewarded'; // Prioritize rewarded
    if (_impressionCount % 5 == 0) return 'interstitial'; // Then interstitial
    if (_impressionCount % 3 == 0) return 'native'; // Then native
    return 'banner'; // Last banner
  }

  // Analytics for monitoring eCPM
  Future<void> logAdMetrics() async {
    final metrics = {
      'total_impressions': _box.read('total_impressions') ?? 0,
      'rewarded_ads': _rewardedAdCount,
      'session_duration_minutes': getSessionDuration().inMinutes,
      'timestamp': DateTime.now().toIso8601String(),
    };

    print('📊 Ad Metrics: $metrics');
    // Send to Firebase Analytics or your backend
  }
}
