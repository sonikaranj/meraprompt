import 'dart:io';
import 'package:promptseen/Admob/Admob_service.dart';
import 'package:promptseen/Admob/config_loader.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:promptseen/routes.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigLoader.load();
  await MobileAds.instance.initialize();
  Get.put(AdController());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final configuration = PurchasesConfiguration("");

  @override
  void initState() {
    super.initState();

    // Wait for widget to be fully initialized before calling ATT
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _initATT();
    // });
    // _configureSDK();
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
      designSize: const Size(390, 844), // Use your actual design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Prompt Mera – AI Photo Editing',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Montserrat',
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A091A),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.splash,
          getPages: AppPages.pages,
          defaultTransition: Transition.fade,
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
