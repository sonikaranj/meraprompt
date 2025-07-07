import 'dart:io';
import 'package:in_app_review/in_app_review.dart';

class RatingService {
  static final InAppReview _inAppReview = InAppReview.instance;

  // Replace with your real App Store ID (from App Store Connect)
  static const String _appStoreId = '6747648125';

  static Future<void> rateApp() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();

      if (isAvailable && !Platform.isAndroid) {
        // Android in-app rating only works from Play Store builds, not local installs
        await _inAppReview.requestReview();
      } else {
        // Fallback: open store listing
        await _inAppReview.openStoreListing(
          appStoreId: _appStoreId, // Required for iOS
        );
      }
    } catch (e) {
      print('Rating Error: $e');
    }
  }
}
