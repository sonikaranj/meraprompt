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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0604),
      body: SafeArea(
        child: GetBuilder<HomeController>(
          builder: (controller) {
            _showConfigPopupIfNeeded();
            return CustomScrollView(
              slivers: [
                // Header
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  toolbarHeight: 100,
                  flexibleSpace: _buildHeader(controller),
                  pinned: true,
                ),
                // Search Bar
                SliverToBoxAdapter(child: _buildSearchBar(controller)),
                // Category Pills
                SliverToBoxAdapter(child: _buildCategoryPills(controller)),
                // Social CTA Card
                SliverToBoxAdapter(child: _buildSocialCommunityCard()),
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
          backgroundColor: const Color(0xFF14100D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.14), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Announcement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('Later'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B59B6),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          await _openExternalUrl(popupLink);
                          if (Get.isDialogOpen ?? false) {
                            Get.back();
                          }
                        },
                        child: const Text('Open'),
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

  Widget _buildHeader(HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0a0604),
            const Color(0xFF0a0604).withOpacity(0.9),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: const [Color(0xFF9B59B6), Color(0xFF00BCD4)],
                      ).createShader(bounds),
                      child: Text(
                        'PromptMera',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      controller.showFavoritesOnly
                          ? '${controller.favorites.length} Favorites'
                          : 'Trending AI Prompts',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                // Favorites toggle button
                // GestureDetector(
                //   onTap: () => controller.toggleFavoritesView(),
                //   child: Container(
                //     width: 50,
                //     height: 50,
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: controller.showFavoritesOnly
                //           ? const Color(0xFFec5b13)
                //           : Colors.white.withOpacity(0.05),
                //       border: Border.all(
                //         color: controller.showFavoritesOnly
                //             ? const Color(0xFFec5b13).withOpacity(0.5)
                //             : Colors.white.withOpacity(0.1),
                //         width: 2,
                //       ),
                //       boxShadow: controller.showFavoritesOnly
                //           ? [
                //         BoxShadow(
                //           color: const Color(0xFFec5b13)
                //               .withOpacity(0.3),
                //           blurRadius: 15,
                //           spreadRadius: 2,
                //         ),
                //       ]
                //           : [],
                //     ),
                //     child: Stack(
                //       alignment: Alignment.center,
                //       children: [
                //         Icon(
                //           controller.showFavoritesOnly
                //               ? Icons.favorite
                //               : Icons.favorite_border,
                //           color: controller.showFavoritesOnly
                //               ? Colors.white
                //               : Colors.grey[400],
                //           size: 24,
                //         ),
                //         if (controller.favoriteCount > 0)
                //           Positioned(
                //             top: -2,
                //             right: -2,
                //             child: Container(
                //               width: 22,
                //               height: 22,
                //               decoration: BoxDecoration(
                //                 shape: BoxShape.circle,
                //                 color: Colors.red,
                //                 border: Border.all(
                //                   color: const Color(0xFF0a0604),
                //                   width: 2,
                //                 ),
                //               ),
                //               child: Center(
                //                 child: Text(
                //                   '${controller.favoriteCount}',
                //                   style: const TextStyle(
                //                     color: Colors.white,
                //                     fontSize: 10,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: TextField(
          onChanged: controller.updateSearchQuery,
          style: TextStyle(color: Colors.grey[200], fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Search prompts...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[500],
              size: 20,
            ),
            suffixIcon: controller.searchQuery.isNotEmpty
                ? GestureDetector(
              onTap: () {
                controller.updateSearchQuery('');
              },
              child: Icon(
                Icons.close,
                color: Colors.grey[500],
                size: 20,
              ),
            )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPills(HomeController controller) {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          final isSelected = controller.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                controller.updateCategory(category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: isSelected
                      ? const Color(0xFF9B59B6)
                      : Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: const Color(0xFF9B59B6).withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                      : [],
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey[300],
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

  Widget _buildSocialCommunityCard() {
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
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF9B59B6).withOpacity(0.2),
            const Color(0xFF00BCD4).withOpacity(0.18),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9B59B6).withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
                child: const Icon(Icons.campaign_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Join Our Community',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Get prompt drops, updates, and bonus ideas daily',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  label: 'Join Telegram',
                  icon: Icons.send_rounded,
                  color: const Color(0xFF229ED9),
                  onTap: () => _openSocialLink(telegramDeepLink, telegramWebLink),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSocialButton(
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
            child: _buildSocialButton(
              label: 'WhatsApp Channel',
              icon: Icons.chat,
              color: const Color(0xFF25D366),
              onTap: () => _openExternalUrl(whatsappLink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.2),
          border: Border.all(color: color.withOpacity(0.45), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF9B59B6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading Prompts...',
                style: TextStyle(color: Colors.grey[400]),
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
                size: 50,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                controller.showFavoritesOnly
                    ? 'No favorites yet\nStart adding some!'
                    : 'No prompts found',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400]),
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
          return _buildPromptCard(context, prompt, controller);
        },
        childCount: filteredPrompts.length,
      ),
    );
  }

  Widget _buildPromptCard(
      BuildContext context, dynamic prompt, HomeController controller) {
    final isFav = controller.isFavorite(prompt.id);

    return GestureDetector(
      onTap: () async{
        final AdController controller = Get.find();
        controller.showInterstitialAd();
        Get.toNamed('/detail', arguments: prompt);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isFav
                ? const Color(0xFF9B59B6).withOpacity(0.45)
                : Colors.white.withOpacity(0.12),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: isFav
                  ? const Color(0xFF9B59B6).withOpacity(0.25)
                  : Colors.black.withOpacity(0.22),
              blurRadius: isFav ? 18 : 12,
              spreadRadius: isFav ? 1 : 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: prompt.imageUrl,
                  fit: BoxFit.cover,
                  // placeholder: (context, url) => Container(
                  //   color: Colors.grey[800],
                  //   child: Center(
                  //     child: CircularProgressIndicator(
                  //       valueColor: AlwaysStoppedAnimation<Color>(
                  //         Colors.grey[600]!,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
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
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.62),
                      ],
                    ),
                  ),
                ),
              ),
              // Favorite button with animation
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    controller.toggleFavorite(prompt.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFav
                          ? const Color(0xFF9B59B6).withOpacity(0.9)
                          : Colors.white.withOpacity(0.08),
                      border: Border.all(
                        color: isFav
                            ? const Color(0xFF9B59B6)
                            : Colors.white.withOpacity(0.15),
                        width: 1.5,
                      ),
                      boxShadow: isFav
                          ? [
                        BoxShadow(
                          color: const Color(0xFF9B59B6)
                              .withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                          : [],
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.white : Colors.white,
                      size: 18,
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
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              prompt.categoryName,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[300],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.sharePrompt(prompt),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: Icon(
                                Icons.share,
                                color: Colors.grey[300],
                                size: 12,
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

  // Widget _buildBottomNavBar(HomeController controller) {
  //   return ClipRRect(
  //     child: BackdropFilter(
  //       filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
  //       child: Container(
  //         height: 80,
  //         decoration: BoxDecoration(
  //           color: Colors.white.withOpacity(0.05),
  //           border: Border(
  //             top: BorderSide(
  //               color: Colors.white.withOpacity(0.1),
  //               width: 1,
  //             ),
  //           ),
  //         ),
  //         child: Obx(
  //           ()=> Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               _buildNavItem(
  //                 icon: Icons.home_filled,
  //                 label: 'Home',
  //                 isActive: controller.selectIndex.value == 0 ,
  //                 onTap: (){
  //
  //                   controller.homeclick();
  //                 }
  //               ),
  //               Stack(
  //                 children: [
  //                   _buildNavItem(
  //                     icon: Icons.favorite,
  //                     label: 'Favorites',
  //                     isActive: controller.selectIndex.value == 1 ,
  //                     onTap: () => controller.toggleFavoritesView(),
  //                   ),
  //                 ],
  //               ),
  //               // _buildNavItem(
  //               //   icon: Icons.person_outline,
  //               //   label: 'Profile',
  //               //   isActive: false,
  //               // ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildNavItem({
  //   required IconData icon,
  //   required String label,
  //   required bool isActive,
  //   VoidCallback? onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(
  //           icon,
  //           color: isActive ? const Color(0xFFec5b13) : Colors.grey[500],
  //           size: 20,
  //         ),
  //         SizedBox(height: 4),
  //         Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 9,
  //             fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
  //             color: isActive ? const Color(0xFFec5b13) : Colors.grey[500],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}