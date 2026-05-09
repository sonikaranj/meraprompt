import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promptseen/Admob/Admob_service.dart';


/// USE THIS WIDGET AS YOUR SCREEN (e.g. MaterialApp(home: ScholarOnboardingFlow()))
class ScholarOnboardingFlow extends StatefulWidget {
  const ScholarOnboardingFlow({super.key});

  @override
  State<ScholarOnboardingFlow> createState() => _ScholarOnboardingFlowState();
}

class _ScholarOnboardingFlowState extends State<ScholarOnboardingFlow> {
  static const int _totalSteps = 3;

  final PageController _controller = PageController(initialPage: 0);
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (index < 0 || index >= _totalSteps) return;

    setState(() => _current = index);
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    final AdController controller = Get.find();
    controller.showInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0C),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: PageView.builder(
              controller: _controller,
              itemCount: _totalSteps,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (context, index) {
                return _OnboardingShell(
                  current: index,
                  total: _totalSteps,
                  onTapStep: _goTo,
                  onNext: () {
                    _goTo(index + 1);
                    print("karan $index");
                    if (index == 2) {
                      // Get.to(() => promptseenPremium(home: true,));
                    }
                  },
                  onBack: () => _goTo(index - 1),
                  child: _buildStep(index),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int index) {
    switch (index) {
      case 0:
        return const _Step1Content(); // PDF Upload & Chat
      case 1:
        return const _Step2Content(); // Image Upload & AI Learning
      case 2:
        return const _Step3Content(); // Smart AI Assistant
      default:
        return const SizedBox.shrink();
    }
  }
}

/// BACKGROUND + TOP PILL + BOTTOM DOTS/BUTTONS
class _OnboardingShell extends StatelessWidget {
  const _OnboardingShell({
    required this.child,
    required this.current,
    required this.total,
    required this.onTapStep,
    required this.onNext,
    required this.onBack,
  });

  final Widget child;
  final int current;
  final int total;
  final ValueChanged<int> onTapStep;
  final VoidCallback onNext;
  final VoidCallback onBack;

  static const _primary = Color(0xFF6C0DF2);
  static const _bgTop = Color(0xFF120821);
  static const _bgMid = Color(0xFF0A0A0C);
  static const _bgBottom = Color(0xFF0A0A0C);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgTop, _bgMid, _bgBottom],
              ),
            ),
          ),
          const Positioned.fill(child: _NoiseOverlay(opacity: 0.05)),
          Positioned.fill(child: CustomPaint(painter: _VignettePainter())),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 5),
                Expanded(child: child),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  child: Column(
                    children: [
                      _StepDots(current: current, total: total),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          if (current > 0) const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    gradient: const LinearGradient(
                                      colors: [_primary, Color(0xFF8B3EFF)],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primary.withOpacity(0.30),
                                        blurRadius: 30,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    onPressed: onNext,
                                    child: Text(
                                      current == total - 1 ? 'Finish' : 'Next',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ))

                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () {
                          // Get.to(() => MainAppScreen());
                        },
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF71717A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// STEP 1 CONTENT - PDF Document Chat with AI
class _Step1Content extends StatelessWidget {
  const _Step1Content();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _PDFHeroOrb(),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Text(
                'Chat with PDF Documents',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Upload your PDF and get instant AI-powered insights and answers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFA1A1AA),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: const [
              Expanded(
                child: _FeatureGlassCard(
                  icon: Icons.picture_as_pdf,
                  label: 'PDF Upload',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _FeatureGlassCard(
                  icon: Icons.chat_bubble_outline,
                  label: 'AI Chat',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _FeatureGlassCard(
                  icon: Icons.lightbulb_outline,
                  label: 'Insights',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _PDFComparisonStrip(),
        ),
        const Spacer(),
      ],
    );
  }
}

/// STEP 2 CONTENT - Image Upload & AI Learning
class _Step2Content extends StatelessWidget {
  const _Step2Content();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const _Step2Background(),
        Column(
          children: [
            const Expanded(
              flex: 50,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: _ImageAIIllustration(),
                ),
              ),
            ),
            Expanded(
              flex: 70,
              child: _BottomSheetArea(),
            ),
          ],
        ),
      ],
    );
  }
}

