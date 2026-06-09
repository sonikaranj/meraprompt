import 'package:get_storage/get_storage.dart';

class AdStrategyService {
  static final AdStrategyService _instance = AdStrategyService._internal();

  factory AdStrategyService() {
    return _instance;
  }

  AdStrategyService._internal();

  final GetStorage _box = GetStorage();

  static const String _lastInterstitialKey = 'last_interstitial_time';
  static const Duration _interstitialCooldown = Duration(minutes: 5);

  // Check agar interstitial ad show kar sakte ho
  bool canShowInterstitial() {
    final lastTime = _box.read(_lastInterstitialKey) as int?;
    if (lastTime == null) return true;

    final difference = DateTime.now().millisecondsSinceEpoch - lastTime;
    return difference >= _interstitialCooldown.inMilliseconds;
  }

  // Record last interstitial show time
  Future<void> recordInterstitialShown() async {
    await _box.write(
      _lastInterstitialKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Rewarded ad - Always show (users want it)
  bool shouldShowRewardedAd() => true;

  // Native ad - Show 1-2 times per session
  bool shouldShowNativeAd(int showCount) {
    return showCount < 2;
  }

  // Banner ad - Always show (non-intrusive)
  bool shouldShowBannerAd() => true;
}
