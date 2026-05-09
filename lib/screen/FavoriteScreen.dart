import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promptseen/controller/home_screen_controller.dart';

class FavoriteScreen extends GetView<HomeController> {
  const FavoriteScreen({super.key});

  // Color Palette from Splash Screen
  static const Color primaryGradient1 = Color(0xFF9B59B6); // Purple
  static const Color primaryGradient2 = Color(0xFF00BCD4); // Cyan
  static const Color darkBg = Color(0xFF0B1020);
  static const Color darkCardBg = Color(0xFF0B1020);
  static const Color accentOrange = Color(0xFFec5b13);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a0f0a),
              const Color(0xFF0f0a05),
              darkBg,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildEnhancedHeader(),
              Expanded(
                child: GetBuilder<HomeController>(
                  builder: (controller) {
                    /// ⭐ get favorites from all prompts
                    final favorites = controller.prompts
                        .where((p) => controller.isFavorite(p.id))
                        .toList();

                    if (favorites.isEmpty) {
                      return _buildEmptyState();
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: favorites.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (context, index) {
                        final prompt = favorites[index];
                        return _buildEnhancedFavoriteCard(prompt, controller);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1a0f0a),
            const Color(0xFF0f0a05).withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // GestureDetector(
          //   onTap: () => Get.back(),
          //   child: Container(
          //     width: 44,
          //     height: 44,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       gradient: LinearGradient(
          //         colors: [
          //           Colors.white.withOpacity(0.15),
          //           Colors.white.withOpacity(0.08),
          //         ],
          //       ),
          //       border: Border.all(
          //         color: Colors.white.withOpacity(0.2),
          //         width: 1.5,
          //       ),
          //     ),
          //     child: const Icon(
          //       Icons.arrow_back_ios_new_rounded,
          //       color: Colors.white,
          //       size: 18,
          //     ),
          //   ),
          // ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [primaryGradient1, primaryGradient2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'My Favorites',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                GetBuilder<HomeController>(
                  builder: (controller) {
                    final count = controller.prompts
                        .where((p) => controller.isFavorite(p.id))
                        .length;
                    return Text(
                      '$count ${count == 1 ? 'Prompt' : 'Prompts'} Saved',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  primaryGradient1.withOpacity(0.3),
                  primaryGradient2.withOpacity(0.2),
                ],
              ),
              border: Border.all(
                color: primaryGradient2.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryGradient1.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite,
              color: primaryGradient2,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  primaryGradient1.withOpacity(0.2),
                  primaryGradient2.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 60,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [primaryGradient1, primaryGradient2],
            ).createShader(bounds),
            child: Text(
              "No favorites yet",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start adding prompts to your collection",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Explore Prompts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFavoriteCard(dynamic prompt, HomeController controller) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/detail', arguments: prompt);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: primaryGradient1.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryGradient1.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              /// Image
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

              /// Gradient overlay
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

              /// Favorite badge (top-left)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        primaryGradient1.withOpacity(0.9),
                        primaryGradient2.withOpacity(0.7),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGradient1.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Saved',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Remove favorite button (top-right)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    controller.toggleFavorite(prompt.id);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accentOrange.withOpacity(0.95),
                          accentOrange.withOpacity(0.85),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentOrange.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              /// Title and category
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        prompt.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
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