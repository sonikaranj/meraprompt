import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get_storage/get_storage.dart';

class EcpmOptimizer {
  static final EcpmOptimizer _instance = EcpmOptimizer._internal();

  factory EcpmOptimizer() {
    return _instance;
  }

  EcpmOptimizer._internal();

  final GetStorage _box = GetStorage();

  // High eCPM countries (US, UK, Canada, Australia)
  static const List<String> highEcpmCountries = [
    'US', 'GB', 'CA', 'AU', 'DE', 'FR', 'NZ', 'IE'
  ];

  // Get user country (you need to implement this)
  String? getUserCountry() {
    return _box.read('user_country');
  }

  // Recommended ad placement strategy for low eCPM
  Map<String, dynamic> getOptimizedAdStrategy() {
    final country = getUserCountry();
    final isHighValueCountry = highEcpmCountries.contains(country);

    return {
      'banner': {
        'show': true,
        'frequency': 'always', // Always show banner
        'placement': 'bottom',
      },
      'interstitial': {
        'show': true,
        'frequency': 'every_5_minutes',
        'showProbability': isHighValueCountry ? 0.8 : 0.5,
        'placement': ['screen_transition', 'major_action'],
      },
      'rewarded': {
        'show': true,
        'frequency': 'on_demand',
        'placement': ['unlock_feature', 'get_extra_content'],
      },
      'native': {
        'show': true,
        'count': 2,
        'placement': ['content_feed'],
      },
      'rewardedInterstitial': {
        'show': true,
        'frequency': 'optional',
        'placement': ['skip_waiting', 'remove_ads_trial'],
      },
    };
  }

  // Request configuration for better targeting
  RequestConfiguration getOptimizedRequestConfig() {
    return RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.g,
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
    );
  }

  // Check if should show interstitial based on strategy
  bool shouldShowInterstitial() {
    final country = getUserCountry();
    final isHighValue = highEcpmCountries.contains(country);

    if (isHighValue) {
      // High value countries: 80% chance
      return DateTime.now().millisecond > 200;
    } else {
      // Other countries: 50% chance
      return DateTime.now().millisecond > 500;
    }
  }
}
