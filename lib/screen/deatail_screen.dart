import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:promptseen/controller/detail_controller.dart';
import 'package:url_launcher/url_launcher.dart';

enum _AiTarget { chatgpt, gemini }

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

              // Main scroll content
              CustomScrollView(
                slivers: [
                  // ── AppBar ───────────────────────────────────────────
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
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
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
                                    Text('Share',
                                        style: TextStyle(color: Colors.white)),
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
                          child: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Main Image ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildMainImage(controller),
                    ),
                  ),

                  // ── Typing Prompt Card ───────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _TypingPromptCard(
                        promptText: controller.prompt.promptText,
                      ),
                    ),
                  ),

                  // ── Copy Button ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildActionButtons(controller),
                    ),
                  ),

                  // ── Generate Buttons ─────────────────────────────────
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

  // ── Main Image ────────────────────────────────────────────────────────────

  Widget _buildMainImage(DetailController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.20),
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
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: 50,
                ),
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
                    colors: [_bgDeep.withOpacity(0.6), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Share
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
            // Favorite
            Positioned(
              top: 16, right: 16,
              child: GestureDetector(
                onTap: () => controller.toggleFavorite(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _bgCard.withOpacity(0.85),
                    border: Border.all(
                        color: _purple.withOpacity(0.35), width: 1),
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

  // ── Copy Button ───────────────────────────────────────────────────────────

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
              BoxShadow(
                color: _purple.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _teal, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Generate Buttons ──────────────────────────────────────────────────────

  Widget _buildGenerateButtons(DetailController controller) {
    final promptText = controller.prompt.promptText.trim();
    return Column(
      children: [
        _buildGenerateButtonTile(
          label: 'Generate with Gemini',
          icon: Icons.auto_awesome,
          gradientColors: const [Color(0xFF7B4FD4), Color(0xFF3EC6C6)],
          glowColor: _purple,
          onTap: () => _showImageOrDirectDialog(
            controller,
            promptText: promptText,
            target: _AiTarget.gemini,
          ),
        ),
        const SizedBox(height: 12),
        _buildGenerateButtonTile(
          label: 'Generate with ChatGPT',
          icon: Icons.smart_toy_outlined,
          gradientColors: const [Color(0xFF3EC6C6), Color(0xFF6A5ACD)],
          glowColor: _teal,
          onTap: () => _showImageOrDirectDialog(
            controller,
            promptText: promptText,
            target: _AiTarget.chatgpt,
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

  // ── Bottom Sheet: Choose send mode ────────────────────────────────────────

  void _showImageOrDirectDialog(
      DetailController controller, {
        required String promptText,
        required _AiTarget target,
      }) {
    final name = target == _AiTarget.chatgpt ? 'ChatGPT' : 'Gemini';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF13152B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [_purple, _teal],
              ).createShader(bounds),
              child: Text(
                'Send to $name',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose how to send your prompt',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),

            // Option 1 — Prompt only
            _buildBottomSheetOption(
              icon: Icons.send_rounded,
              iconColor: _teal,
              title: 'Send Prompt Only',
              subtitle: 'Open $name with prompt pre-filled',
              onTap: () {
                Get.back();
                _openAiWithPrompt(controller,
                    promptText: promptText, target: target);
              },
            ),
            const SizedBox(height: 12),

            // Option 2 — Gallery
            _buildBottomSheetOption(
              icon: Icons.add_photo_alternate_rounded,
              iconColor: _purple,
              title: 'Pick Image + Send Prompt',
              subtitle: 'Select from gallery, then open $name',
              onTap: () {
                Get.back();
                _pickImageAndSend(controller,
                    promptText: promptText, target: target);
              },
            ),
            const SizedBox(height: 12),

            // Option 3 — Camera
            _buildBottomSheetOption(
              icon: Icons.camera_alt_rounded,
              iconColor: const Color(0xFFFFCB47),
              title: 'Take Photo + Send Prompt',
              subtitle: 'Use camera, then open $name',
              onTap: () {
                Get.back();
                _pickImageAndSend(controller,
                    promptText: promptText,
                    target: target,
                    fromCamera: true);
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildBottomSheetOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _bgCardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: iconColor.withOpacity(0.25), width: 1),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  // ── Image Picker ──────────────────────────────────────────────────────────

  Future<void> _pickImageAndSend(
      DetailController controller, {
        required String promptText,
        required _AiTarget target,
        bool fromCamera = false,
      }) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    final confirmed = await _showImagePreviewDialog(picked, promptText, target);
    if (confirmed != true) return;

    await _openAiWithPrompt(controller,
        promptText: promptText, target: target);
  }

  // ── Image Preview Dialog ──────────────────────────────────────────────────

  Future<bool?> _showImagePreviewDialog(
      XFile image,
      String promptText,
      _AiTarget target,
      ) {
    final name = target == _AiTarget.chatgpt ? 'ChatGPT' : 'Gemini';
    return Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: _bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _purple.withOpacity(0.25), width: 1),
            boxShadow: [
              BoxShadow(
                color: _purple.withOpacity(0.15),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                  Text(
                    'Send to $name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Image preview with gradient border
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_purple, _teal],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                padding: const EdgeInsets.all(1.5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11.5),
                  child: Image.file(
                    File(image.path),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Prompt preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _bgCardLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROMPT',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                        color: _purpleLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      promptText.length > 120
                          ? '${promptText.substring(0, 120)}...'
                          : promptText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Info note
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: _teal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _teal.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 14, color: _teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Prompt auto-filled in $name. Attach this image inside the app.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _teal,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Cancel / Confirm buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(result: false),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: _bgCardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderColor, width: 1),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: () => Get.back(result: true),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7B4FD4), Color(0xFF3EC6C6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _purple.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Open $name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
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
    );
  }

  // ── Open AI URL with prompt ───────────────────────────────────────────────

  Future<void> _openAiWithPrompt(
      DetailController controller, {
        required String promptText,
        required _AiTarget target,
      }) async {
    if (promptText.isEmpty) {
      Get.snackbar('Prompt missing', 'No prompt text available.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: _bgCardLight,
          colorText: Colors.white);
      return;
    }

    controller.copyPrompt();

    final encoded = Uri.encodeComponent(promptText);
    final name = target == _AiTarget.chatgpt ? 'ChatGPT' : 'Gemini';

    Uri primaryUri;
    Uri fallbackUri;

    switch (target) {
      case _AiTarget.chatgpt:
        primaryUri  = Uri.parse('https://chatgpt.com/?q=$encoded');
        fallbackUri = Uri.parse('https://chatgpt.com/');
        break;
      case _AiTarget.gemini:
        primaryUri  = Uri.parse(
            'https://aistudio.google.com/prompts/new_chat?prompt=$encoded');
        fallbackUri = Uri.parse('https://gemini.google.com/app');
        break;
    }

    if (await canLaunchUrl(primaryUri)) {
      await launchUrl(primaryUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (await canLaunchUrl(fallbackUri)) {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      Get.snackbar(
        'Prompt Copied! 📋',
        'Long press to paste in $name chat',
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
// Typewriter Prompt Card
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
  int    _charIndex = 0;
  bool   _cursorVisible = true;
  bool   _isDone = false;

  Timer? _typingTimer;
  Timer? _cursorTimer;

  late AnimationController _enterAnim;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();

    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _enterAnim, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      _enterAnim.forward();
      _startCursorBlink();
      Future.delayed(
          const Duration(milliseconds: 300), _startTyping);
    });
  }

  void _startTyping() {
    if (!mounted) return;
    final total = widget.promptText.length;
    final speed = total < 80 ? 40 : total < 250 ? 28 : 16;

    _typingTimer = Timer.periodic(Duration(milliseconds: speed), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_charIndex < total) {
        setState(() {
          _charIndex++;
          _displayed = widget.promptText.substring(0, _charIndex);
        });
      } else {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          _cursorTimer?.cancel();
          setState(() {
            _cursorVisible = false;
            _isDone = true;
          });
        });
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer =
        Timer.periodic(const Duration(milliseconds: 520), (_) {
          if (mounted) setState(() => _cursorVisible = !_cursorVisible);
        });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    _enterAnim.dispose();
    super.dispose();
  }

  double get _progress => widget.promptText.isEmpty
      ? 0
      : _charIndex / widget.promptText.length;

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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _isDone
                        ? _buildBadge(
                      key: const ValueKey('done'),
                      label: '✓ ready',
                      color: _teal,
                    )
                        : _buildTypingBadge(
                        key: const ValueKey('typing')),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Typed text + cursor
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
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: AnimatedOpacity(
                        opacity: _cursorVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 80),
                        child: Container(
                          width: 2, height: 18,
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

              // Progress bar
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _isDone
                    ? const SizedBox.shrink()
                    : Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _progress),
                      duration: const Duration(milliseconds: 120),
                      builder: (_, val, __) =>
                          LinearProgressIndicator(
                            value: val,
                            minHeight: 2,
                            backgroundColor: _purple.withOpacity(0.10),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _purple.withOpacity(0.65),
                            ),
                          ),
                    ),
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: color,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTypingBadge({required Key key}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
              fontSize: 9,
              color: _purpleLight,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing Dot
// ─────────────────────────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
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
      duration: const Duration(milliseconds: 750),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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