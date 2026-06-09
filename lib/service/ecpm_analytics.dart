import 'package:get_storage/get_storage.dart';

class EcpmAnalytics {
  static final EcpmAnalytics _instance = EcpmAnalytics._internal();

  factory EcpmAnalytics() {
    return _instance;
  }

  EcpmAnalytics._internal();

  final GetStorage _box = GetStorage();

  // Track ad impressions with details
  Future<void> trackAdImpression({
    required String adType, // banner, interstitial, native
    required String placement,
    required String country,
    required bool isAdShown,
  }) async {
    final impressions = (_box.read('ad_impressions') ?? 0) as int;
    await _box.write('ad_impressions', impressions + 1);

    final log = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': adType,
      'placement': placement,
      'country': country,
      'shown': isAdShown,
    };

    // Log to analytics
    print('📊 Ad Impression: $log');
  }

  // Track ad clicks
  Future<void> trackAdClick({
    required String adType,
    required String placement,
  }) async {
    final clicks = (_box.read('ad_clicks') ?? 0) as int;
    await _box.write('ad_clicks', clicks + 1);

    print('👆 Ad Click: $adType - $placement');
  }

  // Calculate CTR (Click Through Rate)
  double getClickThroughRate() {
    final clicks = (_box.read('ad_clicks') ?? 0) as int;
    final impressions = (_box.read('ad_impressions') ?? 1) as int;

    return (clicks / impressions) * 100;
  }

  // Estimate daily revenue (rough)
  double estimateDailyRevenue({
    required int dailyImpressions,
    required double ecpm,
  }) {
    return (dailyImpressions / 1000) * ecpm;
  }

  // Monitor eCPM trends
  Map<String, dynamic> getEcpmTrends() {
    final impressions = (_box.read('ad_impressions') ?? 0) as int;
    final clicks = (_box.read('ad_clicks') ?? 0) as int;
    final ctr = getClickThroughRate();

    return {
      'total_impressions': impressions,
      'total_clicks': clicks,
      'ctr_percentage': '${ctr.toStringAsFixed(2)}%',
      'status': ctr > 3.0 ? '✅ Good' : '⚠️ Low',
      'recommendation': ctr < 2.0 ? 'Check ad placements' : 'Placements performing well',
    };
  }

  // High eCPM indicator
  bool isHighEcpmPossible() {
    final trends = getEcpmTrends();
    final ctr = double.tryParse(
        (trends['ctr_percentage'] as String).replaceAll('%', '')) ?? 0;

    // CTR > 3% usually indicates good eCPM
    return ctr > 3.0;
  }

  // Recommendations for improvement
  List<String> getEcpmImprovementTips() {
    final ctr = getClickThroughRate();
    final impressions = (_box.read('ad_impressions') ?? 0) as int;

    return [
      if (impressions < 1000) '⚠️ Need more traffic (target: 1000+ impressions/day)',
      if (ctr < 1.0) '⚠️ CTR is very low - optimize ad placements',
      if (ctr < 2.0) '⚠️ CTR below 2% - consider A/B testing',
      if (ctr > 3.0) '✅ Good CTR - maintain current placements',
      '✅ Ensure ads are at high-intent moments (action transitions)',
      '✅ Use geographic targeting for Tier-1 countries',
      '✅ Keep keywords relevant and high-value',
      '✅ Monitor for ad fatigue - adjust frequency if needed',
      '✅ Test native ads - usually have better CTR',
    ];
  }

  // Reset analytics (monthly)
  Future<void> resetMonthlyAnalytics() async {
    await _box.remove('ad_impressions');
    await _box.remove('ad_clicks');
  }
}
