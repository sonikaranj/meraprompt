import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

class PlacementSpecificAdService {
  static final PlacementSpecificAdService _instance = PlacementSpecificAdService._internal();

  factory PlacementSpecificAdService() {
    return _instance;
  }

  PlacementSpecificAdService._internal();

  // HOME SCREEN AD UNITS (Specific for each action)
  // Coin button clicked
  static const String homeInterstitialCoinClick = 'ca-app-pub-xxxxxxxxxxxxxxxx/home_coin_click';

  // Prompt unlock action
  static const String homeInterstitialPromptUnlock = 'ca-app-pub-xxxxxxxxxxxxxxxx/home_prompt_unlock';

  // Home screen banner (bottom)
  static const String homeBannerBottom = 'ca-app-pub-xxxxxxxxxxxxxxxx/home_banner_bottom';

  // Home screen native ad (between content)
  static const String homeNativeAd = 'ca-app-pub-xxxxxxxxxxxxxxxx/home_native';

  // DETAIL SCREEN AD UNITS
  // Feature unlock
  static const String detailInterstitialFeatureUnlock = 'ca-app-pub-xxxxxxxxxxxxxxxx/detail_feature_unlock';

  // Detail screen banner
  static const String detailBannerBottom = 'ca-app-pub-xxxxxxxxxxxxxxxx/detail_banner_bottom';

  // Detail screen native ad
  static const String detailNativeAd = 'ca-app-pub-xxxxxxxxxxxxxxxx/detail_native';

  // TRANSITION SCREEN AD UNITS
  static const String transitionInterstitial = 'ca-app-pub-xxxxxxxxxxxxxxxx/transition_interstitial';

  // Ad instances
  Map<String, InterstitialAd?> _interstitialAds = {};
  Map<String, BannerAd?> _bannerAds = {};
  Map<String, NativeAd?> _nativeAds = {};

  bool _isInitialized = false;
  Timer? _preloadTimer;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;

    // Start pre-loading ads in background
    _startPreloadingAds();
  }

  // Pre-load ads in background for faster showing
  void _startPreloadingAds() {
    _preloadTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      // Pre-load common interstitials
      _preloadInterstitial('coin_click');
      _preloadInterstitial('prompt_unlock');
      _preloadInterstitial('feature_unlock');
    });
  }

  // ==================== HOME SCREEN ADS ====================

  // Coin button clicked - Show interstitial
  Future<void> loadCoinClickAd() async {
    await _loadInterstitialAd(
      'coin_click',
      homeInterstitialCoinClick,
    );
  }

  Future<void> showCoinClickAd() async {
    await _showInterstitialAd('coin_click');
  }

  // Prompt unlock - Show interstitial
  Future<void> loadPromptUnlockAd() async {
    await _loadInterstitialAd(
      'prompt_unlock',
      homeInterstitialPromptUnlock,
    );
  }

  Future<void> showPromptUnlockAd() async {
    await _showInterstitialAd('prompt_unlock');
  }

  // Home banner - Load and get
  void loadHomeBanner() {
    _loadBannerAd('home_banner', homeBannerBottom);
  }

  BannerAd? getHomeBanner() => _bannerAds['home_banner'];

  // Home native ad
  Future<void> loadHomeNativeAd() async {
    await _loadNativeAd('home_native', homeNativeAd);
  }

  NativeAd? getHomeNativeAd() => _nativeAds['home_native'];

  // ==================== DETAIL SCREEN ADS ====================

  // Feature unlock - Show interstitial
  Future<void> loadFeatureUnlockAd() async {
    await _loadInterstitialAd(
      'feature_unlock',
      detailInterstitialFeatureUnlock,
    );
  }

  Future<void> showFeatureUnlockAd() async {
    await _showInterstitialAd('feature_unlock');
  }

  // Detail banner
  void loadDetailBanner() {
    _loadBannerAd('detail_banner', detailBannerBottom);
  }

  BannerAd? getDetailBanner() => _bannerAds['detail_banner'];

  // Detail native ad
  Future<void> loadDetailNativeAd() async {
    await _loadNativeAd('detail_native', detailNativeAd);
  }

  NativeAd? getDetailNativeAd() => _nativeAds['detail_native'];

  // ==================== TRANSITION ADS ====================

  Future<void> loadTransitionAd() async {
    await _loadInterstitialAd(
      'transition',
      transitionInterstitial,
    );
  }

  Future<void> showTransitionAd() async {
    await _showInterstitialAd('transition');
  }

  // ==================== INTERNAL METHODS ====================

  Future<void> _loadInterstitialAd(String key, String adUnitId) async {
    // Avoid loading if already loaded
    if (_interstitialAds[key] != null) {
      print('✅ Interstitial already loaded: $key');
      return;
    }

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAds[key] = ad;
          print('📢 Interstitial Ad Loaded [$key]');
        },
        onAdFailedToLoad: (error) {
          print('❌ Interstitial Failed [$key]: ${error.message}');
        },
      ),
    );
  }

  Future<void> _showInterstitialAd(String key) async {
    final ad = _interstitialAds[key];
    if (ad == null) {
      print('⚠️ No ad loaded for: $key');
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAds[key] = null;
        _preloadInterstitial(key); // Re-load after showing
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAds[key] = null;
      },
    );

    await ad.show();
  }

  void _preloadInterstitial(String key) {
    final adUnitMap = {
      'coin_click': homeInterstitialCoinClick,
      'prompt_unlock': homeInterstitialPromptUnlock,
      'feature_unlock': detailInterstitialFeatureUnlock,
      'transition': transitionInterstitial,
    };

    final adUnitId = adUnitMap[key];
    if (adUnitId != null) {
      _loadInterstitialAd(key, adUnitId);
    }
  }

  void _loadBannerAd(String key, String adUnitId) {
    _bannerAds[key] = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => print('🎯 Banner Loaded [$key]'),
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner Failed [$key]: ${error.message}');
          ad.dispose();
          _bannerAds[key] = null;
        },
      ),
    );
    _bannerAds[key]?.load();
  }

  Future<void> _loadNativeAd(String key, String adUnitId) async {
    _nativeAds[key] = NativeAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) => print('🎨 Native Ad Loaded [$key]'),
        onAdFailedToLoad: (ad, error) {
          print('❌ Native Failed [$key]: ${error.message}');
          ad.dispose();
          _nativeAds[key] = null;
        },
      ),
    );
    await _nativeAds[key]?.load();
  }

  void dispose() {
    _preloadTimer?.cancel();
    _interstitialAds.forEach((key, ad) => ad?.dispose());
    _bannerAds.forEach((key, ad) => ad?.dispose());
    _nativeAds.forEach((key, ad) => ad?.dispose());
    _interstitialAds.clear();
    _bannerAds.clear();
    _nativeAds.clear();
  }
}
