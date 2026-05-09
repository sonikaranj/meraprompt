import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle in-app rating functionality with one-time rating logic
class RatingService {
 static final InAppReview _inAppReview = InAppReview.instance;

  // Keys for SharedPreferences
  static const String _hasRatedKey = 'has_rated_app';
  static const String _lastPromptDateKey = 'last_rating_prompt_date';
  static const String _appLaunchCountKey = 'app_launch_count';

  /// Check if user has already rated the app
  Future<bool> hasUserRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasRatedKey) ?? false;
  }

  /// Mark that user has rated the app
static  Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
  }

  /// Increment app launch count
  Future<int> incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    int count = (prefs.getInt(_appLaunchCountKey) ?? 0) + 1;
    await prefs.setInt(_appLaunchCountKey, count);
    return count;
  }

  /// Get app launch count
  Future<int> getLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_appLaunchCountKey) ?? 0;
  }

  /// Save last prompt date
  Future<void> saveLastPromptDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPromptDateKey, DateTime.now().toIso8601String());
  }

  /// Check if enough time has passed since last prompt (7 days default)
  Future<bool> canPromptAgain({int daysBetweenPrompts = 7}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastPromptStr = prefs.getString(_lastPromptDateKey);

    if (lastPromptStr == null) return true;

    final lastPrompt = DateTime.parse(lastPromptStr);
    final difference = DateTime.now().difference(lastPrompt).inDays;

    return difference >= daysBetweenPrompts;
  }

  /// Smart rating request - only shows if conditions are met
  /// Returns true if review was requested, false otherwise
  Future<bool> smartRequestReview({
    int minLaunchCount = 5,
    int daysBetweenPrompts = 7,
  }) async {
    try {
      // Check if user has already rated
      if (await hasUserRated()) {
        print('User has already rated the app');
        return false;
      }

      // Check if enough launches
      final launchCount = await getLaunchCount();
      if (launchCount < minLaunchCount) {
        print('Not enough launches: $launchCount/$minLaunchCount');
        return false;
      }

      // Check if enough time has passed since last prompt
      if (!await canPromptAgain(daysBetweenPrompts: daysBetweenPrompts)) {
        print('Not enough time passed since last prompt');
        return false;
      }

      // Check if in-app review is available
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await saveLastPromptDate();
        // Mark as rated after showing prompt
        await markAsRated();
        return true;
      }

      return false;
    } catch (e) {
      print('Error requesting review: $e');
      return false;
    }
  }

  /// Request in-app review (basic version without checks)
 static Future<bool> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await markAsRated();
        return true;
      }
      return false;
    } catch (e) {
      print('Error requesting review: $e');
      return false;
    }
  }

  /// Open store listing page for manual review
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '6747648125',
      );
      await markAsRated();
    } catch (e) {
      print('Error opening store listing: $e');
    }
  }

  /// Reset rating status (for testing only)
  Future<void> resetRatingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasRatedKey);
    await prefs.remove(_lastPromptDateKey);
    await prefs.remove(_appLaunchCountKey);
  }
}

// Example usage in main.dart:
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ratingService = RatingService();

  // Increment launch count on app start
  await ratingService.incrementLaunchCount();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final RatingService _ratingService = RatingService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RatingService _ratingService = RatingService();

  @override
  void initState() {
    super.initState();
    _checkAndRequestRating();
  }

  Future<void> _checkAndRequestRating() async {
    // Wait a bit after app launch, then check
    await Future.delayed(Duration(seconds: 2));

    // Smart request - will only show after 5 launches and if not rated
    await _ratingService.smartRequestReview(
      minLaunchCount: 5,
      daysBetweenPrompts: 7,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Manual rating button
                bool hasRated = await _ratingService.hasUserRated();
                if (hasRated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You have already rated us! Thank you!')),
                  );
                } else {
                  bool shown = await _ratingService.requestReview();
                  if (!shown) {
                    await _ratingService.openStoreListing();
                  }
                }
              },
              child: Text('Rate Us'),
            ),
            SizedBox(height: 20),
            // For testing only - remove in production
            ElevatedButton(
              onPressed: () async {
                await _ratingService.resetRatingStatus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Rating status reset!')),
                );
              },
              child: Text('Reset (Testing Only)'),
            ),
          ],
        ),
      ),
    );
  }
}
*/