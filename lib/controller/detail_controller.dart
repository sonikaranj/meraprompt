import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:promptseen/Admob/Admob_service.dart';
import 'package:promptseen/controller/home_screen_controller.dart';
import 'package:share_plus/share_plus.dart';


class DetailController extends GetxController {
  late PromptModel prompt;
  bool isFavorite = false;
  final HomeController homeController = Get.find<HomeController>();

  // "More Prompts" tap karke same screen ko top par scroll karne ke liye.
  final ScrollController scrollController = ScrollController();

  /// Detail ke neeche dikhane wali "More Prompts" — pehle same category ki,
  /// fir baaki; current prompt ko chhod kar. Max 12.
  List<PromptModel> get morePrompts {
    final all = homeController.prompts;
    final others = all.where((p) => p.id != prompt.id).toList();
    final sameCat =
        others.where((p) => p.categoryName == prompt.categoryName).toList();
    final rest =
        others.where((p) => p.categoryName != prompt.categoryName).toList();
    return [...sameCat, ...rest].take(12).toList();
  }

  /// "More Prompts" me se kisi par tap → isi screen me wahi prompt khol do
  /// (naya route push nahi — GetX controller reuse ke issues se bachne ke liye)
  /// aur upar scroll kar do.
  void openPrompt(PromptModel p) {
    if (p.id == prompt.id) return;
    prompt = p;
    isFavorite = homeController.isFavorite(prompt.id);
    isUnlocked = _isPromptUnlocked(prompt.id);
    update();
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // ── Prompt lock / unlock ──────────────────────────────────────────
  // Unlock ki gayi prompt IDs GetStorage me persist hoti hain, taaki ek baar
  // unlock hone ke baad prompt hamesha khuli rahe (app restart ke baad bhi).
  final GetStorage _box = GetStorage();
  static const String _unlockedKey = 'unlocked_prompts';
  bool isUnlocked = false;

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
    isUnlocked = _isPromptUnlocked(prompt.id);
  }

  /// Ye prompt pehle se unlock hai ya nahi (persisted list me hai kya).
  bool _isPromptUnlocked(String id) {
    if (id.isEmpty) return true; // safety: bina id wali prompt lock mat karo
    final list = (_box.read<List>(_unlockedKey) ?? []).cast<String>();
    return list.contains(id);
  }

  /// "Unlock Prompt" button par call hota hai: rewarded ad dikhao, reward
  /// milne par prompt unlock + persist.
  Future<void> unlockPrompt() async {
    if (isUnlocked) return;

    if (Get.isRegistered<AdController>()) {
      await Get.find<AdController>().showRewardedForUnlock(
        onReward: _grantUnlock,
      );
    } else {
      // AdController na mile to user ko block mat karo.
      _grantUnlock();
    }
  }

  void _grantUnlock() {
    if (isUnlocked) return;
    isUnlocked = true;

    final list = (_box.read<List>(_unlockedKey) ?? []).cast<String>();
    if (prompt.id.isNotEmpty && !list.contains(prompt.id)) {
      list.add(prompt.id);
      _box.write(_unlockedKey, list);
    }

    update(); // GetBuilder ko rebuild karo (lock UI hat jaye)
    Get.snackbar(
      'Unlocked',
      'Prompt unlock ho gaya 🎉',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
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