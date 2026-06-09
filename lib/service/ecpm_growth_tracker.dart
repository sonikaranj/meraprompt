import 'package:get_storage/get_storage.dart';

class EcpmGrowthTracker {
  static final EcpmGrowthTracker _instance = EcpmGrowthTracker._internal();

  factory EcpmGrowthTracker() {
    return _instance;
  }

  EcpmGrowthTracker._internal();

  final GetStorage _box = GetStorage();

  // Expected eCPM growth trajectory
  static const Map<String, double> expectedEcpmGrowth = {
    'week_1': 0.7,
    'week_2': 0.85,
    'week_3': 1.0,
    'week_4': 1.3,
    'month_2': 1.8,
    'month_3': 2.5,
    'month_4': 3.0,
    'month_5': 3.5,
    'month_6': 4.0,
  };

  // Track weekly eCPM
  Future<void> recordWeeklyEcpm(double ecpm) async {
    final weekNumber = getWeekNumber();
    await _box.write('ecpm_week_$weekNumber', ecpm);

    print('📈 Week $weekNumber eCPM: \$$ecpm');
  }

  // Get current week number (1-52)
  int getWeekNumber() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(firstDay).inDays + 1;
    return (dayOfYear / 7).ceil();
  }

  // Track daily impressions
  Future<void> recordDailyImpressions(int impressions) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    await _box.write('impressions_$today', impressions);

    print('👁️ Today Impressions: $impressions');
  }

  // Get weekly average impressions
  int getWeeklyAverageImpressions() {
    int total = 0;
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      total += (_box.read('impressions_$dateStr') ?? 0) as int;
    }
    return total ~/ 7;
  }

  // Growth projection based on current trend
  Map<String, dynamic> getGrowthProjection() {
    final week1Ecpm = _box.read('ecpm_week_1') ?? 0.7;
    final week4Ecpm = _box.read('ecpm_week_4') ?? 1.3;

    double growthRate = 0;
    if (week1Ecpm > 0) {
      growthRate = ((week4Ecpm - week1Ecpm) / week1Ecpm) * 100;
    }

    return {
      'current_growth_rate': '${growthRate.toStringAsFixed(1)}%',
      'healthy_growth_rate': '>30% per month',
      'status': growthRate > 30 ? '✅ On track' : '⚠️ Below expected',
      'projection_month_3': _box.read('ecpm_week_4') ?? 1.3 * 2,
      'projection_month_6': _box.read('ecpm_week_4') ?? 1.3 * 3.5,
    };
  }

  // Factors affecting growth
  static const List<String> growthFactors = [
    '📊 Data Volume: More impressions = Better optimization',
    '🎯 Traffic Quality: High-quality users = Higher eCPM',
    '⏰ Time on Platform: Longer sessions = More ad opportunities',
    '🌍 Geographic Distribution: Tier-1 countries = Higher eCPM',
    '📈 Advertiser Competition: More demand = Higher CPM',
    '🔧 Ad Configuration: Proper setup = Better performance',
    '🎨 Ad Placements: Strategic placement = Higher engagement',
    '💬 User Engagement: Better CTR = Higher eCPM',
  ];

  // Milestones tracker
  Map<String, dynamic> getGrowthMilestones() {
    final currentEcpm = _box.read('current_ecpm') ?? 0.7;

    return {
      'milestone_1x': {
        'target_ecpm': 0.7,
        'status': currentEcpm >= 0.7 ? '✅ Achieved' : '⏳ In Progress',
      },
      'milestone_2x': {
        'target_ecpm': 1.4,
        'status': currentEcpm >= 1.4 ? '✅ Achieved' : '⏳ In Progress',
        'eta': 'Week 3-4',
      },
      'milestone_3x': {
        'target_ecpm': 2.1,
        'status': currentEcpm >= 2.1 ? '✅ Achieved' : '⏳ In Progress',
        'eta': 'Month 2',
      },
      'milestone_5x': {
        'target_ecpm': 3.5,
        'status': currentEcpm >= 3.5 ? '✅ Achieved' : '⏳ In Progress',
        'eta': 'Month 3-4',
      },
    };
  }

  // What NOT to do (can hurt growth)
  static const List<String> avoidTheseMistakes = [
    '❌ Don\'t change ad units frequently (confuses algorithm)',
    '❌ Don\'t use same ad unit for different placements',
    '❌ Don\'t ignore low-performing placements',
    '❌ Don\'t show ads excessively (user fatigue)',
    '❌ Don\'t target low-CPM countries only',
    '❌ Don\'t have inconsistent traffic',
    '❌ Don\'t skip mediation setup',
    '❌ Don\'t block Google\'s auto-optimization',
    '❌ Don\'t use ad fraud or click farms',
    '❌ Don\'t pause ads for long periods',
  ];

  // Monthly optimization checklist
  static const Map<String, List<String>> monthlyChecklist = {
    'month_1': [
      '✅ Setup 7 separate ad units',
      '✅ Configure mediation groups',
      '✅ Set keywords and content URL',
      '✅ Monitor daily impressions',
      '✅ Check for invalid traffic',
    ],
    'month_2': [
      '✅ Analyze placement performance',
      '✅ A/B test ad placements',
      '✅ Adjust frequency capping',
      '✅ Monitor CTR trends',
      '✅ Review eCPM growth',
    ],
    'month_3': [
      '✅ Scale high-performing placements',
      '✅ Optimize mediation order',
      '✅ Consider geographic targeting',
      '✅ Review user retention metrics',
      '✅ Plan next quarter strategy',
    ],
  };

  // Real-time monitoring
  Future<void> printGrowthSummary() async {
    final weeklyAvg = getWeeklyAverageImpressions();
    final projection = getGrowthProjection();
    final milestones = getGrowthMilestones();

    print('''
    ╔════════════════════════════════════════╗
    ║     eCPM GROWTH TRACKING SUMMARY       ║
    ╚════════════════════════════════════════╝

    📊 Weekly Stats:
    - Average Daily Impressions: $weeklyAvg
    - Growth Rate: ${projection['current_growth_rate']}
    - Status: ${projection['status']}

    💡 Tips:
    - Maintain consistent daily traffic
    - Monitor for algorithm improvements (week 3-4)
    - A/B test placements monthly
    - Avoid sudden changes to setup
    ''');
  }
}