/// STEP 3 CONTENT - Smart AI Assistant
class _Step3Content extends StatelessWidget {
  const _Step3Content();

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6C0DF2);
    const teal = Color(0xFF2DD4BF);

    return Column(
      children: [
        Expanded(
          flex: 45,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.20),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                      top: 44,
                      left: 24,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: teal.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 256,
                        height: 256,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    primary.withOpacity(0.3),
                                    teal.withOpacity(0.2),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 120,
                                color: Colors.white70,
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Color(0xCC0A0A0A),
                                    Color(0x00000000),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -12,
                      right: -6,
                      child: _Step3FloatIcon(
                        bg: primary.withOpacity(0.30),
                        border: primary.withOpacity(0.40),
                        icon: Icons.image,
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      left: -12,
                      child: _Step3FloatIcon(
                        bg: teal.withOpacity(0.30),
                        border: teal.withOpacity(0.40),
                        icon: Icons.picture_as_pdf,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Text(
                'Learn with AI Assistant',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your personal AI tutor for documents and images.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: _Step3BenefitsCard(),
        ),
        const Spacer(),
      ],
    );
  }
}

class _Step3BenefitsCard extends StatelessWidget {
  const _Step3BenefitsCard();

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6C0DF2);
    const teal = Color(0xFF2DD4BF);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0x66241834),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primary.withOpacity(0.20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.80),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: primary.withOpacity(0.25),
                blurRadius: 40,
              ),
            ],
          ),
          child: Column(
            children: const [
              _Step3BenefitRow(
                icon: Icons.picture_as_pdf,
                iconColor: primary,
                iconBg: Color(0x336C0DF2),
                iconBorder: Color(0x4D6C0DF2),
                title: 'PDF Intelligence',
                subtitle: 'Chat with your documents and extract key information instantly.',
              ),
              SizedBox(height: 18),
              _Step3BenefitRow(
                icon: Icons.image,
                iconColor: teal,
                iconBg: Color(0x332DD4BF),
                iconBorder: Color(0x4D2DD4BF),
                title: 'Image Analysis',
                subtitle: 'Upload images and learn from AI-powered visual insights.',
              ),
              SizedBox(height: 18),
              _Step3BenefitRow(
                icon: Icons.psychology,
                iconColor: primary,
                iconBg: Color(0x336C0DF2),
                iconBorder: Color(0x4D6C0DF2),
                title: 'Smart Learning',
                subtitle: 'AI understands context and provides personalized explanations.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step3BenefitRow extends StatelessWidget {
  const _Step3BenefitRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.iconBorder,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color iconBorder;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
            border: Border.all(color: iconBorder),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Step3FloatIcon extends StatelessWidget {
  const _Step3FloatIcon({
    required this.bg,
    required this.border,
    required this.icon,
  });

  final Color bg;
  final Color border;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

// Step 2 Background
class _Step2Background extends StatelessWidget {
  const _Step2Background();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, 0.0),
            radius: 1.2,
            colors: [
              Color(0xFF1A1A3A),
              Color(0xFF0A0A1A),
            ],
          ),
        ),
        child: Stack(
          children: const [
            Positioned.fill(child: _GridOverlay()),
            Positioned(
              top: 160,
              left: 60,
              child: _GlowBlob(
                size: 260,
                color: Color(0xFF6C0DF2),
                opacity: 0.20,
                blur: 100,
              ),
            ),
            Positioned(
              bottom: 160,
              right: 60,
              child: _GlowBlob(
                size: 260,
                color: Color(0xFF2DD4BF),
                opacity: 0.10,
                blur: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridOverlay extends StatelessWidget {
  const _GridOverlay();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.40,
      child: CustomPaint(
        painter: _RadialGridPainter(
          dotColor: const Color(0xFF6C0DF2).withOpacity(0.15),
          spacing: 30,
          radius: 1.0,
        ),
      ),
    );
  }
}

class _RadialGridPainter extends CustomPainter {
  _RadialGridPainter({
    required this.dotColor,
    required this.spacing,
    required this.radius,
  });

  final Color dotColor;
  final double spacing;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    for (double y = 0; y <= size.height; y += spacing) {
      for (double x = 0; x <= size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.color,
    required this.opacity,
    required this.blur,
  });

  final double size;
  final Color color;
  final double opacity;
  final double blur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

// Image AI Illustration
class _ImageAIIllustration extends StatelessWidget {
  const _ImageAIIllustration();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 50,
            left: 16,
            child: Transform.rotate(
              angle: -0.21,
              child: _GlassPanel(
                width: 190,
                height: 220,
                borderRadius: 16,
                child: const Icon(Icons.image, size: 80, color: Color(0x332DD4BF)),
              ),
            ),
          ),
          Positioned(
            top: 55,
            left: 40,
            child: Transform.rotate(
              angle: -0.10,
              child: _GlassPanel(
                width: 190,
                height: 220,
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FakeLine(widthFactor: 0.55, opacity: 0.20, height: 8),
                    const SizedBox(height: 10),
                    _FakeLine(widthFactor: 0.80, opacity: 0.10, height: 8),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 45,
            left: 64,
            child: Transform.rotate(
              angle: 0.03,
              child: _AccentPanel(
                width: 190,
                height: 230,
                borderRadius: 16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _TealBar(),
                    SizedBox(height: 10),
                    _AccentLines(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: -6,
            child: _NeonNode(
              size: 48,
              glowColor: const Color(0xFF2DD4BF),
              icon: Icons.chat,
              iconSize: 18,
            ),
          ),
          Positioned(
            top: 100,
            right: -60,
            child: _NeonNode(
              size: 64,
              glowColor: const Color(0xFF6C0DF2),
              icon: Icons.psychology,
              iconSize: 26,
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _ConnectorPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(size.width * 0.90, size.height * 0.25);
    final c = Offset(size.width * 0.75, size.height * 0.40);
    final p2 = Offset(size.width * 0.80, size.height * 0.60);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..quadraticBezierTo(c.dx, c.dy, p2.dx, p2.dy);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = const LinearGradient(
        colors: [Color(0xFF2DD4BF), Color(0xFF6C0DF2)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..color = Colors.white.withOpacity(0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomSheetArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF0A0A1A),
            Color(0xF20A0A1A),
            Color(0x00000000),
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                const Text(
                  'Learn from Images',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Upload images and chat with AI to understand visual content.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFA1A1AA),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _GlassPanel(
            borderRadius: 20,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _ChecklistRow(
                  icon: Icons.image,
                  iconBg: Color(0x1A2DD4BF),
                  iconColor: Color(0xFF2DD4BF),
                  title: 'Image Recognition',
                  subtitle: 'AI understands your images',
                ),
                SizedBox(height: 14),
                _ChecklistRow(
                  icon: Icons.chat_bubble,
                  iconBg: Color(0x1A6C0DF2),
                  iconColor: Color(0xFF6C0DF2),
                  title: 'Interactive Chat',
                  subtitle: 'Ask questions about images',
                ),
                SizedBox(height: 14),
                _ChecklistRow(
                  icon: Icons.lightbulb,
                  iconBg: Color(0x1A9B59FF),
                  iconColor: Color(0xFFB48BFF),
                  title: 'Instant Insights',
                  subtitle: 'Get detailed explanations',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    this.width,
    this.height,
    required this.child,
    this.padding = const EdgeInsets.all(0),
    this.borderRadius = 16,
  });

  final double? width;
  final double? height;
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AccentPanel extends StatelessWidget {
  const _AccentPanel({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.child,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6C0DF2).withOpacity(0.20),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: const Color(0xFF6C0DF2).withOpacity(0.40)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NeonNode extends StatelessWidget {
  const _NeonNode({
    required this.size,
    required this.glowColor,
    required this.icon,
    required this.iconSize,
  });

  final double size;
  final Color glowColor;
  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        shape: BoxShape.circle,
        border: Border.all(color: glowColor.withOpacity(0.50)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.30),
            blurRadius: 20,
            spreadRadius: 0,
          )
        ],
      ),
      child: Center(
        child: Icon(icon, color: glowColor, size: iconSize),
      ),
    );
  }
}

class _FakeLine extends StatelessWidget {
  const _FakeLine({
    required this.widthFactor,
    required this.opacity,
    required this.height,
  });

  final double widthFactor;
  final double opacity;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(opacity),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _TealBar extends StatelessWidget {
  const _TealBar();

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.55,
      child: Container(
        height: 14,
        decoration: BoxDecoration(
          color: const Color(0xFF2DD4BF).withOpacity(0.60),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _AccentLines extends StatelessWidget {
  const _AccentLines();

  @override
  Widget build(BuildContext context) {
    Widget line(double w) => FractionallySizedBox(
      widthFactor: w,
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.30),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line(1.0),
        const SizedBox(height: 7),
        line(1.0),
        const SizedBox(height: 7),
        line(0.65),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.40),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// PDF Hero Orb
class _PDFHeroOrb extends StatelessWidget {
  const _PDFHeroOrb();

  static const _primary = Color(0xFF6C0DF2);
  static const _accentCyan = Color(0xFF00F2FF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      height: 256,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _primary.withOpacity(0.15),
                  Colors.transparent,
                ],
                radius: 0.70,
              ),
            ),
          ),
          CustomPaint(
            size: const Size(256, 256),
            painter: _OrbitalRingsPainter(),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _primary.withOpacity(0.20),
              border: Border.all(color: _primary.withOpacity(0.40)),
              boxShadow: [
                BoxShadow(
                  color: _primary.withOpacity(0.40),
                  blurRadius: 50,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Icon(Icons.picture_as_pdf, size: 48, color: Colors.white),
          ),
          const Positioned(
            top: 18,
            left: 40,
            child: _GlassCircleIcon(
              size: 40,
              icon: Icons.chat,
              iconSize: 20,
              iconColor: _accentCyan,
              shadowColor: _accentCyan,
            ),
          ),
          const Positioned(
            bottom: 34,
            right: 8,
            child: _GlassCircleIcon(
              size: 48,
              icon: Icons.auto_awesome,
              iconSize: 24,
              iconColor: _primary,
              shadowColor: _primary,
            ),
          ),
          Positioned(
            top: 74,
            right: 18,
            child: _GlassCircleIcon(
              size: 32,
              icon: Icons.image,
              iconSize: 18,
              iconColor: Colors.white.withOpacity(0.80),
              shadowColor: Colors.white,
              shadowOpacity: 0.10,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureGlassCard extends StatelessWidget {
  const _FeatureGlassCard({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  static const _primary = Color(0xFF6C0DF2);

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _primary, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: Color(0xFFD4D4D8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PDFComparisonStrip extends StatelessWidget {
  const _PDFComparisonStrip();

  static const _primary = Color(0xFF6C0DF2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRADITIONAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: const Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manual Reading',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFA1A1AA),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(width: 1, height: 32, color: Colors.white.withOpacity(0.10)),
          const Spacer(),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'AI POWERED',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Instant Chat',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.20),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(Icons.check, size: 16, color: Color(0xFF34D399)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.current, required this.total});

  final int current;
  final int total;

  static const _primary = Color(0xFF6C0DF2);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == current;
        return Container(
          margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
          width: active ? 24 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? _primary : const Color(0xFF3F3F46),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassCircleIcon extends StatelessWidget {
  const _GlassCircleIcon({
    required this.size,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    required this.shadowColor,
    this.shadowOpacity = 0.30,
  });

  final double size;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Color shadowColor;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(shadowOpacity),
                blurRadius: 15,
              ),
            ],
          ),
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}

class _OrbitalRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    void drawDashedCircle(
        double radius,
        double strokeWidth,
        List<double> pattern,
        double opacity,
        ) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = Colors.white.withOpacity(opacity);

      final path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
      final dashed = _dashPath(path, pattern);
      canvas.drawPath(dashed, paint);
    }

    drawDashedCircle(size.width * 0.35, 1, const [2, 4], 0.30);
    drawDashedCircle(size.width * 0.45, 1, const [1, 3], 0.30);
  }

  Path _dashPath(Path source, List<double> dashArray) {
    final metrics = source.computeMetrics().toList();
    final result = Path();
    for (final metric in metrics) {
      double distance = 0.0;
      int index = 0;
      while (distance < metric.length) {
        final len = dashArray[index % dashArray.length];
        final next = distance + len;
        if (index.isEven) {
          result.addPath(
            metric.extractPath(distance, next.clamp(0, metric.length)),
            Offset.zero,
          );
        }
        distance = next;
        index++;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final shader = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.transparent,
        const Color(0xCC0A0A0C),
      ],
      stops: const [0.40, 1.0],
    ).createShader(rect);

    canvas.drawRect(rect, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NoiseOverlay extends StatelessWidget {
  const _NoiseOverlay({required this.opacity});
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(painter: _NoisePainter()),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const step = 6.0;

    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        final v = ((x * 12.9898 + y * 78.233) % 1.0).abs();
        if (v > 0.85) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}