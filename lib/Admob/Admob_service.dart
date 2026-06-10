import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:promptseen/Admob/app_config.dart';
import 'package:promptseen/service/connectivity_service.dart';


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
class AdController extends GetxController with WidgetsBindingObserver {
  // Banner / MREC ab AdController me owned nahi — [MrecAdBox] widget khud
  // manage karta hai (neeche).
  RewardedAd? rewardedAd;
  AppOpenAd? _appOpenAd;

  /// =====================
  /// REWARDED-INTERSTITIAL POOL (unlock ke liye)
  /// =====================
  /// 2-3 rewarded ads hamesha preloaded rakhte hain, taaki "Unlock Prompt" par
  /// turant ad mile aur loading dialog dikhe hi na. Ek dikhne par pool
  /// background me dobara bhar jata hai.
  static const int _rewardedPoolTarget = 3; // 2-3 ready ads
  final List<RewardedInterstitialAd> _rewardedPool = [];
  int _rewardedLoadsInFlight = 0;

  /// =====================
  /// INTERSTITIAL POOL
  /// =====================
  /// Hum hamesha 2-3 interstitial ads preloaded rakhte hain taaki request
  /// aate hi turant ek dikhayi ja sake (koi wait nahi). Jaise hi ek dikhti
  /// hai, pool background me dobara fill ho jaata hai.
  static const int _interstitialPoolTarget = 3; // 2-3 ready ads
  // NOTE: Regular AdMob `InterstitialAd` ADX `/...` units ke saath bhi load
  // hoti hai (live app me production-tested), isliye yahi use karte hain.
  final List<InterstitialAd> _interstitialPool = [];
  int _interstitialLoadsInFlight = 0;

  var isInterstitialReady = false.obs;
  var isRewardedReady = false.obs;
  // Pool me koi rewarded ad ready hai kya (pool.isNotEmpty ka mirror).
  var isRewardedInterstitialReady = false.obs;

  bool isFirstTime = true;
  bool _isAppOpenAdReady = false;

  /// =====================
  /// 🔥 FORCE ADS VARIABLE 🔥
  /// =====================
  /// Agar ye `true` ho toh premium user ko bhi ads dikhenge
  /// Agar ye `false` ho toh AppConfig.IsPrimiumUser check hoga
  bool forceShowAdsForPremium = false;

  /// Ad unit id valid (real) hai ya nahi. Valid formats: "/..." (Ad Manager/
  /// AdX) ya "ca-app-pub-..." (AdMob). Khali/fake id par ads off rakhte hain
  /// taaki crash/policy issue na ho.
  bool _isValidAdUnitId(String? id) {
    if (id == null) return false;
    final t = id.trim();
    if (t.isEmpty) return false;
    return t.startsWith('/') || t.startsWith('ca-app-pub-');
  }

