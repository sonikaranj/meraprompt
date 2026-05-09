import 'dart:math';
import 'package:promptseen/Admob/Admob_service.dart';
import 'package:promptseen/Admob/app_config.dart';
import 'package:promptseen/comman/purchase/PrivacyScreen.dart';
import 'package:promptseen/comman/purchase/TermsScreen.dart';
import 'package:promptseen/comman/serviceapp/RatingService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {

  final String appShareLink = "${AppConfig.appShareLink}";
  final String privacyPolicyUrl = "${AppConfig.privacyPolicyUrl}";
  final String supportEmail = "${AppConfig.supportEmail}";

  // PromptMera Brand Colors
  static const Color _bgDeep      = Color(0xFF0D0E1A);
  static const Color _bgCard      = Color(0xFF13152B);
  static const Color _bgCardLight = Color(0xFF1A1D35);
  static const Color _purple      = Color(0xFFAA6EE8);
  static const Color _teal        = Color(0xFF3EC6C6);
  static const Color _purpleLight = Color(0xFFCC99FF);
  static const Color _borderColor = Color(0xFF2A2D4A);

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _slideController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 900), vsync: this);
    _floatingController = AnimationController(duration: const Duration(seconds: 3), vsync: this)
      ..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack));
    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Widget _buildFloatingGlow(Size size, int index) {
    final random = Random(index);
    final startX = random.nextDouble() * size.width;
    final startY = random.nextDouble() * size.height;
    final color = index % 2 == 0 ? _purple : _teal;

    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        final offsetY = sin((index + _floatingAnimation.value * pi * 2)) * 30;
        final offsetX = cos((index + _floatingAnimation.value * pi * 2)) * 20;
        return Positioned(
          left: startX + offsetX,
          top: startY + offsetY,
          child: Container(
            width: 3 + random.nextDouble() * 5,
            height: 3 + random.nextDouble() * 5,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12 + random.nextDouble() * 0.18),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10, spreadRadius: 1)],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_bgCard, _bgCardLight],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _purple.withOpacity(0.22), width: 1.5),
                boxShadow: [
                  BoxShadow(color: _purple.withOpacity(0.18), blurRadius: 40, offset: const Offset(0, 14)),
                  BoxShadow(color: _teal.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_purple, _teal],
                      ),
                      boxShadow: [BoxShadow(color: _purple.withOpacity(0.45), blurRadius: 28, spreadRadius: 4)],
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 46),
                  ),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                        colors: [_purple, _teal]).createShader(bounds),
                    child: const Text('PromptMera',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,
                            color: Colors.white, letterSpacing: -0.5)),
                  ),
                  const SizedBox(height: 8),
                  Text('Smart AI Prompts for Unlimited Creativity',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[400], letterSpacing: 0.3)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _purple.withOpacity(0.28), width: 1),
                    ),
                    child: const Text('v1.0.0 • Build 2024',
                        style: TextStyle(fontSize: 12, color: _purpleLight,
                            fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? accentColor,
  }) {
    final accent = accentColor ?? _purple;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: accent.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_bgCard.withOpacity(0.9), _bgCardLight.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor.withOpacity(0.8), width: 1),
              boxShadow: [BoxShadow(color: accent.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: accent.withOpacity(0.22), width: 1),
                  ),
                  child: Icon(icon, color: accent, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.2)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500], letterSpacing: 0.2)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Row(
        children: [
          Container(
            width: 4, height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_purple, _teal],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 18,
              fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _bgDeep,
      body: Stack(
        children: [
          // Purple radial glow top-right
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.7, -0.8),
                radius: 1.4,
                colors: [_purple.withOpacity(0.12), _bgDeep],
                stops: const [0.0, 0.65],
              ),
            ),
          ),
          // Teal glow bottom-left
          Positioned(
            bottom: -80, left: -60,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                    colors: [_teal.withOpacity(0.08), Colors.transparent]),
              ),
            ),
          ),
          ...List.generate(12, (index) => _buildFloatingGlow(size, index)),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildSectionHeader('Account'),
                      _buildMenuTile(icon: Icons.privacy_tip_rounded, title: 'Privacy Policy',
                          subtitle: 'How we protect your data', accentColor: _purple,
                          onTap: () => Get.to(() => PrivacyScreen())),
                      _buildMenuTile(icon: Icons.description_rounded, title: 'Terms & Conditions',
                          subtitle: 'Legal agreements', accentColor: _purple,
                          onTap: () => Get.to(() => Termsscreen())),
                      _buildSectionHeader('Support & Feedback'),
                      _buildMenuTile(icon: Icons.share_rounded, title: 'Share App',
                          subtitle: 'Tell your friends', accentColor: _teal,
                          onTap: () => Share.share("Discover PromptMera! $appShareLink")),
                      _buildMenuTile(icon: Icons.star_rounded, title: 'Rate Us',
                          subtitle: 'Leave a review', accentColor: const Color(0xFFFFCB47),
                          onTap: () async => await RatingService.requestReview()),
                      _buildMenuTile(icon: Icons.mail_rounded, title: 'Contact Support',
                          subtitle: 'Get help & feedback', accentColor: const Color(0xFFFF6B9D),
                          onTap: _launchEmail),
                      _buildSectionHeader('About'),
                      Container(
                        margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_bgCard.withOpacity(0.8), _bgCardLight.withOpacity(0.6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _purple.withOpacity(0.2), width: 1),
                          boxShadow: [BoxShadow(color: _purple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 6))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44, height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(colors: [_purple, _teal]),
                                    boxShadow: [BoxShadow(color: _purple.withOpacity(0.4), blurRadius: 14, spreadRadius: 2)],
                                  ),
                                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => const LinearGradient(
                                            colors: [_purple, _teal]).createShader(bounds),
                                        child: const Text('PromptMera',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                      Text('v1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                                'PromptMera is your AI-powered creative companion, crafted to help you explore, generate, and master prompts for every AI tool. Powered by advanced generative models.',
                                style: TextStyle(fontSize: 13, color: Colors.grey[400], height: 1.6, letterSpacing: 0.2)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: supportEmail);
    if (await canLaunchUrl(emailLaunchUri)) await launchUrl(emailLaunchUri);
  }
}