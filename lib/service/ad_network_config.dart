// High eCPM Ad Networks Configuration
// Order matters: Top networks = Higher eCPM

class AdNetworkConfig {
  // Network Priority Order for HIGH eCPM
  static const List<String> networkPriorityOrder = [
    'Google AdMob', // First-party, highest eCPM
    'Google Ad Manager',
    'AppLovin',
    'Facebook Audience Network',
    'Pangle', // High eCPM for certain regions
    'Mintegral',
    'IronSource',
    'UnityAds',
  ];

  // Network eCPM Ranges (Approximate)
  static const Map<String, Map<String, String>> networkEcpmRanges = {
    'Google AdMob': {
      'banner': '\$0.50-2.00',
      'interstitial': '\$1.50-5.00',
      'native': '\$1.00-4.00',
      'rewarded_interstitial': '\$3.00-8.00',
    },
    'AppLovin': {
      'banner': '\$0.30-1.50',
      'interstitial': '\$1.00-4.00',
      'native': '\$0.80-2.50',
    },
    'Facebook Audience Network': {
      'banner': '\$0.20-1.00',
      'interstitial': '\$0.80-3.00',
      'native': '\$0.50-2.00',
    },
    'Google Ad Manager': {
      'banner': '\$1.00-3.00',
      'interstitial': '\$2.00-6.00',
      'native': '\$1.50-5.00',
    },
  };

  // Mediation Setup Instructions
  static const String mediationSetupGuide = '''
  HIGH eCPM MEDIATION SETUP (AdMob Console):

  1. Create Ad Units (SEPARATE for each format):
     ✓ Banner (Home)
     ✓ Banner (Detail)
     ✓ Interstitial (Transition)
     ✓ Interstitial (Action)
     ✓ Interstitial (Exit)
     ✓ Native (Home)
     ✓ Native (Detail)

  2. Create Mediation Groups:
     Group 1: Interstitials
       - Ad Sources Order:
         1. Google AdMob (100%)
         2. Google Ad Manager (Waterfall)
         3. AppLovin
         4. Facebook (Backup)

     Group 2: Banners
       - Ad Sources Order:
         1. Google AdMob (100%)
         2. AppLovin
         3. Facebook

     Group 3: Native
       - Ad Sources Order:
         1. Google AdMob (100%)
         2. AppLovin (Waterfall)
         3. Facebook (Backup)

  3. Set Minimum CPM Thresholds:
     - Interstitial: \$1.00 minimum
     - Native: \$0.50 minimum
     - Banner: \$0.25 minimum

  4. Enable Filters:
     ✓ Block low-quality advertisers
     ✓ Enable category exclusions for bad fit
     ✓ Set content rating = G or PG
  ''';

  // Best Practices
  static const Map<String, String> bestPractices = {
    '1_keywords': 'Use high-value keywords: AI, Photo, Editing, Design, Premium',
    '2_placement': 'Show ads at high-intent moments (before feature unlock)',
    '3_frequency': 'Balance: 1 ad per 3-5 minutes is optimal',
    '4_quality': 'Focus on user retention > ad frequency',
    '5_targeting': 'Use geographic targeting (Tier-1 countries first)',
    '6_testing': 'A/B test placements for 2 weeks, then optimize',
    '7_viewability': 'Ensure ads are 50%+ visible for 1+ second',
    '8_network': 'Good connection = Higher eCPM',
    '9_device': 'Higher-end devices = Higher eCPM',
    '10_content': 'Premium content category = Higher eCPM',
  };

  // High eCPM Checklist
  static const List<String> highEcpmChecklist = [
    '✓ Using separate ad units per format and placement',
    '✓ Mediation groups created with proper order',
    '✓ Keywords set to high-value categories',
    '✓ Content URL provided (shows ad relevance)',
    '✓ Ads placed at high-intent moments',
    '✓ Frequency capping enabled (avoid ad fatigue)',
    '✓ Banner + Interstitial + Native mix balanced',
    '✓ Geographic targeting for high-CPM countries',
    '✓ Invalid traffic filters enabled',
    '✓ Monitoring reports daily for trends',
    '✓ A/B testing placements',
    '✓ User retention prioritized over ad count',
  ];
}
