import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:promptseen/controller/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0E1A),
        ),
        child: Stack(
          children: [
            // Background Glow - Radial gradient (purple/blue)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.5, 0.3),
                    radius: 1.5,
                    colors: [
                      const Color(0xFF7C3AED).withValues(alpha: 0.2),
                      const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      const Color(0xFF0A0E1A).withValues(alpha: 1.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Decorative glow blob - Center top
            Positioned(
              top: -200,
              left: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C3AED).withValues(alpha: 0.15),
                      const Color(0xFF0A0E1A).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Decorative glow blob - Center bottom
            Positioned(
              bottom: -200,
              right: -100,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF06B6D4).withValues(alpha: 0.1),
                      const Color(0xFF0A0E1A).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Main content - Centered splash screen
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 60.h),

                      // Logo/Image container
                      Container(
                        width: 200.w,
                        height: 200.h,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1a1a2e).withValues(alpha: 0.6),
                          border: Border.all(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                            width: 2.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'asset/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.smart_toy_outlined,
                                  size: 100.sp,
                                  color: const Color(0xFF7C3AED),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 60.h),

                      // Title
                      Text(
                        'PromptMera',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Subtitle
                      Text(
                        'Smart AI Prompts for Unlimited\nCreativity',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                          letterSpacing: 0.3,
                        ),
                      ),

                      SizedBox(height: 60.h),

                      // Loading/Status text with animation
                      Obx(() {
                        final dots = List.generate(
                          (controller.currentPage.value % 4),
                          (index) => '.',
                        ).join();
                        return Text(
                          'INITIALIZING NEURAL CORE$dots',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        );
                      }),

                      SizedBox(height: 80.h),

                      // Footer text
                      Text(
                        'POWERED BY ADVANCED GENERATIVE MODELS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
