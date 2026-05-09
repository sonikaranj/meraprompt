import 'dart:io';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:promptseen/Admob/app_config.dart';


/// =====================
/// AD UNIT IDS
/// =====================
class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConfig.bannerAdUnitId;
    } else if (Platform.isIOS) {
      return AppConfig.bannerAdUnitId;
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppConfig.interstitialAdUnitId;
    } else if (Platform.isIOS) {
      return AppConfig.interstitialAdUnitId;
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return AppConfig.rewardedAdUnitId;
    } else if (Platform.isIOS) {
      return AppConfig.rewardedAdUnitId;
    }
    throw UnsupportedError("Unsupported platform");
  }

  /// 🔥 Rewarded Interstitial
  static String get rewardedInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppConfig.rewardedAdUnitId; // TEST
    } else if (Platform.isIOS) {
      return AppConfig.rewardedAdUnitId;
    }
    throw UnsupportedError("Unsupported platform");
  }

  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return AppConfig.appOpen;
    } else if (Platform.isIOS) {
      return AppConfig.appOpen;
    }
    throw UnsupportedError("Unsupported platform");
  }
}

/// =====================
/// AD CONTROLLER
/// =====================
class AdController extends GetxController {
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;
  RewardedInterstitialAd? rewardedInterstitialAd;
  AppOpenAd? _appOpenAd;

  var isBannerReady = false.obs;
  var isInterstitialReady = false.obs;
  var isRewardedReady = false.obs;
  var isRewardedInterstitialReady = false.obs;

  bool isFirstTime = true;
  bool _isAppOpenAdReady = false;

  /// =====================
  /// 🔥 FORCE ADS VARIABLE 🔥
  /// =====================
  /// Agar ye `true` ho toh premium user ko bhi ads dikhenge
  /// Agar ye `false` ho toh AppConfig.IsPrimiumUser check hoga
  bool forceShowAdsForPremium = false;

  /// Helper method to check if ads should be shown
  bool shouldShowAds() {
    // Agar forceShowAdsForPremium true hai toh hamesha ads dikhao
    if (forceShowAdsForPremium) {
      return true;
    }
    // Agar premium user hai toh ads na dikhao
    if (AppConfig.IsPrimiumUser) {
      return false;
    }
    // Baaki sab ko ads dikhao
    return true;
  }

  /// =====================
  /// INIT
  /// =====================
  @override
  void onInit() {
    super.onInit();

    MobileAds.instance.initialize();

    Future.delayed(const Duration(seconds: 1), () {
      // Only load ads if user is not premium (or forceShowAdsForPremium is true)
      if (shouldShowAds()) {
        loadBannerAd();
        loadInterstitialAd();
        loadRewardedAd();
        loadRewardedInterstitialAd();
        loadAndShowAppOpenFirstTime();
        print("✅ Ads loaded");
      } else {
        print("⭐ Premium user - Ads disabled");
      }
    });
  }

  /// =====================
  /// BANNER
  /// =====================
  void loadBannerAd() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Banner ads disabled");
      return;
    }

    bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => isBannerReady.value = true,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          isBannerReady.value = false;
        },
      ),
    )..load();
  }

  /// =====================
  /// INTERSTITIAL
  /// =====================
  void loadInterstitialAd() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Interstitial ads disabled");
      return;
    }

    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isInterstitialReady.value = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isInterstitialReady.value = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (_) => isInterstitialReady.value = false,
      ),
    );
  }

  void showInterstitialAd() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Skipping interstitial ad");
      return;
    }

    if (isInterstitialReady.value && interstitialAd != null) {
      interstitialAd!.show();
    }
  }

  /// =====================
  /// REWARDED
  /// =====================
  void loadRewardedAd() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Rewarded ads disabled");
      return;
    }

    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isRewardedReady.value = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isRewardedReady.value = false;
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (_) => isRewardedReady.value = false,
      ),
    );
  }

  void showRewardedAd(Function(num amount) onReward) {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Rewarded ad skipped");
      return;
    }

    if (isRewardedReady.value && rewardedAd != null) {
      rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onReward(reward.amount);
        },
      );
    }
  }

  /// =====================
  /// 🔥 REWARDED INTERSTITIAL
  /// =====================
  void loadRewardedInterstitialAd() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Rewarded interstitial ads disabled");
      return;
    }

    RewardedInterstitialAd.load(
      adUnitId: AdHelper.rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback:
      RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedInterstitialAd = ad;
          isRewardedInterstitialReady.value = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isRewardedInterstitialReady.value = false;
              loadRewardedInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (_) =>
        isRewardedInterstitialReady.value = false,
      ),
    );
  }

  void showRewardedInterstitialAd(Function(num amount) onReward) {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Rewarded interstitial ad skipped");
      return;
    }

    if (isRewardedInterstitialReady.value &&
        rewardedInterstitialAd != null) {
      rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          onReward(reward.amount);
        },
      );
    }
  }

  /// =====================
  /// APP OPEN
  /// =====================
  void loadAppOpenAd() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - App open ads disabled");
      return;
    }

    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdReady = true;
        },
        onAdFailedToLoad: (_) => _isAppOpenAdReady = false,
      ),
    );
  }

  void loadAndShowAppOpenFirstTime() async {
    if (!isFirstTime) {
      return;
    }

    if (!shouldShowAds()) {
      print("⭐ Premium user - App open ad skipped");
      isFirstTime = false;
      return;
    }

    await Future.delayed(const Duration(seconds: 2));
    loadAppOpenAd();

    await Future.delayed(const Duration(seconds: 2));
    if (_isAppOpenAdReady && _appOpenAd != null) {
      _appOpenAd!.show();
    }
    isFirstTime = false;
  }

  /// =====================
  /// 🔥 TOGGLE FORCE ADS 🔥
  /// =====================
  /// Ye method use karo force ads ko on/off karne ke liye
  void setForceShowAdsForPremium(bool value) {
    forceShowAdsForPremium = value;
    print("🔥 forceShowAdsForPremium: $forceShowAdsForPremium");

    if (forceShowAdsForPremium) {
      print("🔥 Premium user ko bhi ads dikhenge!");
    } else {
      print("✅ AppConfig.IsPrimiumUser ka normal logic chalega");
    }
  }

  /// =====================
  /// DISPOSE
  /// =====================
  @override
  void onClose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();
    rewardedInterstitialAd?.dispose();
    _appOpenAd?.dispose();
    super.onClose();
  }
}