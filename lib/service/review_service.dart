import 'package:in_app_review/in_app_review.dart';
import 'package:get_storage/get_storage.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();

  factory ReviewService() {
    return _instance;
  }

  ReviewService._internal();

  final InAppReview _inAppReview = InAppReview.instance;
  final GetStorage _box = GetStorage();

  static const String _reviewCountKey = 'prompt_unlocks_count';
  static const String _lastReviewKey = 'last_review_prompt_id';
  static const int _reviewTriggerCount = 3; // Review ke baad har 3 unlocks

  /// Track prompt unlock aur check karo agar review dikhana chahiye
  Future<void> trackPromptUnlock(String promptId) async {
    // Count increment karo
    int currentCount = _box.read(_reviewCountKey) ?? 0;
    currentCount++;
    await _box.write(_reviewCountKey, currentCount);

    // Check karo agar review dikhani chahiye
    if (currentCount % _reviewTriggerCount == 0) {
      // Check karo agar same prompt par pehle se review nahi pucha gaya
      final lastReviewId = _box.read(_lastReviewKey) as String?;
      if (lastReviewId != promptId) {
        await Future.delayed(const Duration(milliseconds: 500));
        await requestReview();
        await _box.write(_lastReviewKey, promptId);
      }
    }
  }

  /// In-app review dialog show karo
  Future<void> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    } catch (e) {
      print('Error requesting review: $e');
    }
  }

  /// Manual review request (profile se)
  Future<void> manualRequestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    } catch (e) {
      print('Error requesting review: $e');
    }
  }

  /// Open Play Store page for rating
  Future<void> openPlayStore() async {
    try {
      await _inAppReview.openStoreListing();
    } catch (e) {
      print('Error opening Play Store: $e');
    }
  }

  /// Reset review count (for testing)
  Future<void> resetReviewCount() async {
    await _box.remove(_reviewCountKey);
    await _box.remove(_lastReviewKey);
  }

  /// Get current unlock count
  int getUnlockCount() {
    return _box.read(_reviewCountKey) ?? 0;
  }
}
