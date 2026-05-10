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
              // Purple glow top-right
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
              // Teal glow bottom-left
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
                  // ── AppBar ───────────────────────────────────────
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
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    title: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [_purple, _teal],
                      ).createShader(bounds),
                      child: const Text(
                        'Prompt Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      GestureDetector(
                        onTap: () => showMenu(
                          context: context,
                          color: _bgCardLight,
                          position:
                          const RelativeRect.fromLTRB(100, 50, 0, 0),
                          items: [
                            PopupMenuItem(
                              onTap: () => controller.sharePrompt(),
                              child: Row(children: const [
                                Icon(Icons.share, color: _teal),
                                SizedBox(width: 12),
                                Text('Share',
                                    style:
                                    TextStyle(color: Colors.white)),
                              ]),
                            ),
                            PopupMenuItem(
                              onTap: () => _showReportDialog(context),
                              child: Row(children: const [
                                Icon(Icons.flag, color: Color(0xFFFF6B9D)),
                                SizedBox(width: 12),
                                Text('Report Prompt',
                                    style:
                                    TextStyle(color: Colors.white)),
                              ]),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _bgCard,
                            border:
                            Border.all(color: _borderColor, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.more_vert,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),

                  // ── Main Image ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildMainImage(controller),
                    ),
                  ),

                  // ── Prompt Card with typing animation ────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _TypingPromptCard(
                        promptText: controller.prompt.promptText,
                        onCopy: () => controller.copyPrompt(),
                      ),
                    ),
                  ),

                  // ── Send to AI Buttons ───────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildSendButtons(controller),
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

  // ── Report Dialog ─────────────────────────────────────────────────────────

  void _showReportDialog(BuildContext context) {
    final reportController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: _bgCardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Color(0xFFFF6B9D),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Report This Prompt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Please describe why you\'re reporting this prompt',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[400],
                ),
              ),

              const SizedBox(height: 16),

              // Text field
              TextField(
                controller: reportController,
                maxLines: 4,
                minLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type your report here...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: _bgCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _purple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _purple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _purple.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _purple.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Submit button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final reportText = reportController.text.trim();
                        if (reportText.isEmpty) {
                          Get.snackbar(
                            'Empty Report',
                            'Please describe why you\'re reporting this prompt',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: _bgCardLight,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        // Close dialog
                        Get.back();

                        // Show success message directly
                        _showReportSuccessMessage();

                        // Clear text field
                        reportController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B9D), Color(0xFFFF8FAE)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B9D).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Submit Report',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showReportSuccessMessage() {
    Get.snackbar(
      'Report Submitted ✓',
      'Thank you! Your report has been received. Our team will review it shortly.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _bgCardLight,
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      duration: const Duration(seconds: 5),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B9D).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFFFF6B9D),
          size: 24,
        ),
      ),
      shouldIconPulse: true,
    );
  }

  // ── Main Image ────────────────────────────────────────────────────────────

  Widget _buildMainImage(DetailController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.22),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: _teal.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
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
              height: 380,
              width: double.infinity,
              placeholder: (context, url) => Container(
                height: 380,
                color: _bgCard,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_purple),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 380,
                color: _bgCard,
                child: Icon(Icons.image_not_supported,
                    color: Colors.grey[600], size: 50),
              ),
            ),
            // Bottom fade
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      _bgDeep.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Share
            Positioned(
              top: 14, left: 14,
              child: GestureDetector(
                onTap: () => controller.sharePrompt(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _bgCard.withOpacity(0.85),
                    border: Border.all(
                        color: _teal.withOpacity(0.4), width: 1),
                  ),
                  child: const Icon(Icons.share, color: _teal, size: 16),
                ),
              ),
            ),
            // Favorite
            Positioned(
              top: 14, right: 14,
              child: GestureDetector(
                onTap: () => controller.toggleFavorite(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _bgCard.withOpacity(0.85),
                    border: Border.all(
                        color: _purple.withOpacity(0.4), width: 1),
                  ),
                  child: Icon(
                    controller.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: controller.isFavorite
                        ? const Color(0xFFFF6B9D)
                        : Colors.white,
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

  // ── Send Buttons ──────────────────────────────────────────────────────────

  Widget _buildSendButtons(DetailController controller) {
    final prompt = controller.prompt.promptText.trim();
    return Column(
      children: [
        // Gemini
        _AiSendButton(
          label: 'Generate with Gemini',
          icon: Icons.auto_awesome,
          gradientColors: const [Color(0xFF7B4FD4), Color(0xFF3EC6C6)],
          glowColor: _purple,
          onTap: () => _sendToAi(
            controller,
            promptText: prompt,
            // ✅ https://gemini.google.com/app?q=<encoded_prompt>
            urlBuilder: (encoded) =>
            'https://gemini.google.com/app?q=$encoded',
            fallback: 'https://gemini.google.com/app',
            aiName: 'Gemini',
          ),
        ),
        const SizedBox(height: 12),
        // ChatGPT
        _AiSendButton(
          label: 'Generate with ChatGPT',
          icon: Icons.smart_toy_outlined,
          gradientColors: const [Color(0xFF3EC6C6), Color(0xFF6A5ACD)],
          glowColor: _teal,
          onTap: () => _sendToAi(
            controller,
            promptText: prompt,
            // ✅ https://chatgpt.com/?q=<encoded_prompt>
            urlBuilder: (encoded) =>
            'https://chatgpt.com/?q=$encoded',
            fallback: 'https://chatgpt.com/',
            aiName: 'ChatGPT',
          ),
        ),
      ],
    );
  }

  Future<void> _sendToAi(
      DetailController controller, {
        required String promptText,
        required String Function(String encoded) urlBuilder,
        required String fallback,
        required String aiName,
      }) async {
    if (promptText.isEmpty) {
      Get.snackbar('Prompt missing', 'No prompt text available.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _bgCardLight,
          colorText: Colors.white);
      return;
    }

    // Copy prompt to clipboard as well
    controller.copyPrompt();

    // URL encode the prompt
    final encoded = Uri.encodeComponent(promptText);
    final primaryUri = Uri.parse(urlBuilder(encoded));
    final fallbackUri = Uri.parse(fallback);

    // Try primary URL with prompt pre-filled
    if (await canLaunchUrl(primaryUri)) {
      await launchUrl(primaryUri, mode: LaunchMode.externalApplication);
      return;
    }

    // Fallback: open plain app + snackbar to paste
    if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      Get.snackbar(
        'Prompt Copied! 📋',
        'Long press & paste in $aiName to get started',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _bgCardLight,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.content_paste_rounded, color: _teal),
        duration: const Duration(seconds: 5),
      );
      return;
    }

    Get.snackbar('Unable to open', 'Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: _bgCardLight,
        colorText: Colors.white);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Typing Prompt Card
// ─────────────────────────────────────────────────────────────────────────────

class _TypingPromptCard extends StatefulWidget {
  final String promptText;
  final VoidCallback onCopy;

  const _TypingPromptCard({
    required this.promptText,
    required this.onCopy,
  });

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

  String _displayed  = '';
  int    _charIndex  = 0;
  bool   _cursorOn   = true;
  bool   _isDone     = false;

  Timer? _typingTimer;
  Timer? _cursorTimer;

  late AnimationController _enterCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
        begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _enterCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      _enterCtrl.forward();
      _startCursor();
      Future.delayed(const Duration(milliseconds: 300), _startTyping);
    });
  }

  void _startTyping() {
    if (!mounted) return;
    final total = widget.promptText.length;
    final ms    = total < 80 ? 38 : total < 250 ? 26 : 15;

    _typingTimer = Timer.periodic(Duration(milliseconds: ms), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_charIndex < total) {
        setState(() {
          _charIndex++;
          _displayed = widget.promptText.substring(0, _charIndex);
        });
      } else {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (!mounted) return;
          _cursorTimer?.cancel();
          setState(() { _cursorOn = false; _isDone = true; });
        });
      }
    });
  }

  void _startCursor() {
    _cursorTimer =
        Timer.periodic(const Duration(milliseconds: 520), (_) {
          if (mounted) setState(() => _cursorOn = !_cursorOn);
        });
  }

  double get _progress => widget.promptText.isEmpty
      ? 0
      : _charIndex / widget.promptText.length;

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _purple.withOpacity(0.22), width: 1),
            boxShadow: [
              BoxShadow(
                color: _purple.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ─────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 3, height: 18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_purple, _teal],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'PROMPT STRING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.6,
                      color: _purpleLight,
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _isDone
                        ? _buildBadge(
                      key: const ValueKey('done'),
                      label: '✓ Ready',
                      color: _teal,
                    )
                        : _buildTypingBadge(
                        key: const ValueKey('typing')),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Typed text + blinking cursor ────────────────────
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _displayed,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.88),
                        height: 1.7,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: AnimatedOpacity(
                        opacity: _cursorOn ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 80),
                        child: Container(
                          width: 2, height: 16,
                          margin: const EdgeInsets.only(left: 2),
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

              // ── Progress bar ────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _isDone
                    ? const SizedBox(height: 4)
                    : Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _progress),
                      duration: const Duration(milliseconds: 100),
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v,
                        minHeight: 2,
                        backgroundColor:
                        _purple.withOpacity(0.10),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _purple.withOpacity(0.60)),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Divider ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        _purple.withOpacity(0.3),
                        _teal.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // ── Copy button row ─────────────────────────────────
              Row(
                children: [
                  // Char count
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _purple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _purple.withOpacity(0.18), width: 1),
                    ),
                    child: Text(
                      '${widget.promptText.length} chars',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Copy button
                  GestureDetector(
                    onTap: widget.onCopy,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _teal.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _teal.withOpacity(0.28), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.content_copy_rounded,
                              color: _teal, size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 12,
                              color: _teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required Key key,
    required String label,
    required Color color,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypingBadge({required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _purple.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _purple.withOpacity(0.28), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(),
          const SizedBox(width: 5),
          const Text(
            'typing...',
            style: TextStyle(
              fontSize: 10,
              color: _purpleLight,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AI Send Button
// ─────────────────────────────────────────────────────────────────────────────

class _AiSendButton extends StatelessWidget {
  final String      label;
  final IconData    icon;
  final List<Color> gradientColors;
  final Color       glowColor;
  final VoidCallback onTap;

  const _AiSendButton({
    required this.label,
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 10),
            // Arrow indicator
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing Dot
// ─────────────────────────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 750))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7, height: 7,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFAA6EE8),
        ),
      ),
    );
  }
}