import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;

// Splash Screen Controller
class SplashController extends GetxController {
  final progress = 0.0.obs;
  final statusText = 'INITIALIZING NEURAL CORE'.obs;

  @override
  void onInit() {
    super.onInit();
    _animateProgress();
  }

  void _animateProgress() async {
    await Future.delayed(const Duration(milliseconds: 500));

    for (int i = 0; i <= 100; i += 2) {
      progress.value = i / 100;

      await Future.delayed(const Duration(milliseconds: 40));
    }

    // Navigate to home after splash completes
    await Future.delayed(const Duration(milliseconds: 500));
    Get.offNamed('/onboarding');
  }
}

// Splash Screen UI
class SplashScreen extends GetView<SplashController> {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0D0F1A),
        ),
        child: Stack(
          children: [
            // Background Glow - Radial gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.5, 0.5),
                    radius: 1.2,
                    colors: [
                      const Color(0xFF6750A4).withValues(alpha: 0.15),
                      const Color(0xFF0D0F1A).withValues(alpha: 1.0),
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // Grid Pattern Background
            Positioned.fill(
              child: CustomPaint(
                painter: GridPatternPainter(),
              ),
            ),

            // Decorative AI Blob 1 - Top Left
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFCFBCFF).withValues(alpha: 0.10),
                      const Color(0xFF0D0F1A).withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

            // Decorative AI Blob 2 - Bottom Right
            Positioned(
              bottom: -150,
              right: -150,
              child: Container(
                width: 500,
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFE7C365).withValues(alpha: 0.05),
                      const Color(0xFF0D0F1A).withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 150, sigmaY: 150),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

            // Particles Effect
            Positioned.fill(
              child: CustomPaint(
                painter: ParticlesPainter(),
              ),
            ),

            // Center Content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo Section
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container with Glow
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFCFBCFF).withValues(alpha: 0.20),
                              const Color(0xFF0D0F1A).withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 1.0],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.network(
                              fit: BoxFit.contain,
                              'https://promptmera.com/logo.png',
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // App Name
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [
                              Color(0xFFCFBCFF), // primary
                              Color(0xFFCDC0E9), // secondary
                              Color(0xFFE7C365), // tertiary
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'PromptMera',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.0,
                            fontFamily: 'Outfit',
                            height: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Subtitle
                      const Text(
                        'Smart AI Prompts for Unlimited Creativity',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Progress Bar Container
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60),
                        child: Obx(() => Column(
                          children: [
                            // Progress Bar
                            Container(
                              width: double.infinity,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFF374151),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Stack(
                                children: [
                                  // Animated gradient fill with pulse effect
                                  Container(
                                    width: (MediaQuery.of(context).size.width - 120) *
                                        controller.progress.value,
                                    height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF8B5CF6).withValues(alpha: 0.0),
                                  const Color(0xFF8B5CF6),
                                  const Color(0xFF3B82F6),
                                  const Color(0xFF3B82F6).withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Status Text - Static
                            Text(
                              controller.statusText.value,
                              style: TextStyle(
                                color: const Color(0xFF9CA3AF).withValues(alpha: 0.4),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // Bottom Section - Powered By
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          color: const Color(0xFF6B7280).withValues(alpha: 0.8),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'POWERED BY ADVANCED GENERATIVE MODELS',
                          style: TextStyle(
                            color: const Color(0xFF6B7280).withValues(alpha: 0.7),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Grid Pattern Painter
class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF374151).withValues(alpha: 0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const cellSize = 100.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += cellSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += cellSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPatternPainter oldDelegate) => false;
}

// Particles Painter
class ParticlesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCFBCFF).withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    const particleSize = 40.0;

    // Draw particles as dots in a grid pattern
    for (double x = 0; x < size.width; x += particleSize) {
      for (double y = 0; y < size.height; y += particleSize) {
        canvas.drawCircle(
          Offset(x, y),
          1.0,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => false;
}

// Custom Brain Painter (Left Side) - REMOVED, using image instead
// Custom Arrow Painter (Right Side) - REMOVED, using image instead
