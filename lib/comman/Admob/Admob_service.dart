import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class AdUnits {
  static const String interstitialTest =
      'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedTest = 'ca-app-pub-3940256099942544/5224354917';
  static const String nativeTest = 'ca-app-pub-3940256099942544/2247696110';
  static String interstitial = interstitialTest;
  static String rewarded = rewardedTest;
  static String native = nativeTest;
  static Future<void> loadFromRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    final jsonString = remoteConfig.getString('ad_units');
    if (jsonString.isEmpty) return;
    final Map<String, dynamic> adUnitsMap = jsonDecode(jsonString);
    interstitial = _safeId(adUnitsMap['interstitial'], interstitialTest);
    rewarded = _safeId(adUnitsMap['rewarded'], rewardedTest);
    native = _safeId(adUnitsMap['native'], nativeTest);
  }

  static String _safeId(String? id, String fallback) {
    if (id == null) return fallback;
    if (id.startsWith('ca-app-pub-') && id.length > 20) return id;
    return fallback;
  }
}

class AdController extends GetxController {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  // NativeAd? _nativeAd;
  final RxBool isAdLoading = false.obs;
  final RxBool isAdLoaded = false.obs;
  final RxBool isRewardedLoading = false.obs;
  final RxBool isRewardedLoaded = false.obs;
  final RxBool isNativeLoading = false.obs;
  final RxBool isNativeLoaded = false.obs;
  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    preloadInterstitialAd();
    preloadRewardedAd();
    // preloadNativeAd();
  }

  void preloadInterstitialAd() {
    final adUnitId = AdUnits.interstitial;
    if (isAdLoading.value || isAdLoaded.value) return;
    isAdLoading.value = true;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          isAdLoaded.value = true;
          isAdLoading.value = false;
          _interstitialAd
              ?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isAdLoaded.value = false;
              preloadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              isAdLoaded.value = false;
              preloadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          isAdLoading.value = false;
        },
      ),
    );
  }

  void showOrLoadInterstitialAd() {
    final adUnitId = AdUnits.interstitial;
    if (isAdLoaded.value && _interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      Get.generalDialog(
        barrierDismissible: false,
        barrierLabel: "Loading",
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.8),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Loading Interstitial Ad...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      );
      isAdLoading.value = true;
      InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            Get.back();
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                preloadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                preloadInterstitialAd();
              },
            );
            ad.show();
            isAdLoaded.value = false;
            isAdLoading.value = false;
          },
          onAdFailedToLoad: (LoadAdError error) {
            Get.back();
            isAdLoading.value = false;
          },
        ),
      );
    }
  }

  void preloadRewardedAd() {
    final adUnitId = AdUnits.rewarded;
    if (isRewardedLoading.value || isRewardedLoaded.value) return;
    isRewardedLoading.value = true;
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          isRewardedLoaded.value = true;
          isRewardedLoading.value = false;
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isRewardedLoaded.value = false;
              preloadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              isRewardedLoaded.value = false;
              preloadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          isRewardedLoading.value = false;
        },
      ),
    );
  }

  void showOrLoadRewardedAd({required VoidCallback onRewarded}) {
    final adUnitId = AdUnits.rewarded;
    if (isRewardedLoaded.value && _rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onRewarded();
        },
      );
    } else {
      Get.generalDialog(
        barrierDismissible: false,
        barrierLabel: "Loading",
        pageBuilder: (context, animation, secondaryAnimation) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.8),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Loading Rewarded Ad...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      );
      isRewardedLoading.value = true;
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            Get.back();
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                preloadRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                preloadRewardedAd();
              },
            );
            ad.show(
              onUserEarnedReward: (ad, reward) {
                onRewarded();
              },
            );
            isRewardedLoaded.value = false;
            isRewardedLoading.value = false;
          },
          onAdFailedToLoad: (LoadAdError error) {
            Get.back();
            isRewardedLoading.value = false;
          },
        ),
      );
    }
  }

  // void preloadNativeAd() {
  //   final adUnitId = AdUnits.native;
  //   if (isNativeLoading.value || isNativeLoaded.value) return;
  //   isNativeLoading.value = true;
  //   _nativeAd = NativeAd(
  //     adUnitId: adUnitId,
  //     factoryId: 'listTile',
  //     request: const AdRequest(),
  //     listener: NativeAdListener(
  //       onAdLoaded: (ad) {
  //         isNativeLoaded.value = true;
  //         isNativeLoading.value = false;
  //       },
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //         isNativeLoading.value = false;
  //       },
  //     ),
  //   )..load();
  // }
  //
  // NativeAd? get nativeAd => _nativeAd;
  @override
  void onClose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    // _nativeAd?.dispose();
    super.onClose();
  }
}
