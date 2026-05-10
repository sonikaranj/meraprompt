import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class PromptModel {
  final String id;
  final String title;
  final String promptText;
  final String imageUrl;
  final String categoryName;
  final String viewsCount;
  final String shareCount;
  final String generateCount;

  PromptModel({
    required this.id,
    required this.title,
    required this.promptText,
    required this.imageUrl,
    required this.categoryName,
    required this.viewsCount,
    required this.shareCount,
    required this.generateCount,
  });

  factory PromptModel.fromJson(Map<String, dynamic> json) {
    return PromptModel(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      promptText: json['prompt_text'] ?? '',
      imageUrl: json['image_url'] ?? '',
      categoryName: json['category_name'] ?? 'Other',
      viewsCount: json['views_count'] ?? '0',
      shareCount: json['share_count'] ?? '0',
      generateCount: json['generate_count'] ?? '0',
    );
  }
}

class HomeController extends GetxController {
  bool isLoading = true;
  List<PromptModel> prompts = [];
  List<PromptModel> favorites = [];
  String selectedCategory = 'All';
  String searchQuery = '';
  bool showFavoritesOnly = false;
  RxInt selectIndex = 0.obs;

  List<String> favoriteIds = [];


  final box = GetStorage();

  final String apiUrl =
      'https://promptmera.com/applicationv1/api.php?action=get_prompts&api_key=PROMPTSEEN_ADMIN_123';
  final String categoriesApiUrl =
      'https://promptmera.com/applicationv1/api.php?action=get_categories&api_key=PROMPTSEEN_ADMIN_123';

  List<String> categories = ['All'];

  @override
  void onInit() {
    super.onInit();
    _loadFavorites();
    fetchCategories();
    fetchPrompts();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(categoriesApiUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) return;

      final json = jsonDecode(response.body);
      final List<dynamic> data = json['data'] ?? [];
      final List<String> apiCategories = data
          .map((item) => (item['name'] ?? '').toString().trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();

      if (apiCategories.isNotEmpty) {
        categories = ['All', ...apiCategories];

        if (!categories.contains(selectedCategory)) {
          selectedCategory = 'All';
        }

        update();
      }
    } catch (_) {
      // Keep existing fallback categories when category API fails.
    }
  }

  Future<void> fetchPrompts() async {
    try {
      isLoading = true;
      update();

      final response = await http.get(Uri.parse(apiUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> data = json['data'] ?? [];

        prompts = data.map((item) => PromptModel.fromJson(item)).toList();
        if (categories.length == 1) {
          final promptCategories = prompts
              .map((p) => p.categoryName.trim())
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList();
          if (promptCategories.isNotEmpty) {
            categories = ['All', ...promptCategories];
          }
        }
        /// restore favorites
        favorites = prompts.where((p) => favoriteIds.contains(p.id)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load prompts',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Error: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading = false;
      update();
    }
  }

  List<PromptModel> getFilteredPrompts() {
    // If showing favorites, filter from favorites list
    List<PromptModel> filtered = showFavoritesOnly ? favorites : prompts;

    // Filter by category
    if (selectedCategory != 'All') {
      filtered = filtered
          .where((p) => p.categoryName == selectedCategory)
          .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
      p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          p.promptText.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  void updateCategory(String category) {
    selectedCategory = category;
    update();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    update();
  }

  void toggleFavorite(String promptId) {
    final prompt = prompts.firstWhere((p) => p.id == promptId);

    if (isFavorite(promptId)) {
      // Remove from favorites
      favorites.removeWhere((p) => p.id == promptId);

    } else {
      // Add to favorites
      favorites.add(prompt);

    }

    _saveFavorites();
    update();
  }

  bool isFavorite(String promptId) {
    return favorites.any((p) => p.id == promptId);
  }
   void homeclick(){
     selectIndex.value = 0;
     showFavoritesOnly = false;
     update();
   }


  void toggleFavoritesView() {
    showFavoritesOnly = !showFavoritesOnly;
    selectedCategory = 'All';
    searchQuery = '';
    selectIndex.value = 1;
    update();
  }

  void _saveFavorites() {
    try {
      favoriteIds = favorites.map((p) => p.id).toList();
      box.write('favorites', favoriteIds);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  void _loadFavorites() {
    try {
      favoriteIds = (box.read<List>('favorites') ?? []).cast<String>();
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }


  Future<void> sharePrompt(PromptModel prompt) async {
   print(prompt.title);
  }

  void clearFavorites() {
    favorites.clear();
    box.remove('favorites');

    update();
  }

  int get favoriteCount => favorites.length;
}