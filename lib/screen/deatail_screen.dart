import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promptseen/controller/detail_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends GetView<DetailController> {
  const DetailScreen({Key? key}) : super(key: key);

  static const Color _bgDeep      = Color(0xFF0D0E1A);
  static const Color _bgCard      = Color(0xFF13152B);
  static const Color _bgCardLight = Color(0xFF1A1D35);
  static const Color _purple      = Color(0xFFAA6EE8);
  static const Color _teal        = Color(0xFF3EC6C6);
  static const Color _purpleLight = Color(0xFFCC99FF);
  static const Color _borderColor = Color(0xFF2A2D4A);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: _bgDeep,
          body: Stack(
            children: [
              // Purple radial glow — top right
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.8, -0.9),
                    radius: 1.3,
                    colors: [_purple.withOpacity(0.10), _bgDeep],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
              // Teal glow — bottom left
              Positioned(
                bottom: -80, left: -60,
                child: Container(
                  width: 260, height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_teal.withOpacity(0.07), Colors.transparent],
                    ),
                  ),
                ),
              ),

              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: _bgDeep,
                    elevation: 0,
                    leading: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _bgCard,
                          border: Border.all(color: _borderColor, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                    title: ShaderMask(
                      shaderCallback: (bounds) =>
                          const LinearGradient(colors: [_purple, _teal]).createShader(bounds),
                      child: const Text(
                        'Prompt Details',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      GestureDetector(
                        onTap: () {
                          showMenu(
                            context: context,
                            color: _bgCardLight,
                            position: const RelativeRect.fromLTRB(100, 50, 0, 0),
                            items: [
                              PopupMenuItem(
                                onTap: () => controller.sharePrompt(),
                                child: Row(
                                  children: const [
                                    Icon(Icons.share, color: _teal),
                                    SizedBox(width: 12),
                                    Text('Share', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _bgCard,
                            border: Border.all(color: _borderColor, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildMainImage(controller),
                    ),
                  ),

                  // Prompt Card with typewriter
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _TypingPromptCard(
                        promptText: controller.prompt.promptText,
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildActionButtons(controller),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildGenerateButtons(controller),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainImage(DetailController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: _purple.withOpacity(0.20), blurRadius: 32, offset: const Offset(0, 12)),
          BoxShadow(color: _teal.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_purple.withOpacity(0.5), _teal.withOpacity(0.4)],
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.5),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: controller.prompt.imageUrl,
              fit: BoxFit.cover,
              height: 400,
              width: double.infinity,
              placeholder: (context, url) => Container(
                height: 400,
                color: _bgCard,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_purple),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 400,
                color: _bgCard,
                child: Icon(Icons.image_not_supported, color: Colors.grey[600], size: 50),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [_bgDeep.withOpacity(0.6), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16, left: 16,
              child: GestureDetector(
                onTap: () => controller.sharePrompt(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _bgCard.withOpacity(0.85),
                    border: Border.all(color: _teal.withOpacity(0.35), width: 1),
                  ),
                  child: const Icon(Icons.share, color: _teal, size: 16),
                ),
              ),
            ),
            Positioned(
              top: 16, right: 16,
              child: GestureDetector(
                onTap: () => controller.toggleFavorite(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _bgCard.withOpacity(0.85),
                    border: Border.all(color: _purple.withOpacity(0.35), width: 1),
                  ),
                  child: Icon(
                    controller.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: controller.isFavorite ? const Color(0xFFFF6B9D) : Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(DetailController controller) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.content_copy,
          label: 'Copy',
          onTap: () => controller.copyPrompt(),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgCard, _bgCardLight],
            ),
            border: Border.all(color: _purple.withOpacity(0.25), width: 1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: _purple.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.content_copy, color: _teal, size: 20),
              SizedBox(height: 6),
              Text(
                'Copy',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                    letterSpacing: 0.5, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButtons(DetailController controller) {
    final promptText = controller.prompt.promptText.trim();
    return Column(
      children: [
        _buildGenerateButtonTile(
          label: 'Generate with Gemini',
          icon: Icons.auto_awesome,
          gradientColors: const [Color(0xFF7B4FD4), Color(0xFF3EC6C6)],
          glowColor: _purple,
          onTap: () => _openAiWithPrompt(
            controller,
            promptText: promptText,
            baseUrl: 'https://gemini.google.com/app',
            queryParam: 'q',
          ),
        ),
        const SizedBox(height: 12),
        _buildGenerateButtonTile(
          label: 'Generate with ChatGPT',
          icon: Icons.smart_toy_outlined,
          gradientColors: const [Color(0xFF3EC6C6), Color(0xFF6A5ACD)],
          glowColor: _teal,
          onTap: () => _openAiWithPrompt(
            controller,
            promptText: promptText,
            baseUrl: 'https://chatgpt.com/',
            queryParam: 'q',
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButtonTile({
    required String label,
    required IconData icon,
    required List<Color> gradientColors,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Copies the prompt AND opens the AI app with the prompt pre-filled
  Future<void> _openAiWithPrompt(
      DetailController controller, {
        required String promptText,
        required String baseUrl,
        required String queryParam,
      }) async {
    if (promptText.isEmpty) {
      Get.snackbar('Prompt missing', 'No prompt text available.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Copy to clipboard first so user has it ready
    controller.copyPrompt();

    // Build URI with prompt as query parameter
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {queryParam: promptText},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback: open plain URL without query (some apps don't support deep-link params)
    final fallbackUri = Uri.parse(baseUrl);
    if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      Get.snackbar(
        'Prompt Copied!',
        'Paste it in the chat to get started.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _bgCardLight,
        colorText: Colors.white,
        icon: const Icon(Icons.content_paste, color: _teal),
        duration: const Duration(seconds: 4),
      );
      return;
    }

    Get.snackbar('Unable to open', 'Please try again later.',
        snackPosition: SnackPosition.BOTTOM);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typewriter Prompt Card — self-contained StatefulWidget
// ─────────────────────────────────────────────────────────────────────────────

class _TypingPromptCard extends StatefulWidget {
  final String promptText;
  const _TypingPromptCard({required this.promptText});

  @override
  State<_TypingPromptCard> createState() => _TypingPromptCardState();
}

class _TypingPromptCardState extends State<_TypingPromptCard>
    with SingleTickerProviderStateMixin {

  static const Color _bgCard      = Color(0xFF13152B);
  static const Color _bgCardLight = Color(0xFF1A1D35);
  static const Color _purple      = Color(0xFFAA6EE8);
  static const Color _teal        = Color(0xFF3EC6C6);
  static const Color _purpleLight = Color(0xFFCC99FF);

  String _displayed = '';
  int _charIndex = 0;
  Timer? _timer;
  bool _cursorVisible = true;
  Timer? _cursorTimer;
  late AnimationController _containerAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    // Container entrance animation
    _containerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _containerAnim, curve: Curves.easeOut)
    as Animation<double>;
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _containerAnim, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _containerAnim, curve: Curves.easeOutCubic));

    // Start after short delay (image loads first)
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _containerAnim.forward();
        _startTyping();
        _startCursorBlink();
      }
    });
  }

  void _startTyping() {
    // Adaptive speed: shorter prompts type faster, longer ones slower
    final charCount = widget.promptText.length;
    final speed = charCount < 100 ? 35 : charCount < 300 ? 25 : 18;

    _timer = Timer.periodic(Duration(milliseconds: speed), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_charIndex < widget.promptText.length) {
        setState(() {
          _displayed = widget.promptText.substring(0, _charIndex + 1);
          _charIndex++;
        });
      } else {
        t.cancel();
        // Stop cursor blinking after done
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _cursorTimer?.cancel();
            setState(() => _cursorVisible = false);
          }
        });
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted) setState(() => _cursorVisible = !_cursorVisible);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cursorTimer?.cancel();
    _containerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDoneTyping = _charIndex >= widget.promptText.length;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgCard, _bgCardLight],
            ),
            border: Border.all(color: _purple.withOpacity(0.22), width: 1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _purple.withOpacity(0.10),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Gradient indicator bar
                  Container(
                    width: 3, height: 16,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_purple, _teal],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'PROMPT STRING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: _purpleLight,
                    ),
                  ),
                  const Spacer(),
                  // Live typing indicator badge
                  if (!isDoneTyping)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _purple.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _purple.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PulsingDot(),
                          const SizedBox(width: 5),
                          const Text(
                            'typing...',
                            style: TextStyle(
                              fontSize: 9,
                              color: _purpleLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                  // Done badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _teal.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _teal.withOpacity(0.3), width: 1),
                      ),
                      child: const Text(
                        '✓ ready',
                        style: TextStyle(fontSize: 9, color: _teal, letterSpacing: 0.5),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Typing text with blinking cursor
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _displayed,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.65,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    // Blinking cursor
                    WidgetSpan(
                      child: AnimatedOpacity(
                        opacity: _cursorVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 100),
                        child: Container(
                          width: 2,
                          height: 18,
                          margin: const EdgeInsets.only(left: 2, bottom: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [_purple, _teal],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar while typing
              if (!isDoneTyping) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: widget.promptText.isEmpty
                        ? 0
                        : _charIndex / widget.promptText.length,
                    minHeight: 2,
                    backgroundColor: _purple.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _purple.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Small animated pulsing dot for "typing..." badge
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6, height: 6,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFAA6EE8),
        ),
      ),
    );
  }
}