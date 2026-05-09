import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promptseen/controller/home_screen_controller.dart';

class FavoriteScreen extends GetView<HomeController> {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0604),
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: const Color(0xFF0a0604),
        elevation: 0,
      ),
      body: GetBuilder<HomeController>(
        builder: (controller) {

          /// ⭐ get favorites from all prompts
          final favorites = controller.prompts
              .where((p) => controller.isFavorite(p.id))
              .toList();

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 60,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No favorites yet",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
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
              return _buildFavoriteCard(prompt, controller);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(dynamic prompt, HomeController controller) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/detail', arguments: prompt);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
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
                  ),
                ),
              ),
            ),

            /// Remove favorite
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  controller.toggleFavorite(prompt.id);
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFec5b13),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),

            /// Title
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(
                  prompt.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
