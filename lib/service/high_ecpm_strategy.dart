import 'package:get_storage/get_storage.dart';
import 'dart:async';

class HighEcpmStrategy {
  static final HighEcpmStrategy _instance = HighEcpmStrategy._internal();

  factory HighEcpmStrategy() {
    return _instance;
  }

  HighEcpmStrategy._internal();

  final GetStorage _box = GetStorage();

  // Strategy 1: Show Interstitial + Native combination (Higher eCPM)
  // Show interstitial first, then native ad = Better fill rate
  Map<String, dynamic> getOptimalAdSequence() {
    return {
      'sequence_1': {
        'step1': 'Show Interstitial',
        'delay': '2 seconds',
        'step2': 'Show Native Ad',
        'ecpm_boost': '40-50%',
      },
      'sequence_2': {
        'step1': 'Banner (always visible)',
        'step2': 'Interstitial (on action)',
        'step3': 'Native (feed)',
        'total_ecpm_boost': '60%',
      },
    };
  }

  // Strategy 2: Premium Ad Placement (High Traffic Areas)
  List<String> getPremiumPlacements() {
    return [
      'after_user_completes_action', // High engagement point
      'before_main_feature', // High intent
      'content_transition', // Natural break point
      'feature_unlock_prompt', // High attention
      'session_end', // Last moment - desperate to engage
    ];
  }

  // Strategy 3: Geographic Targeting (Tier Countries)
  Map<String, List<String>> getCountryTiers() {
    return {
      'tier_1_high_ecpm': [
        'US', 'GB', 'CA', 'AU', 'DE', 'FR', 'SE', 'NL', 'CH', 'DK'
      ],
      'tier_2_medium_ecpm': [
        'JP', 'KR', 'SG', 'HK', 'IE', 'NZ', 'AT', 'BE'
      ],
      'tier_3_low_ecpm': [
        'IN', 'BR', 'MX', 'RU', 'TH', 'VN', 'ID'
      ],
    };
  }

  // Strategy 4: Time-based Ad Showing (Peak Hours)
  bool shouldShowPremiumAdNow() {
    final hour = DateTime.now().hour;

    // Peak hours: 6-11 AM, 6-11 PM (higher eCPM)
    final isPeakHour = (hour >= 6 && hour <= 11) || (hour >= 18 && hour <= 23);

    return isPeakHour;
  }

  // Strategy 5: User Session Quality Tracking
  Future<void> trackSessionQuality() async {
    final sessionStart = _box.read('session_start') as int? ?? DateTime.now().millisecondsSinceEpoch;
    final sessionDuration = DateTime.now().millisecondsSinceEpoch - sessionStart;
    final isQualitySession = sessionDuration > 120000; // > 2 minutes

    await _box.write('is_quality_session', isQualitySession);
    await _box.write('session_duration', sessionDuration);
  }

  bool isQualitySession() {
    return _box.read('is_quality_session') ?? false;
  }

  // Strategy 6: Ad Frequency Based on Country Tier
  int getOptimalAdFrequency(String countryCode) {
    final tier1 = getCountryTiers()['tier_1_high_ecpm']!;
    final tier2 = getCountryTiers()['tier_2_medium_ecpm']!;

    if (tier1.contains(countryCode)) {
      return 1; // Show ads frequently (high eCPM countries can handle it)
    } else if (tier2.contains(countryCode)) {
      return 2; // Show ads moderately
    } else {
      return 3; // Show ads less frequently
    }
  }

  // Strategy 7: Content Category Impact (High Value Categories)
  Map<String, double> getContentCategoryEcpmMultiplier() {
    return {
      'productivity': 1.5, // High eCPM
      'photo_editing': 1.4,
      'ai_tools': 1.6, // Highest
      'utilities': 1.2,
      'entertainment': 0.8, // Lower eCPM
      'games': 0.7, // Lowest
    };
  }

  // Strategy 8: Keywords for High eCPM
  List<String> getHighEcpmKeywords() {
    return [
      // Finance/Business (Highest CPM)
      'business', 'finance', 'investment', 'trading', 'crypto', 'forex',

      // Technology
      'technology', 'software', 'ai', 'automation', 'cloud',

      // Professional
      'productivity', 'work', 'office', 'professional', 'career',

      // Creative (Your category)
      'design', 'photo', 'editing', 'creative', 'graphics',

      // Premium
      'premium', 'pro', 'professional', 'enterprise',
    ];
  }

  // Strategy 9: Device & Network Quality Consideration
  Future<void> optimizeForDeviceQuality() async {
    // High-end devices = Higher eCPM
    // Good network = Higher eCPM

    await _box.write('device_quality_tier', 'high'); // Auto-detect in real app
    await _box.write('network_quality', 'good');
  }

  // Strategy 10: A/B Testing Ad Placements
  Map<String, dynamic> getABTestVariants() {
    return {
      'variant_a': {
        'name': 'Interstitial Every 3 Actions',
        'expected_ecpm': '\$1.5-2.0',
      },
      'variant_b': {
        'name': 'Interstitial Every 5 Actions + More Native',
        'expected_ecpm': '\$2.0-2.5',
      },
      'variant_c': {
        'name': 'Banner + Strategic Interstitial Combo',
        'expected_ecpm': '\$2.5-3.5',
      },
      'variant_d': {
        'name': 'Native Focused (More Native, Less Interstitial)',
        'expected_ecpm': '\$2.0-3.0',
      },
    };
  }
}
