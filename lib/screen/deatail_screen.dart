import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promptseen/Admob/Admob_service.dart';
import 'package:promptseen/Admob/app_config.dart';
import 'package:promptseen/controller/detail_controller.dart';
import 'package:promptseen/service/review_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends GetView<DetailController> {
  const DetailScreen({Key? key}) : super(key: key);

  static const Color _bgDeep      = Color(0xFF0D0E1A);
  static const Color _bgCard      = Color(0xFF13152B);
  static const Color _bgCardLight = Color(0xFF1A1D35);
  static const Color _purple      = Color(0xFF38BDF8);
  static const Color _teal        = Color(0xFF3EC6C6);
  static const Color _purpleLight = Color(0xFF93C5FD);
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
                controller: controller.scrollController,
                slivers: [
                  // ── AppBar ───────────────────────────────────────
                  SliverAppBar(
                    backgroundColor: _bgDeep,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    leadingWidth: 56,
                    leading: GestureDetector(
                      // opaque = poora box tappable, margin/transparent area me
                      // taps fall-through nahi honge.
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // Get.back() andar se closeCurrentSnackbar() call karta
                        // hai, jo unlock-snackbar animate hote waqt
                        // LateInitializationError crash deta hai (GetX bug).
                        // Isliye seedha Navigator se pop karo — snackbar ko
                        // bina chhede route safely band ho jata hai.
                        final nav = Navigator.of(context);
                        if (nav.canPop()) {
                          nav.pop();
                        } else {
                          Get.offAllNamed('/home');
                        }
                      },
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
                                Icon(Icons.flag, color: Color(0xFF06B6D4)),
                                SizedBox(width: 12),
                                Text('Report Prompt',
                                    style:
                                    TextStyle(color: Colors.white)),
                              ]),
                            ),
                            PopupMenuItem(
                              onTap: () => _showRateAppDialog(context),
                              child: Row(children: const [
                                Icon(Icons.star_rounded, color: Color(0xFFFFD700)),
                                SizedBox(width: 12),
                                Text('Rate App',
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

                  // ── Prompt Stats & Metadata ──────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildPromptMetadata(controller),
                    ),
                  ),

                  // ── Tags Section ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildTagsSection(),
                    ),
                  ),

                  // ── Prompt Card (locked / unlocked) ──────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      // key = prompt.id taaki prompt badalne par card fresh
                      // bane (typing animation dobara chale, content update ho).
                      child: controller.isUnlocked
                          ? _TypingPromptCard(
                              key: ValueKey('typing_${controller.prompt.id}'),
                              promptText: controller.prompt.promptText,
                              onCopy: () => controller.copyPrompt(),
                            )
                          : _LockedPromptCard(
                              key: ValueKey('locked_${controller.prompt.id}'),
                              promptText: controller.prompt.promptText,
                              onUnlock: () => controller.unlockPrompt(),
                            ),
                    ),
                  ),

                  // ── Send to AI Buttons (sirf unlock hone par) ────
                  if (controller.isUnlocked)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: _buildSendButtons(controller),
                      ),
                    ),

                  // ── MREC / banner ad (self-contained) ────────────
                  SliverToBoxAdapter(
                    child: MrecAdBox(
                      adUnitId: AppConfig.mrecAdUnitId,
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    ),
                  ),

                  // ── More Prompts ─────────────────────────────────
                  SliverToBoxAdapter(
                    child: _MorePromptsSection(controller: controller),
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
                      color: const Color(0xFF06B6D4).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Color(0xFF06B6D4),
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
                      // Navigator.pop = dialog band (Get.back snackbar crash se bacho)
                      onTap: () => Navigator.of(context).pop(),
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

                        // Close dialog (Navigator.pop = Get.back snackbar crash se bacho)
                        Navigator.of(context).pop();

                        // Show success message directly
                        _showReportSuccessMessage();

                        // Clear text field
                        reportController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF06B6D4), Color(0xFFFF8FAE)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06B6D4).withOpacity(0.3),
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

  // ── Rate App Dialog ──────────────────────────────────────────────────────

  void _showRateAppDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: _bgCardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFD700),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Love MK EDIT?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Rate our app and help us improve!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Rating Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStarButton(1),
                  const SizedBox(width: 8),
                  _buildStarButton(2),
                  const SizedBox(width: 8),
                  _buildStarButton(3),
                  const SizedBox(width: 8),
                  _buildStarButton(4),
                  const SizedBox(width: 8),
                  _buildStarButton(5),
                ],
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
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
                            'Later',
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
                  // Rate Now
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _rateAppNow();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Rate Now',
                            style: TextStyle(
                              color: Colors.black87,
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

  Widget _buildStarButton(int rating) {
    return GestureDetector(
      onTap: () {
        Navigator.of(Get.context!).pop();
        _rateAppNow();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _bgCard,
          border: Border.all(
            color: _purple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '$rating',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _rateAppNow() async {
    final reviewService = ReviewService();
    await reviewService.requestReview();
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
          color: const Color(0xFF06B6D4).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF06B6D4),
          size: 24,
        ),
      ),
      shouldIconPulse: true,
    );
  }

  // ── Tags Section ──────────────────────────────────────────────────────────

  Widget _buildTagsSection() {
    final tags = ['AI', 'Image', 'Creative', 'Editing', 'Photo'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    border: Border.all(
                      color: _teal.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      color: _teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  // ── Prompt Metadata & Stats ───────────────────────────────────────────────

  Widget _buildPromptMetadata(DetailController controller) {
    final prompt = controller.prompt;
    return Column(
      children: [
        // Category, Difficulty, Stats Row
        Row(
          children: [
            // Category Badge
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF3EC6C6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.label_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prompt.categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Difficulty Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _bgCard,
                border: Border.all(color: _teal.withOpacity(0.4), width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up,
                      color: _teal, size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'Easy',
                    style: TextStyle(
                      color: _teal,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Stats Row: Views, Favorites, Copy Button
        Row(
          children: [
            // Views stat
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _bgCard,
                  border: Border.all(color: _borderColor, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2.5K',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Views',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Favorites stat
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _bgCard,
                  border: Border.all(color: _borderColor, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '486',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Saved',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Quick Copy Button
            GestureDetector(
              onTap: () => controller.copyPrompt(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _purple.withOpacity(0.6),
                      _teal.withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: _purple.withOpacity(0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.content_copy_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(height: 2),
                    Text(
                      'Copy',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
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
              placeholder: (context, url) => Shimmer.fromColors(
                baseColor: _bgCard,
                highlightColor: const Color(0xFF252A45),
                child: Container(
                  height: 380,
                  color: _bgCard,
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
                        ? const Color(0xFF06B6D4)
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
    super.key,
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
  static const Color _purple      = Color(0xFF38BDF8);
  static const Color _teal        = Color(0xFF3EC6C6);
  static const Color _purpleLight = Color(0xFF93C5FD);

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
          color: Color(0xFF38BDF8),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCKED PROMPT CARD — blurred preview + "Unlock Prompt" (watch ad) button
// ─────────────────────────────────────────────────────────────────────────────
class _LockedPromptCard extends StatelessWidget {
  final String promptText;
  final VoidCallback onUnlock;

  const _LockedPromptCard({
    super.key,
    required this.promptText,
    required this.onUnlock,
  });

  static const Color _bgCard = Color(0xFF13152B);
  static const Color _border = Color(0xFF2A2D4A);
  static const Color _purple = Color(0xFF38BDF8);
  static const Color _purpleLight = Color(0xFF93C5FD);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Blurred preview of the prompt text (teaser behind the lock).
          Positioned.fill(
            child: IgnorePointer(
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    promptText.isEmpty
                        ? 'This prompt is locked. Unlock to reveal the full prompt text and send it to your favourite AI tools.'
                        : promptText,
                    maxLines: 6,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Lock overlay + unlock button.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _bgCard.withOpacity(0.65),
                  _bgCard.withOpacity(0.92),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _purple.withOpacity(0.15),
                    border: Border.all(color: _purple.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: _purpleLight, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Prompt Locked',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ek chhota ad dekho aur ye prompt unlock karo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onUnlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
                    label: const Text(
                      'Unlock Prompt',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MORE PROMPTS — detail ke neeche horizontal list (same screen me khulti hai)
// ─────────────────────────────────────────────────────────────────────────────
class _MorePromptsSection extends StatelessWidget {
  final DetailController controller;

  const _MorePromptsSection({required this.controller});

  static const Color _bgCard = Color(0xFF13152B);
  static const Color _border = Color(0xFF2A2D4A);
  static const Color _purple = Color(0xFF38BDF8);

  @override
  Widget build(BuildContext context) {
    final items = controller.morePrompts;
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading with subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: _purple, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Related Prompts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Similar prompts in this category',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2-column grid — saare related prompts ek saath dikhte hain
          // (pehle horizontal list thi, ab 2 image per row).
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              mainAxisExtent: 230,
            ),
            itemBuilder: (ctx, i) {
              final p = items[i];
              return GestureDetector(
                onTap: () => controller.openPrompt(p),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: _bgCard,
                                border: Border.all(color: _border),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: p.imageUrl.isEmpty
                                  ? const Icon(Icons.image_outlined,
                                      color: Colors.white24, size: 32)
                                  : CachedNetworkImage(
                                      imageUrl: p.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (c, u) =>
                                          Shimmer.fromColors(
                                        baseColor: _bgCard,
                                        highlightColor:
                                            const Color(0xFF252A45),
                                        child: Container(color: _bgCard),
                                      ),
                                      errorWidget: (c, u, e) => const Icon(
                                          Icons.broken_image_outlined,
                                          color: Colors.white24,
                                          size: 32),
                                    ),
                            ),
                          ),
                          // Rating badge
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star_rounded,
                                      color: Color(0xFFFFD700), size: 12),
                                  SizedBox(width: 2),
                                  Text(
                                    '4.8',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}