import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promptseen/Admob/Admob_service.dart';
import 'package:promptseen/Admob/app_config.dart';
import 'package:promptseen/controller/home_screen_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({Key? key}) : super(key: key);

  static bool _popupCheckedThisSession = false;

  // Color Palette from Splash Screen
  static const Color primaryGradient1 = Color(0xFF9B59B6); // Purple
  static const Color primaryGradient2 = Color(0xFF00BCD4); // Cyan
  static const Color darkBg = Color(0xFF0B1020);
  static const Color darkCardBg = Color(0xFF14100D);
  static  Color accentOrange =  Color(0xFF6750A4).withValues(alpha: 0.15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: GetBuilder<HomeController>(
          builder: (controller) {
            _showConfigPopupIfNeeded();
            return CustomScrollView(
              slivers: [
                // Enhanced Header with Gradient Background
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 120,
                  flexibleSpace: _buildEnhancedHeader(controller),
                  pinned: true,
                ),
                // Search Bar
                SliverToBoxAdapter(child: _buildEnhancedSearchBar(controller)),
                // Category Pills
                SliverToBoxAdapter(child: _buildEnhancedCategoryPills(controller)),
                // Social CTA Card
                SliverToBoxAdapter(child: _buildEnhancedSocialCommunityCard()),
                // Grid of Prompts
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: _buildPromptsGrid(controller),
                ),
                // Bottom padding for nav bar
                SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showConfigPopupIfNeeded() {
    if (_popupCheckedThisSession) return;
    _popupCheckedThisSession = true;

    final popupLink = AppConfig.popupAds.trim();
    if (popupLink.isEmpty) return;

    final message = AppConfig.popupMessage.trim().isEmpty
        ? 'New update is available. Tap below to open it.'
        : AppConfig.popupMessage.trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isDialogOpen ?? false) return;

      Get.dialog(
        Dialog(
          backgroundColor: darkCardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Colors.white.withOpacity(0.14),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Announcement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Later',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [primaryGradient1, primaryGradient2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryGradient1.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            await _openExternalUrl(popupLink);
                            if (Get.isDialogOpen ?? false) {
                              Get.back();
                            }
                          },
                          child: const Text(
                            'Open',
                            style: TextStyle(fontWeight: FontWeight.w600),
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
    });
  }

  Future<void> _openExternalUrl(String url) async {
    final cleanUrl = url.trim();
    final uri = Uri.tryParse(cleanUrl);
    if (cleanUrl.isEmpty || uri == null) {
      Get.snackbar(
        'Link not available',
        'Please check back later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    Get.snackbar(
      'Unable to open link',
      'Please try again later.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  Widget _buildEnhancedHeader(HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0B1020),
            const Color(0xFF14142B).withValues(alpha: 0.95),
            const Color(0xFF0B1020),

          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [primaryGradient1, primaryGradient2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'PromptMera',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.showFavoritesOnly
                          ? '${controller.favorites.length} Favorites'
                          : 'Smart AI Prompts',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        primaryGradient1.withOpacity(0.2),
                        primaryGradient2.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: primaryGradient2.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: primaryGradient2,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSearchBar(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryGradient1.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.updateSearchQuery,
          style: TextStyle(
            color: Colors.grey[100],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search prompts...',
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.grey[500],
              size: 22,
            ),
            suffixIcon: controller.searchQuery.isNotEmpty
                ? GestureDetector(
              onTap: () {
                controller.updateSearchQuery('');
              },
              child: Icon(
                Icons.close_rounded,
                color: Colors.grey[500],
                size: 22,
              ),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedCategoryPills(HomeController controller) {
    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final isSelected = controller.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                controller.updateCategory(category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: isSelected
                      ? LinearGradient(
                    colors: [primaryGradient1, primaryGradient2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.04),
                    ],
                  ),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white.withOpacity(0.12),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: primaryGradient1.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey[300],
                      letterSpacing: 0.3,
                    ),
                    child: Text(category),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedSocialCommunityCard() {
    final telegramHandle = AppConfig.telegram.trim();
    final instagramHandle = AppConfig.instraggram.trim();
    final whatsappLink = AppConfig.whatsapplink.trim();

    final telegramDeepLink = telegramHandle.startsWith('tg://')
        ? telegramHandle
        : 'tg://resolve?domain=${telegramHandle.isNotEmpty ? telegramHandle : 'promptseen'}';
    final telegramWebLink = telegramHandle.startsWith('http')
        ? telegramHandle
        : 'https://t.me/${telegramHandle.isNotEmpty ? telegramHandle : 'promptseen'}';

    final instagramDeepLink = instagramHandle.startsWith('instagram://')
        ? instagramHandle
        : 'instagram://user?username=${instagramHandle.isNotEmpty ? instagramHandle : 'promptseen'}';
    final instagramWebLink = instagramHandle.startsWith('http')
        ? instagramHandle
        : 'https://instagram.com/${instagramHandle.isNotEmpty ? instagramHandle : 'promptseen'}';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryGradient1.withOpacity(0.25),
            primaryGradient2.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGradient1.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primaryGradient1.withOpacity(0.4),
                      primaryGradient2.withOpacity(0.2),
                    ],
                  ),
                  border: Border.all(
                    color: primaryGradient2.withOpacity(0.3),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: primaryGradient2,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Join Our Community',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Get prompt drops & daily updates',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedSocialButton(
                  label: 'Telegram',
                  icon: Icons.send_rounded,
                  color: const Color(0xFF229ED9),
                  onTap: () => _openSocialLink(telegramDeepLink, telegramWebLink),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildEnhancedSocialButton(
                  label: 'Instagram',
                  icon: Icons.camera_alt_rounded,
                  color: const Color(0xFFE1306C),
                  onTap: () =>
                      _openSocialLink(instagramDeepLink, instagramWebLink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: _buildEnhancedSocialButton(
              label: 'WhatsApp Channel',
              icon: Icons.chat_rounded,
              color: const Color(0xFF25D366),
              onTap: () => _openExternalUrl(whatsappLink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.15),
          border: Border.all(color: color.withOpacity(0.4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSocialLink(String appUrl, String webUrl) async {
    final appUri = Uri.parse(appUrl);
    final webUri = Uri.parse(webUrl);

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    Get.snackbar(
      'Unable to open link',
      'Please try again later.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  Widget _buildPromptsGrid(HomeController controller) {
    final filteredPrompts = controller.getFilteredPrompts();

    if (controller.isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [primaryGradient1, primaryGradient2],
                ).createShader(bounds),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading Prompts...',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredPrompts.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                controller.showFavoritesOnly
                    ? Icons.favorite_border
                    : Icons.search_off,
                size: 56,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                controller.showFavoritesOnly
                    ? 'No favorites yet\nStart adding some!'
                    : 'No prompts found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final prompt = filteredPrompts[index];
          return _buildEnhancedPromptCard(context, prompt, controller);
        },
        childCount: filteredPrompts.length,
      ),
    );
  }

  Widget _buildEnhancedPromptCard(
      BuildContext context, dynamic prompt, HomeController controller) {
    final isFav = controller.isFavorite(prompt.id);

    return GestureDetector(
      onTap: () async {
        final AdController adController = Get.find();
        adController.showInterstitialAd();
        Get.toNamed('/detail', arguments: prompt);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isFav
                ? primaryGradient1.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isFav
                  ? primaryGradient1.withOpacity(0.3)
                  : Colors.black.withOpacity(0.25),
              blurRadius: isFav ? 20 : 14,
              spreadRadius: isFav ? 2 : 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: prompt.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                      size: 40,
                    ),
                  ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              // Favorite button with animation
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    controller.toggleFavorite(prompt.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isFav
                          ? LinearGradient(
                        colors: [primaryGradient1, primaryGradient2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(
                        color: isFav
                            ? Colors.white.withOpacity(0.3)
                            : Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: isFav
                          ? [
                        BoxShadow(
                          color: primaryGradient1.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                          : [],
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Text content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        prompt.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              prompt.categoryName,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[200],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.sharePrompt(prompt),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.share_rounded,
                                color: Colors.grey[200],
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}