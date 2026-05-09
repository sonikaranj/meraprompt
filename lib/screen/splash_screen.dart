import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Splash Screen Controller
class SplashController extends GetxController {
  final progress = 0.0.obs;
  final statusText = 'Initializing Neural Engine'.obs;
  final subStatusText = 'Optimizing Models'.obs;

  @override
  void onInit() {
    super.onInit();
    _animateProgress();
  }

  void _animateProgress() async {
    await Future.delayed(const Duration(milliseconds: 500));

    for (int i = 0; i <= 100; i += 2) {
      progress.value = i / 100;

      // Update status text based on progress
      if (i == 20) {
        statusText.value = 'Loading AI Models';
        subStatusText.value = 'Training Algorithms';
      } else if (i == 50) {
        statusText.value = 'Calibrating Neural Network';
        subStatusText.value = 'Fine-tuning Parameters';
      } else if (i == 75) {
        statusText.value = 'Finalizing Setup';
        subStatusText.value = 'Preparing Interface';
      }

      await Future.delayed(const Duration(milliseconds: 40));
    }

    // Navigate to home after splash completes
    await Future.delayed(const Duration(milliseconds: 500));
    Get.offNamed('/onboarding'); // Change '/home' to your home route
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
          color: Color(0xFF0a0604), // background-dark
        ),
        child: Stack(
          children: [
            // Background Decorative Elements
            // AI Mesh Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: CustomPaint(
                  painter: MeshPatternPainter(),
                ),
              ),
            ),

            // Glow Background 1 (Top-Left)
            Positioned(
              top: -80,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFec5b13).withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFec5b13).withOpacity(0.15),
                      blurRadius: 80,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),

            // Glow Background 2 (Center)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 160,
              left: MediaQuery.of(context).size.width / 2 - 160,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFec5b13).withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFec5b13).withOpacity(0.1),
                      blurRadius: 100,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Spacer
                  const SizedBox(height: 20),

                  // Center Content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo with Glow Effect
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background Glow
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFec5b13).withOpacity(0.3),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFec5b13).withOpacity(0.3),
                                    blurRadius: 80,
                                  ),
                                ],
                              ),
                            ),
                            // Logo Container
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFec5b13),
                                    const Color(0xFFec5b13).withOpacity(0.8),
                                    const Color(0xFFec5b13).withOpacity(0.4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFec5b13).withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                            // Sparkle Accent (Top-Right)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                Icons.bubble_chart,
                                color: const Color(0xFFec5b13).withOpacity(0.6),
                                size: 20,
                              ),
                            ),
                            // Blur Accent (Bottom-Left)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              child: Icon(
                                Icons.blur_on,
                                color: const Color(0xFFec5b13).withOpacity(0.4),
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // App Name - PromptSeen
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Prompt',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              TextSpan(
                                text: 'Seen',
                                style: const TextStyle(
                                  color: Color(0xFFec5b13),
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'Discover Powerful AI Photo Prompts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom: Loading State
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        // Status Text and Progress Percentage
                        Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.statusText.value,
                                      style: const TextStyle(
                                        color: Color(0xFFe2e8f0),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.subStatusText.value,
                                      style: TextStyle(
                                        color: const Color(0xFFec5b13).withOpacity(0.6),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${(controller.progress.value * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Color(0xFFec5b13),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Progress Bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  // Background bar
                                  Container(
                                    width: double.infinity,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1e293b),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  // Progress fill with glow
                                  Container(
                                    width: Get.width * controller.progress.value,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          const Color(0xFFec5b13),
                                          const Color(0xFFec5b13).withOpacity(0.6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFec5b13).withOpacity(0.4),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                        const SizedBox(height: 16),

                        // Premium AI Access Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFec5b13).withOpacity(0.1),
                            border: Border.all(
                              color: const Color(0xFFec5b13).withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.security,
                                color: Color(0xFFec5b13),
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Premium AI Access',
                                style: TextStyle(
                                  color: const Color(0xFFec5b13).withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                  fontFamily: 'Inter',
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
          ],
        ),
      ),
    );
  }
}

// Custom Mesh Pattern Painter
class MeshPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFec5b13).withOpacity(0.05)
      ..strokeWidth = 1;

    const cellSize = 24.0;
    const radius = 1.0;

    for (double x = 0; x < size.width; x += cellSize) {
      for (double y = 0; y < size.height; y += cellSize) {
        canvas.drawCircle(
          Offset(x + 2, y + 2),
          radius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(MeshPatternPainter oldDelegate) => false;
}