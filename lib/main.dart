import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:promptseen/Admob/app_config.dart';
import 'package:promptseen/routes.dart';
import 'package:promptseen/service/connectivity_service.dart';
import 'package:promptseen/service/notification_service.dart';
import 'package:promptseen/service/ad_service.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'const.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  AppConfig.loadThemeCache();

  // Initialize timezone for notifications
  tz.initializeTimeZones();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initNotifications();

  // Initialize Ad Service
  final adService = AdService();
  await adService.initialize();

  Get.put(ConnectivityService(), permanent: true);
  Get.put(notificationService, permanent: true);
  Get.put(adService, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _notificationService = Get.find<NotificationService>();

    // App start hone par check karo agar 1 hour baad open ho raha hai
    _notificationService.checkAndNotifyIfAppClosedFor1Hour();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App exit karte waqt time record karo
      _notificationService.recordAppExit();
    } else if (state == AppLifecycleState.resumed) {
      // App resume hone par check karo agar notification bhejni hai
      _notificationService.checkAndNotifyIfAppClosedFor1Hour();
    }
  }

  Future<void> _configureSDK() async {
    // Enable debug mode (disable for production)
    // await Purchases.setLogLevel(LogLevel.debug);
    //
    // PurchasesConfiguration configuration = PurchasesConfiguration("");
    //
    // // This is the critical missing line - you need to actually configure Purchases
    // await Purchases.configure(configuration);

    // print("RevenueCat SDK configured successfully");
    // print("Configuration: $configuration");
  }

  Future<void> _initATT() async {
    if (!Platform.isIOS) return; // ATT is iOS-only

    try {
      // Get current status first
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('Current ATT Status: $status');

      if (status == TrackingStatus.notDetermined) {
        // Optional: Show custom explainer dialog first
        // await _showCustomExplainerDialog();

        // Important: Wait for UI to be ready
        await Future.delayed(const Duration(milliseconds: 500));

        // Request authorization - this will show the system dialog
        final result = await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('ATT authorization result: $result');

        // Handle the result
        _handleATTResult(result);
      } else {
        debugPrint('ATT already determined: $status');
        _handleATTResult(status);
      }
    } catch (e) {
      debugPrint('Error in ATT initialization: $e');
    }
  }

  void _handleATTResult(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.authorized:
        debugPrint('✅ Tracking authorized - can use personalized ads');
        // Initialize ads with personalized targeting
        _initializePersonalizedAds();
        break;

      case TrackingStatus.denied:
        debugPrint('❌ Tracking denied - use non-personalized ads');
        // Initialize ads without personalization
        _initializeNonPersonalizedAds();
        break;

      case TrackingStatus.restricted:
        debugPrint('🔒 Tracking restricted - check parental controls');
        // Use non-personalized ads (same as denied)
        _initializeNonPersonalizedAds();
        break;

      case TrackingStatus.notDetermined:
        debugPrint('❓ Status still not determined');
        // Handle as needed - maybe show retry option
        _initializeNonPersonalizedAds(); // Safe fallback
        break;

      case TrackingStatus.notSupported:
        debugPrint('📱 Tracking not supported on this device/OS version');
        // Fallback to non-personalized ads (older iOS versions)
        _initializeNonPersonalizedAds();
        break;
    }
  }

  // Helper method for personalized ads
  void _initializePersonalizedAds() {
    debugPrint('Initializing personalized ads...');
    // Add your personalized ads initialization code here
    // Example:
    // AdMobService.instance.setPersonalizedAds(true);
    // AppLovinService.setPersonalizedAds(true);
  }

  // Helper method for non-personalized ads
  void _initializeNonPersonalizedAds() {
    debugPrint('Initializing non-personalized ads...');
    // Add your non-personalized ads initialization code here
    // Example:
    // AdMobService.instance.setPersonalizedAds(false);
    // AppLovinService.setPersonalizedAds(false);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Stack(
          children: [
            GetMaterialApp(
              title: 'MK EDIT – AI Photo Editing',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                fontFamily: 'Montserrat',
                brightness: Brightness.dark,
                scaffoldBackgroundColor: AppColor.primaryColor,
                primaryColor: AppColor.themColors,
                colorScheme: ColorScheme.dark(
                  primary: AppColor.themColors,
                  secondary: AppColor.accent,
                  surface: AppColor.secoundaryColor,
                ),
                useMaterial3: true,
              ),
              initialRoute: AppRoutes.splash,
              getPages: AppPages.pages,
              defaultTransition: Transition.fade,
              transitionDuration: const Duration(milliseconds: 300),
            ),
            const _NoInternetOverlay(),
          ],
        );
      },
    );
  }
}

class _NoInternetOverlay extends StatelessWidget {
  const _NoInternetOverlay();

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();
    return Obx(() {
      if (connectivityService.isConnected.value) {
        return const SizedBox.shrink();
      }
      return MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF080C18),
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0EA5E9), Color(0xFF00BCD4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'No Internet Connection',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Check your WiFi or mobile data connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[400],
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF00BCD4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0EA5E9).withValues(alpha: 0.45),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
