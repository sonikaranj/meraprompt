import 'dart:io';
import 'dart:math' as math;
import 'package:promptseen/Admob/app_config.dart';
import 'package:promptseen/Admob/config_loader.dart';
import 'package:promptseen/comman/Preview/OnboardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:get/get.dart';
import 'package:promptseen/comman/serviceapp/FirstLaunchService.dart';

import 'package:purchases_flutter/purchases_flutter.dart';

class TranscriptionAISplash extends StatefulWidget {
  const TranscriptionAISplash({super.key});

  @override
  State<TranscriptionAISplash> createState() => _TranscriptionAISplashState();
}

class _TranscriptionAISplashState extends State<TranscriptionAISplash>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _waveController;
  late final AnimationController _particleController;
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;
  late final AnimationController _progressController;

  late final Animation<double> _fade;
  late final Animation<double> _wave;
  late final Animation<double> _particle;
  late final Animation<double> _pulse;
  late final Animation<double> _rotation;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Audio wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _wave = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Particle floating animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _particle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _rotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      _rotationController,
    );

    // Progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    // iOS ATT after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initATT();
    });

    // Config + ads + routing
    _loadConfigAndNavigate();
    checkPrimium();
  }

  Future<void> _initATT() async {
    if (!Platform.isIOS) return;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('Current ATT Status: $status');

      if (status == TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(milliseconds: 500));
        final result = await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('ATT authorization result: $result');
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
        _initializePersonalizedAds();
        break;
      case TrackingStatus.denied:
        debugPrint('❌ Tracking denied - use non-personalized ads');
        _initializeNonPersonalizedAds();
        break;
      case TrackingStatus.restricted:
        debugPrint('🔒 Tracking restricted - check parental controls');
        _initializeNonPersonalizedAds();
        break;
      case TrackingStatus.notDetermined:
        debugPrint('❓ Status still not determined');
        _initializeNonPersonalizedAds();
        break;
      case TrackingStatus.notSupported:
        debugPrint('📱 Tracking not supported on this device/OS version');
        _initializeNonPersonalizedAds();
        break;
    }
  }

  void _initializePersonalizedAds() {
    debugPrint('Initializing personalized ads...');
  }

  void _initializeNonPersonalizedAds() {
    debugPrint('Initializing non-personalized ads...');
  }

  Future<void> _loadConfigAndNavigate() async {
    try {
      await Future.wait([
        ConfigLoader.load(),
        Future.delayed(const Duration(seconds: 3)),
      ]);

      if (!mounted) return;

      final firstLaunch = await FirstLaunchService.isFirstLaunch();
      if (firstLaunch == true) {
        await FirstLaunchService.setFirstLaunchDone();
        Get.offAll(() => const ScholarOnboardingFlow());
      } else {
        Get.offAll(() => const ScholarOnboardingFlow());
      }
    } catch (e) {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      final firstLaunch = await FirstLaunchService.isFirstLaunch();
      if (firstLaunch == true) {
        await FirstLaunchService.setFirstLaunchDone();
        Get.offAll(() => const ScholarOnboardingFlow());
      } else {
        // Get.offAll(() => const MainAppScreen());
        Get.offAll(() => const ScholarOnboardingFlow());
      }
    }
  }

  Future<void> checkPrimium() async {
    var IsPrimiumUser = await FirstLaunchService.isUserPremium();
    print(IsPrimiumUser);
    AppConfig.IsPrimiumUser = IsPrimiumUser;
    if (IsPrimiumUser == false) {
      final info = await Purchases.getCustomerInfo();
      print(info);
      print(info.activeSubscriptions);
      if (info.activeSubscriptions.length == 1) {
        await FirstLaunchService.setUserPremium(true);
        setState(() {
          AppConfig.IsPrimiumUser = true;
        });
      } else {
        await FirstLaunchService.setUserPremium(false);
        setState(() {
          AppConfig.IsPrimiumUser = false;
        });
      }
    }
    setState(() {
      AppConfig.IsPrimiumUser = IsPrimiumUser;
    });
    print(IsPrimiumUser);
    print("karan");
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _waveController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0B2E),
              Color(0xFF0A0A0C),
              Color(0xFF000000),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fade,
          child: Stack(
            children: [
              // Animated background orbs
              AnimatedBuilder(
                animation: _particle,
                builder: (context, child) {
                  return Positioned(
                    top: -100 + (_particle.value * 50),
                    right: -80,
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF6C0DF2).withOpacity(0.2),
                            const Color(0xFF6C0DF2).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              AnimatedBuilder(
                animation: _particle,
                builder: (context, child) {
                  return Positioned(
                    bottom: -120 + (_particle.value * -40),
                    left: -100,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF2DD4BF).withOpacity(0.15),
                            const Color(0xFF2DD4BF).withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Grid overlay
              Positioned.fill(
                child: CustomPaint(
                  painter: _TranscriptionGridPainter(
                    const Color(0xFF6C0DF2).withOpacity(0.08),
                  ),
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // AI Badge
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulse.value * 0.9,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6C0DF2).withOpacity(0.3),
                                  const Color(0xFF2DD4BF).withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xFF6C0DF2).withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6C0DF2).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2DD4BF),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2DD4BF),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'AI POWERED',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Main Microphone Icon with Audio Waves
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer rotating ring
                        AnimatedBuilder(
                          animation: _rotation,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotation.value,
                              child: Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.transparent,
                                  ),
                                  gradient: SweepGradient(
                                    colors: [
                                      const Color(0xFF6C0DF2).withOpacity(0.8),
                                      const Color(0xFF2DD4BF).withOpacity(0.8),
                                      const Color(0xFF8B3EFF).withOpacity(0.8),
                                      const Color(0xFF6C0DF2).withOpacity(0.8),
                                    ],
                                    stops: const [0.0, 0.33, 0.66, 1.0],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Pulsing glow circles
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulse.value,
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF6C0DF2).withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Audio wave bars
                        AnimatedBuilder(
                          animation: _wave,
                          builder: (context, child) {
                            return SizedBox(
                              width: 200,
                              height: 200,
                              child: CustomPaint(
                                painter: _AudioWavePainter(
                                  _wave.value,
                                  const Color(0xFF6C0DF2),
                                  const Color(0xFF2DD4BF),
                                ),
                              ),
                            );
                          },
                        ),

                        // Center microphone icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF6C0DF2),
                                Color(0xFF8B3EFF),
                                Color(0xFF2DD4BF),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C0DF2).withOpacity(0.6),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: const Color(0xFF2DD4BF).withOpacity(0.4),
                                blurRadius: 60,
                                spreadRadius: 15,
                              ),
                            ],
                          ),
                          child: Image.asset('asset/logo.png')
                        ),

                        // Floating feature indicators
                        _buildFloatingIndicator(
                          _particle,
                          Icons.video_library_rounded,
                          'Video',
                          const Color(0xFF6C0DF2),
                          left: -120,
                          top: -20,
                        ),

                        _buildFloatingIndicator(
                          _particle,
                          Icons.picture_as_pdf_rounded,
                          'PDF',
                          const Color(0xFF2DD4BF),
                          right: -120,
                          top: 20,
                          delay: 0.33,
                        ),

                        _buildFloatingIndicator(
                          _particle,
                          Icons.image_rounded,
                          'Image',
                          const Color(0xFF8B3EFF),
                          left: -100,
                          bottom: -40,
                          delay: 0.66,
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // App title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFF6C0DF2),
                          Color(0xFF2DD4BF),
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        'TranscriptAI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Video to Insight • AI Powered Transcription',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Loading progress bar
                    Container(
                      width: size.width * 0.65,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF6C0DF2).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: AnimatedBuilder(
                        animation: _progress,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progress.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6C0DF2),
                                    Color(0xFF8B3EFF),
                                    Color(0xFF2DD4BF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6C0DF2).withOpacity(0.6),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Loading text
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (context, child) {
                        final texts = [
                          'Initializing AI...',
                          'Loading Models...',
                          'Almost Ready...',
                          'Ready!',
                        ];
                        final index = (_progress.value * (texts.length - 1)).floor();
                        return Text(
                          texts[index.clamp(0, texts.length - 1)],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 0.8,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),

              // Floating particles
              ..._buildFloatingParticles(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIndicator(
      Animation<double> animation,
      IconData icon,
      String label,
      Color color, {
        double? left,
        double? right,
        double? top,
        double? bottom,
        double delay = 0.0,
      }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final value = (animation.value + delay) % 1.0;
          return Transform.translate(
            offset: Offset(0, math.sin(value * 2 * math.pi) * 8),
            child: Transform.scale(
              scale: 1.0 + (math.sin(value * 2 * math.pi) * 0.08),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.4),
                      color.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: color.withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildFloatingParticles() {
    return List.generate(15, (index) {
      final random = math.Random(index);
      final left = random.nextDouble() * 400;
      final top = random.nextDouble() * 800;
      final size = 2.0 + random.nextDouble() * 4;
      final duration = 2000 + random.nextInt(2000);

      return Positioned(
        left: left,
        top: top,
        child: AnimatedBuilder(
          animation: _particle,
          builder: (context, child) {
            return Opacity(
              opacity: 0.3 + (_particle.value * 0.4),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6C0DF2).withOpacity(0.8),
                      const Color(0xFF2DD4BF).withOpacity(0.4),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C0DF2).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// Audio Wave Painter
class _AudioWavePainter extends CustomPainter {
  final double progress;
  final Color color1;
  final Color color2;

  _AudioWavePainter(this.progress, this.color1, this.color2);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw 8 audio wave bars
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (progress * math.pi / 8);
      final barHeight = 20 + (math.sin(progress * 2 * math.pi + i) * 15).abs();

      final startRadius = 60.0;
      final endRadius = startRadius + barHeight;

      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );

      final end = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius,
      );

      paint.shader = LinearGradient(
        colors: [color1, color2],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromPoints(start, end));

      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Grid Painter
class _TranscriptionGridPainter extends CustomPainter {
  final Color gridColor;

  _TranscriptionGridPainter(this.gridColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    const spacing = 40.0;

    // Vertical lines with fade
    for (double x = 0; x <= size.width; x += spacing) {
      final gradient = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            gridColor.withOpacity(0),
            gridColor,
            gridColor.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(x, 0, 1, size.height));
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gradient);
    }

    // Horizontal lines with fade
    for (double y = 0; y <= size.height; y += spacing) {
      final gradient = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            gridColor.withOpacity(0),
            gridColor,
            gridColor.withOpacity(0),
          ],
        ).createShader(Rect.fromLTWH(0, y, size.width, 1));
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gradient);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
