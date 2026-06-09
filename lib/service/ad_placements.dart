// Ad Placement Examples - Use these placement strings throughout your app

class AdPlacements {
  // Banner placements
  static const String bannerHome = 'home';
  static const String bannerDetail = 'detail';

  // Interstitial placements
  static const String interstitialScreenTransition = 'transition';
  static const String interstitialUserAction = 'action';
  static const String interstitialAppExit = 'exit';

  // Rewarded placements
  static const String rewardedUnlock = 'unlock';
  static const String rewardedBonus = 'bonus';

  // Native placements
  static const String nativeHomeFeed = 'home';
  static const String nativeDetail = 'detail';
}

// Usage Examples in different screens:

/*

HOME SCREEN:
```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AdService _adService;

  @override
  void initState() {
    super.initState();
    _adService = Get.find<AdService>();
    // Load banner for home screen
    _adService.loadBannerAd(AdPlacements.bannerHome);
    // Load native ad for home feed
    _adService.loadNativeAd(AdPlacements.nativeHomeFeed);
    // Pre-load interstitial for transitions
    _adService.loadInterstitialAd(AdPlacements.interstitialScreenTransition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Your home screen content
          Expanded(
            child: ListView(
              children: [
                // Content items
                // Show native ad every 5 items
                if (_adService.getNativeAd() != null)
                  NativeAdWidget(nativeAd: _adService.getNativeAd()!),
              ],
            ),
          ),
          // Banner at bottom
          if (_adService.getBannerAd() != null)
            Container(
              width: double.infinity,
              height: 50,
              child: AdWidget(ad: _adService.getBannerAd()!),
            ),
        ],
      ),
    );
  }
}
```

DETAIL SCREEN:
```dart
class DetailScreen extends StatefulWidget {
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late AdService _adService;

  @override
  void initState() {
    super.initState();
    _adService = Get.find<AdService>();
    // Load banner for detail screen
    _adService.loadBannerAd(AdPlacements.bannerDetail);
    // Load native ad for detail
    _adService.loadNativeAd(AdPlacements.nativeDetail);
  }

  void onScreenExit() {
    // Show interstitial on app exit
    _adService.loadInterstitialAd(AdPlacements.interstitialAppExit);
    _adService.showInterstitialAd(AdPlacements.interstitialAppExit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Detail content
          if (_adService.getNativeAd() != null)
            NativeAdWidget(nativeAd: _adService.getNativeAd()!),
        ],
      ),
    );
  }
}
```

UNLOCK FEATURE:
```dart
void unlockFeature() {
  _adService.loadRewardedAd(AdPlacements.rewardedUnlock);
  _adService.showRewardedAd(
    AdPlacements.rewardedUnlock,
    (rewardItem) {
      print('User earned reward: ${rewardItem.amount}');
      // Unlock feature
    },
  );
}
```

BONUS ACTION:
```dart
void claimBonus() {
  _adService.loadRewardedAd(AdPlacements.rewardedBonus);
  _adService.showRewardedAd(
    AdPlacements.rewardedBonus,
    (rewardItem) {
      print('Bonus reward: ${rewardItem.amount}');
      // Award bonus to user
    },
  );
}
```

*/