  /// Helper method to check if ads should be shown
  bool shouldShowAds() {
    // Config se ads band hain toh kabhi mat dikhao
    if (!AppConfig.showAds) {
      return false;
    }
    // Ad unit id fake/khali hai toh ads off (warna load fail + policy risk)
    if (!_isValidAdUnitId(AppConfig.interstitialAdUnitId)) {
      print('⚠️ Invalid interstitial ad unit ID - ads disabled');
      return false;
    }
    // Force mode: testing ke liye premium user ko bhi ads dikhao
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

  /// Net hai ya nahi. ConnectivityService registered na ho to true maan lete
  /// hain (load attempt SDK khud handle karega).
  bool get isOnline => !Get.isRegistered<ConnectivityService>() ||
      Get.find<ConnectivityService>().isConnected.value;

  /// Google Ad Inspector kholta hai — bidding debug karne ka OFFICIAL tareeka.
  /// Har ad unit ke saare ad sources dikhte hain: kisne bid kiya, kisne fill
  /// kiya, aur jo source skip hua uska exact error (e.g. Meta "no fill" /
  /// "not configured"). Sirf registered test device par khulta hai
  /// (debug build me emulator/test device chalega).
  void openAdInspector() {
    MobileAds.instance.openAdInspector((error) {
      if (error != null) {
        print('❌ Ad Inspector: ${error.message} (${error.code})');
      }
    });
  }

  /// Kis network ne ye ad fill ki (AdMob / Meta / ...). Bidding debug karne
  /// ke liye — logcat me "via Facebook Audience Network" dikhe to Meta ka
  /// bid jeeta.
  static String adSourceOf(Ad ad) {
    final info = ad.responseInfo?.loadedAdapterResponseInfo;
    if (info == null) return 'unknown';
    final source = info.adSourceName;
    return source.isNotEmpty ? source : info.adapterClassName;
  }

  /// =====================
  /// INIT
  /// =====================
  @override
  void onInit() {
    super.onInit();
    // App resume par App Open ad dikhane ke liye lifecycle observe karo.
    WidgetsBinding.instance.addObserver(this);
    _gatherConsentThenInit();
    _retryWhenBackOnline();
  }

  /// GDPR/UMP consent: EU/UK users ko Google ka consent form dikhana zaroori
  /// he — bina iske wahan ads serve nahi hoti (revenue loss + policy issue).
  /// Non-EU regions me form required nahi hota, flow seedha aage badhta he.
  /// Consent fail ho jaye to bhi SDK init karte hain (limited ads chalti hain).
  void _gatherConsentThenInit() {
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
              if (formError != null) {
                print('⚠️ Consent form: ${formError.message}');
              }
            });
          }
        } catch (e) {
          print('⚠️ Consent flow error: $e');
        }
        _initMobileAds();
      },
      (formError) {
        print('⚠️ Consent info update failed: ${formError.message}');
        _initMobileAds();
      },
    );
  }

  bool _sdkStarted = false;

  Future<void> _initMobileAds() async {
    if (_sdkStarted) return;
    _sdkStarted = true;
    // Debug build: real device ko test device bana do taaki live ad unit IDs
    // par bhi sirf test ads aayein (invalid-traffic / account ban se bachav).
    // Emulator AdMob ke liye automatically test device hota hai. Apne phone ka
    // hash logcat me "RequestConfiguration.Builder.setTestDeviceIds" line se
    // milta hai — use neeche list me daalo.
    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: <String>[
          // 'YOUR_DEVICE_HASH',
        ]),
      );
    }

    final status = await MobileAds.instance.initialize();
    // Mediation adapters ka init state — Meta (Facebook) adapter yahan
    // "ready" dikhna chahiye, warna bidding kaam nahi karegi.
    status.adapterStatuses.forEach((name, adapter) {
      print('🔌 Adapter $name: ${adapter.state.name} (${adapter.description})');
    });

    // Only load ads if user is not premium (or forceShowAdsForPremium is true)
    if (shouldShowAds()) {
      // NOTE: Banner / MREC ab yahaan owned nahi hai. Har placement
      // self-contained [MrecAdBox] widget use karta hai (file ke neeche),
      // jo apna BannerAd khud create/dispose karta hai. Ek shared BannerAd ko
      // rebuild hone wale AdWidget me wrap karna hi
      // "This AdWidget is already in the Widget tree" crash deta tha.
      loadInterstitialAd();
      loadRewardedAd();
      loadRewardedInterstitialAd();
      loadAndShowAppOpenFirstTime();
      print("✅ Ads loaded");
    } else {
      print("⭐ Premium user - Ads disabled");
    }
  }

  /// Net wapas aate hi khali pools dobara bhar do (offline me load attempts
  /// skip hote hain, isliye yahi ek hi re-entry point chahiye).
  void _retryWhenBackOnline() {
    if (!Get.isRegistered<ConnectivityService>()) return;
    ever(Get.find<ConnectivityService>().isConnected, (bool connected) {
      if (connected && shouldShowAds()) {
        print('🌐 Back online - refilling ad pools');
        _preloadInterstitials();
        _preloadRewarded();
        if (rewardedAd == null) loadRewardedAd();
      }
    });
  }

  /// =====================
  /// INTERSTITIAL (POOL)
  /// =====================

  /// Public entry (compat): pool ko target tak top-up karta hai.
  void loadInterstitialAd() => _preloadInterstitials();

  /// Pool me jitne ads kam hain (ready + loading < target) utne load
  /// shuru kar deta hai, taaki hamesha 2-3 ads taiyaar rahein.
  void _preloadInterstitials() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Interstitial ads disabled");
      return;
    }
    // Offline me request bhejna bekaar hai — net wapas aane par
    // [_retryWhenBackOnline] pool khud bhar dega.
    if (!isOnline) {
      print("📵 Offline - interstitial preload skipped");
      return;
    }
    while (_interstitialPool.length + _interstitialLoadsInFlight <
        _interstitialPoolTarget) {
      _loadOneInterstitial();
    }
  }

  /// Ek single interstitial load karke pool me daalta hai.
  void _loadOneInterstitial() {
    _interstitialLoadsInFlight++;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoadsInFlight--;
          _interstitialPool.add(ad);
          isInterstitialReady.value = _interstitialPool.isNotEmpty;
          print("✅ Interstitial ready (pool: ${_interstitialPool.length}) "
              "via ${adSourceOf(ad)}");
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadsInFlight--;
          isInterstitialReady.value = _interstitialPool.isNotEmpty;
          print("❌ Interstitial failed: $error");
          // Thodi der baad pool dobara bharne ki koshish (offline me
          // _preloadInterstitials khud skip kar dega).
          Future.delayed(const Duration(seconds: 30), _preloadInterstitials);
        },
      ),
    );
  }

  /// Fire-and-forget show (compat): pool me ad ho to turant dikhao.
  void showInterstitialAd() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Skipping interstitial ad");
      return;
    }
    _showFromPool(() {});
  }

  /// Request aate hi: agar pool me ad ready hai to turant dikhao. Agar pool
  /// khali hai to ek loading overlay dikha kar [timeout] tak wait karo, ad
  /// aate hi dikhao. [onComplete] hamesha exactly ek baar chalta hai (ad
  /// dismiss hone par, ya ads off / timeout par turant) — caller bina atke
  /// aage badh sakta hai (e.g. navigate).
  Future<void> showInterstitialAdWithLoading({
    required VoidCallback onComplete,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    // Premium user / ads disabled → just continue.
    if (!shouldShowAds()) {
      onComplete();
      return;
    }

    // Pool me ad ready hai → turant show.
    if (_interstitialPool.isNotEmpty) {
      _showFromPool(onComplete);
      return;
    }

    // Offline → loader dikha kar wait karna bekaar hai, seedha aage badho.
    if (!isOnline) {
      onComplete();
      return;
    }

    // Pool khali → loader dikhao aur ek ad load hone ka wait karo.
    _showAdLoading();
    _preloadInterstitials();

    final stopwatch = Stopwatch()..start();
    while (_interstitialPool.isEmpty && stopwatch.elapsed < timeout) {
      await Future.delayed(const Duration(milliseconds: 150));
    }

    _hideAdLoading();

    if (_interstitialPool.isNotEmpty) {
      _showFromPool(onComplete);
    } else {
      // Time pe load nahi hui → user ko block mat karo.
      onComplete();
    }
  }

  /// Pool se ek ad nikaal kar dikhata hai, callbacks wire karta hai, aur
  /// dismiss hote hi pool dobara bhar deta hai.
  void _showFromPool(VoidCallback onComplete) {
    if (_interstitialPool.isEmpty) {
      _preloadInterstitials();
      onComplete();
      return;
    }

    final ad = _interstitialPool.removeAt(0);
    isInterstitialReady.value = _interstitialPool.isNotEmpty;

    var completed = false;
    void finish() {
      if (completed) return;
      completed = true;
      onComplete();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadInterstitials(); // pool wapas 2-3 tak bhar do
        finish();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _preloadInterstitials();
        finish();
      },
    );

    ad.show();
  }

  // Ad loading dialog ka state. `Get.isDialogOpen`/`Get.back()` GetX me
  // reliably kaam nahi karte (race + version issues), isliye dialog ka apna
  // context capture karke usi route ko directly pop karte hain.
  bool _adLoadingOpen = false;
  BuildContext? _adLoadingCtx;

  /// Full-screen blocking loader shown while an ad is being fetched.
  void _showAdLoading() {
    if (_adLoadingOpen) return;
    _adLoadingOpen = true;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Builder(
          builder: (ctx) {
            // Dialog ka apna context — isi se reliably pop karenge.
            _adLoadingCtx = ctx;
            return Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF13152B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2D4A)),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFBAE6FD)),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }

  void _hideAdLoading() {
    if (!_adLoadingOpen) return;
    _adLoadingOpen = false;
    _closeAdLoading();
  }

  /// Loading dialog ko reliably band karta hai. Pehle dialog ke apne context
  /// se pop (sabse pakka). Wo na mile to GetX fallback. Agar dialog abhi build
  /// hi nahi hua (race), to agle frame retry.
  void _closeAdLoading() {
    final ctx = _adLoadingCtx;
    if (ctx != null && ctx.mounted) {
      _adLoadingCtx = null;
      Navigator.of(ctx).pop();
      return;
    }
    if (Get.isDialogOpen ?? false) {
      Get.back();
      return;
    }
    // Dialog abhi tak tree me nahi aaya → agle frame phir try karo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _adLoadingCtx;
      if (c != null && c.mounted) {
        _adLoadingCtx = null;
        Navigator.of(c).pop();
      } else if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });
  }

  /// =====================
  /// REWARDED
  /// =====================
  void loadRewardedAd() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Rewarded ads disabled");
      return;
    }
    if (!isOnline) {
      print("📵 Offline - rewarded load skipped");
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
  /// Public entry (compat): pool ko target tak top-up karta hai.
  void loadRewardedInterstitialAd() => _preloadRewarded();

  /// Pool me jitne rewarded ads kam hain (ready + loading < target) utne load
  /// kar deta hai, taaki hamesha 2-3 ready rahein (unlock par loading dialog
  /// aaye hi na).
  void _preloadRewarded() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Rewarded interstitial ads disabled");
      return;
    }
    if (!isOnline) {
      print("📵 Offline - rewarded preload skipped");
      return;
    }
    while (_rewardedPool.length + _rewardedLoadsInFlight <
        _rewardedPoolTarget) {
      _loadOneRewarded();
    }
  }

  /// Ek single rewarded-interstitial load karke pool me daalta hai.
  void _loadOneRewarded() {
    _rewardedLoadsInFlight++;
    RewardedInterstitialAd.load(
      adUnitId: AdHelper.rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback:
      RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedLoadsInFlight--;
          _rewardedPool.add(ad);
          isRewardedInterstitialReady.value = _rewardedPool.isNotEmpty;
          print("✅ Rewarded ready (pool: ${_rewardedPool.length}) "
              "via ${adSourceOf(ad)}");
        },
        onAdFailedToLoad: (error) {
          _rewardedLoadsInFlight--;
          isRewardedInterstitialReady.value = _rewardedPool.isNotEmpty;
          print("❌ Rewarded failed: $error");
          // Thodi der baad pool dobara bharne ki koshish.
          Future.delayed(const Duration(seconds: 30), _preloadRewarded);
        },
      ),
    );
  }

  /// Compat: pool se ek rewarded dikhata hai (reward amount callback ke saath).
  void showRewardedInterstitialAd(Function(num amount) onReward) {
    if (!shouldShowAds()) {
      print("⭐ Premium user - Rewarded interstitial ad skipped");
      return;
    }
    _showRewardedFromPool(onReward: onReward);
  }

  /// =====================
  /// 🔓 PROMPT UNLOCK (rewarded)
  /// =====================
  /// Pool me rewarded ad ready hai to TURANT dikhao (koi loading dialog nahi).
  /// Pool khali ho to hi chhoti loading 2s dikha kar wait karo. Reward milne
  /// par [onReward] (= unlock). Ads off/premium ya time pe load na ho to bhi
  /// [onReward] (fail-open) taaki user kabhi permanently block na ho.
  Future<void> showRewardedForUnlock({required VoidCallback onReward}) async {
    // Ads off / premium → bina ad ke unlock.
    if (!shouldShowAds()) {
      onReward();
      return;
    }

    // Pool me ad ready → turant show, koi loading dialog nahi.
    if (_rewardedPool.isNotEmpty) {
      _showRewardedFromPool(onReward: (_) => onReward(), failOpen: onReward);
      return;
    }

    // Offline → wait mat karo, fail-open (unlock) taaki user block na ho.
    if (!isOnline) {
      onReward();
      return;
    }

    // Pool khali → chhoti loading dikhao aur sirf 2s wait karo.
    _showAdLoading();
    _preloadRewarded();
    final sw = Stopwatch()..start();
    while (_rewardedPool.isEmpty && sw.elapsed < const Duration(seconds: 2)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _hideAdLoading();

    if (_rewardedPool.isNotEmpty) {
      _showRewardedFromPool(onReward: (_) => onReward(), failOpen: onReward);
    } else {
      // Time pe load nahi hui → fail open (unlock).
      onReward();
    }
  }

  /// Pool se ek rewarded nikaal kar dikhata hai, callbacks wire karta hai, aur
  /// pool dobara bhar deta hai. [onReward] reward milne par chalta hai;
  /// [failOpen] tab chalta hai jab ad show hi na ho paaye (unlock na atke).
  void _showRewardedFromPool({
    required Function(num amount) onReward,
    VoidCallback? failOpen,
  }) {
    if (_rewardedPool.isEmpty) {
      _preloadRewarded();
      failOpen?.call();
      return;
    }

    final ad = _rewardedPool.removeAt(0);
    isRewardedInterstitialReady.value = _rewardedPool.isNotEmpty;

    var rewarded = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadRewarded(); // pool wapas 2-3 tak bhar do
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _preloadRewarded();
        if (!rewarded) failOpen?.call(); // show fail → fail open
      },
    );
    ad.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        onReward(reward.amount);
      },
    );
  }

  /// =====================
  /// APP OPEN (first launch + resume)
  /// =====================
  /// Resume par bhi App Open dikhana eCPM ka bada win he — par frequency
  /// caps ke saath, warna users irritate ho kar uninstall karte hain:
  /// - kam se kam [_appOpenMinBackground] background me raha ho
  /// - do shows ke beech [_appOpenCooldown] ka gap
  /// - 4 ghante purani cached ad expire (Google policy)
  static const Duration _appOpenMinBackground = Duration(seconds: 30);
  static const Duration _appOpenCooldown = Duration(minutes: 4);
  static const Duration _appOpenMaxAge = Duration(hours: 4);

  DateTime? _appOpenLoadTime;
  DateTime? _appOpenLastShownAt;
  DateTime? _pausedAt;
  bool _isShowingAppOpen = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _maybeShowAppOpenOnResume();
    }
  }

  void _maybeShowAppOpenOnResume() {
    // Ad khud full-screen dikh rahi thi to wapas aana "resume" nahi he.
    if (_isShowingAppOpen) return;
    if (!shouldShowAds()) return;

    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt == null ||
        DateTime.now().difference(pausedAt) < _appOpenMinBackground) {
      return;
    }
    final lastShown = _appOpenLastShownAt;
    if (lastShown != null &&
        DateTime.now().difference(lastShown) < _appOpenCooldown) {
      return;
    }

    // Purani cached ad expire kar do (4h limit), fresh load karo.
    final loadedAt = _appOpenLoadTime;
    if (_isAppOpenAdReady &&
        loadedAt != null &&
        DateTime.now().difference(loadedAt) > _appOpenMaxAge) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _isAppOpenAdReady = false;
    }

    if (_isAppOpenAdReady && _appOpenAd != null) {
      _showAppOpen();
    } else {
      // Abhi ready nahi — agli baar ke liye load kar do.
      loadAppOpenAd();
    }
  }

  void _showAppOpen() {
    final ad = _appOpenAd;
    if (ad == null) return;
    _isShowingAppOpen = true;
    _appOpenLastShownAt = DateTime.now();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _afterAppOpenClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _afterAppOpenClosed();
      },
    );
    ad.show();
  }

  void _afterAppOpenClosed() {
    _isShowingAppOpen = false;
    _appOpenAd = null;
    _isAppOpenAdReady = false;
    // Agla resume aane se pehle ad ready rakho.
    loadAppOpenAd();
  }

  void loadAppOpenAd() {
    if (!shouldShowAds()) {
      print("⭐ Premium user - App open ads disabled");
      return;
    }
    if (!isOnline) {
      print("📵 Offline - app open load skipped");
      return;
    }

    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdReady = true;
          _appOpenLoadTime = DateTime.now();
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
      _showAppOpen();
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
    WidgetsBinding.instance.removeObserver(this);
    for (final ad in _interstitialPool) {
      ad.dispose();
    }
    _interstitialPool.clear();
    for (final ad in _rewardedPool) {
      ad.dispose();
    }
    _rewardedPool.clear();
    rewardedAd?.dispose();
    _appOpenAd?.dispose();
    super.onClose();
  }
}

