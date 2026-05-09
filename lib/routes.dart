import 'package:get/get.dart';
import 'package:promptseen/controller/detail_controller.dart';
import 'package:promptseen/controller/home_screen_controller.dart';
import 'package:promptseen/controller/onboarding_controller.dart';
import 'package:promptseen/screen/bottom_nav_screen.dart';
import 'package:promptseen/screen/deatail_screen.dart';
import 'package:promptseen/screen/home_screen.dart';
import 'package:promptseen/screen/onboarding_screen.dart';
import 'package:promptseen/screen/splash_screen.dart';

// Import your home screen here
// import 'screens/home_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String detail = '/detail';
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashController>(
              () => SplashController(),
          fenix: true,
        );
      }),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingController>(
              () => OnboardingController(),
          fenix: true,
        );
      }),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // Add your home screen route here
    GetPage(
      name: AppRoutes.home,     

               page: () =>  BottomNavScreen(),
      binding: BindingsBuilder(() {
      Get.lazyPut<HomeController>(
            () => HomeController(),
        fenix: true,
      );
    }),

      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.detail,

      page: () => const DetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DetailController>(
              () => DetailController(),
          fenix: true,
        );
      }),

      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}