import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

class AdService {
  static final AdService _instance = AdService._internal();

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  // BANNER AD UNITS
  static const String bannerAdUnitHome = 'ca-app-pub-xxxxxxxxxxxxxxxx/banner_home';
  static const String bannerAdUnitDetail = 'ca-app-pub-xxxxxxxxxxxxxxxx/banner_detail';

  // INTERSTITIAL AD UNITS (Different placements)
  static const String interstitialUnitScreenTransition = 'ca-app-pub-xxxxxxxxxxxxxxxx/interstitial_transition';
  static const String interstitialUnitUserAction = 'ca-app-pub-xxxxxxxxxxxxxxxx/interstitial_action';
  static const String interstitialUnitAppExit = 'ca-app-pub-xxxxxxxxxxxxxxxx/interstitial_exit';

  // NATIVE AD UNITS
  static const String nativeUnitHomeFeed = 'ca-app-pub-xxxxxxxxxxxxxxxx/native_home_feed';
  static const String nativeUnitDetailScreen = 'ca-app-pub-xxxxxxxxxxxxxxxx/native_detail';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  NativeAd? _nativeAd;

  bool _isInitialized = false;
  Timer? _adRefreshTimer;
  int _interstitialShowCount = 0;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;
    _startAdRefreshCycle();
  }

  // Pre-load ads for better performance
  void _startAdRefreshCycle() {
    _adRefreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      loadInterstitialAd('transition');
    });
  }

  // Banner Ad - Load specific placement
  void loadBannerAd(String placement) {
    final adUnitId = placement == 'home' ? bannerAdUnitHome : bannerAdUnitDetail;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('Banner Ad Loaded: $placement'),
        onAdFailedToLoad: (ad, error) {
          print('Banner Ad Failed [$placement]: ${error.message}');
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  BannerAd? getBannerAd() => _bannerAd;

  // Interstitial Ad - Load specific placement
  Future<void> loadInterstitialAd(String placement) async {
    final adUnitId = _getInterstitialAdUnit(placement);

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          print('Interstitial Ad Loaded: $placement');
        },
        onAdFailedToLoad: (error) {
          print('Interstitial Ad Failed [$placement]: ${error.message}');
        },
      ),
    );
  }

  String _getInterstitialAdUnit(String placement) {
    switch (placement) {
      case 'transition':
        return interstitialUnitScreenTransition;
      case 'action':
        return interstitialUnitUserAction;
      case 'exit':
        return interstitialUnitAppExit;
      default:
        return interstitialUnitScreenTransition;
    }
  }

  Future<void> showInterstitialAd(String placement) async {
    _interstitialShowCount++;

    if (_interstitialShowCount % 3 == 0 && _interstitialAd != null) {
      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd(placement);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
        },
      );
      await _interstitialAd?.show();
    } else {
      loadInterstitialAd(placement);
    }
  }

  // Native Ad - Load specific placement
  Future<void> loadNativeAd(String placement) async {
    final adUnitId = placement == 'home' ? nativeUnitHomeFeed : nativeUnitDetailScreen;

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('Native Ad Loaded: $placement');
        },
        onAdFailedToLoad: (ad, error) {
          print('Native Ad Failed [$placement]: ${error.message}');
          ad.dispose();
        },
      ),
    );
    await _nativeAd?.load();
  }

  NativeAd? getNativeAd() => _nativeAd;

  void dispose() {
    _adRefreshTimer?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _nativeAd?.dispose();
  }
}