/// =====================
/// MREC AD BOX (self-contained 300x250)
/// =====================
/// Drop-in MREC/banner box jo apna [BannerAd] khud iske widget lifetime ke
/// liye own karta hai — initState me banata hai, dispose me hata deta hai.
/// Isse hamesha EXACTLY ek hi [AdWidget] ek ad ko wrap karta hai.
///
/// Ye "This AdWidget is already in the Widget tree" crash ka fix hai: wo crash
/// tab aata hai jab ek shared BannerAd (e.g. controller me rakha) ko aisa
/// AdWidget wrap karta hai jo refresh/navigation/reload par rebuild ho jaata
/// hai. Ad ka lifecycle is widget se baandh kar, ek hi live AdWidget rehta hai.
class MrecAdBox extends StatefulWidget {
  /// Load karne wali REAL ad unit id (config se). Khali ho to kuch nahi
  /// dikhta (koi test ad nahi).
  final String adUnitId;

  /// Ad ke around margin (home & detail placements alag rakh sakein).
  final EdgeInsetsGeometry margin;

  const MrecAdBox({
    Key? key,
    required this.adUnitId,
    this.margin = const EdgeInsets.symmetric(vertical: 16),
  }) : super(key: key);

  @override
  State<MrecAdBox> createState() => _MrecAdBoxState();
}

