import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:promptseen/controller/home_screen_controller.dart';
import 'package:share_plus/share_plus.dart';


class DetailController extends GetxController {
  late PromptModel prompt;
  bool isFavorite = false;
  final HomeController homeController = Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    // Get prompt from navigation arguments
    prompt = Get.arguments ?? PromptModel(
      id: '',
      title: 'Unknown',
      promptText: 'No prompt text',
      imageUrl: '',
      categoryName: 'Other',
      viewsCount: '0',
      shareCount: '0',
      generateCount: '0',
    );

    isFavorite = homeController.isFavorite(prompt.id);
  }

  void copyPrompt() {
    Clipboard.setData(ClipboardData(text: prompt.promptText));
    Get.snackbar(
      'Copied',
      'Prompt copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void savePrompt() {
    // TODO: Implement bookmark/save functionality
    Get.snackbar(
      'Saved',
      'Prompt saved to collection',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void exportPrompt() {
    // TODO: Implement export functionality
    Get.snackbar(
      'Exported',
      'Prompt exported successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void generatePrompt() {
    // TODO: Implement prompt generation
    Get.snackbar(
      'Generating',
      'Generating image from prompt...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleFavorite() {
    homeController.toggleFavorite(prompt.id);

    isFavorite = homeController.isFavorite(prompt.id);

    Get.snackbar(
      isFavorite ? 'Added' : 'Removed',
      isFavorite
          ? 'Added to favorites'
          : 'Removed from favorites',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    update();
  }


  void sharePrompt() {
    final text =
        "${prompt.title}\n\n${prompt.promptText}\n\nShared via PromptSeen App";

    Share.share(text);

    Get.snackbar(
      'Shared',
      'Prompt shared successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

}