class _MrecAdBoxState extends State<MrecAdBox> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _loading = false;
  bool _disposed = false;
  StreamSubscription<bool>? _connSub;

  @override
  void initState() {
    super.initState();
    _loadAd();
    // Offline me load fail ho jaati hai aur widget hamesha khaali reh jata
    // tha — net wapas aate hi dobara try karo.
    if (Get.isRegistered<ConnectivityService>()) {
      _connSub =
          Get.find<ConnectivityService>().isConnected.listen((connected) {
        if (connected && !_loaded && !_loading && !_disposed) _loadAd();
      });
    }
  }

  void _loadAd() {
    // Sirf real config ad unit id use karo. Khali ho to kuch load mat karo
    // (koi test ad nahi) — widget bas khaali (SizedBox) rahega.
    final unitId = widget.adUnitId.trim();
    if (unitId.isEmpty) return;

    _loading = true;
    BannerAd(
      adUnitId: unitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _loading = false;
          // Agar widget load hone se pehle hat gaya, to ad ko dead State se
          // attach karne ke bajaye discard kar do.
          if (_disposed) {
            ad.dispose();
            return;
          }
          debugPrint("✅ MREC loaded via ${AdController.adSourceOf(ad)}");
          setState(() {
            _ad = ad as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          _loading = false;
          debugPrint("❌ MREC Ad failed to load: ${error.message}");
          ad.dispose();
          if (!_disposed && mounted) {
            setState(() {
              _ad = null;
              _loaded = false;
            });
          }
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _disposed = true;
    _connSub?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      child: SizedBox(
        width: 300,
        height: 250,
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}

/// =====================
/// NATIVE AD BOX (self-contained, medium template)
/// =====================
/// MREC se zyada eCPM deta he kyunki content jaisa blend hota he. [MrecAdBox]
/// jaisa hi self-contained he — apna [NativeAd] khud own/dispose karta he,
/// fail hone par net wapas aane par retry karta he, aur load na ho to khaali
/// (zero-height) rehta he.
class NativeAdBox extends StatefulWidget {
  /// Load karne wali REAL native ad unit id (config se). Khali ho to kuch
  /// nahi dikhta.
  final String adUnitId;

  final EdgeInsetsGeometry margin;

  const NativeAdBox({
    super.key,
    required this.adUnitId,
    this.margin = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  State<NativeAdBox> createState() => _NativeAdBoxState();
}

class _NativeAdBoxState extends State<NativeAdBox> {
  NativeAd? _ad;
  bool _loaded = false;
  bool _loading = false;
  bool _disposed = false;
  StreamSubscription<bool>? _connSub;

  // App ke dark theme se matching template colors.
  static const Color _bg = Color(0xFF13152B);
  static const Color _accent = Color(0xFF38BDF8);

  @override
  void initState() {
    super.initState();
    _loadAd();
    if (Get.isRegistered<ConnectivityService>()) {
      _connSub =
          Get.find<ConnectivityService>().isConnected.listen((connected) {
        if (connected && !_loaded && !_loading && !_disposed) _loadAd();
      });
    }
  }

  void _loadAd() {
    final unitId = widget.adUnitId.trim();
    if (unitId.isEmpty) return;

    _loading = true;
    NativeAd(
      adUnitId: unitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: _bg,
        cornerRadius: 14,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: _accent,
          size: 15,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          size: 15,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white70,
          size: 13,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white54,
          size: 12,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          _loading = false;
          if (_disposed) {
            ad.dispose();
            return;
          }
          debugPrint("✅ Native loaded via ${AdController.adSourceOf(ad)}");
          setState(() {
            _ad = ad as NativeAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          _loading = false;
          debugPrint("❌ Native Ad failed to load: ${error.message}");
          ad.dispose();
          if (!_disposed && mounted) {
            setState(() {
              _ad = null;
              _loaded = false;
            });
          }
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _disposed = true;
    _connSub?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      // Medium template ki recommended height 320 he.
      child: SizedBox(
        height: 320,
        width: double.infinity,
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}