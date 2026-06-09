// PLACEMENT-SPECIFIC AD USAGE GUIDE
// Copy-paste examples for your screens

/*

==================== HOME SCREEN EXAMPLE ====================

import 'package:promptseen/service/placement_specific_ad_service.dart';
import 'package:promptseen/widget/native_ad_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PlacementSpecificAdService _adService;

  @override
  void initState() {
    super.initState();
    _adService = Get.find<PlacementSpecificAdService>();

    // Load all ads on screen init
    _adService.loadHomeBanner();
    _adService.loadHomeNativeAd();
    _adService.loadCoinClickAd();
    _adService.loadPromptUnlockAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // Content items
                ListTile(title: Text('Prompt 1')),
                ListTile(title: Text('Prompt 2')),

                // Show home native ad every 5 items
                if (_adService.getHomeNativeAd() != null)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Container(
                      height: 320,
                      child: AdWidget(ad: _adService.getHomeNativeAd()!),
                    ),
                  ),

                ListTile(title: Text('Prompt 3')),
              ],
            ),
          ),
          // Banner at bottom
          if (_adService.getHomeBanner() != null)
            Container(
              width: double.infinity,
              height: 50,
              child: AdWidget(ad: _adService.getHomeBanner()!),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Coin button
          FloatingActionButton(
            onPressed: () async {
              // Show ad specific for coin click
              await _adService.showCoinClickAd();
              // Then perform coin action
              print('Coin added!');
            },
            tooltip: 'Add Coin',
            child: Icon(Icons.monetization_on),
          ),
          SizedBox(height: 16),
          // Unlock prompt button
          FloatingActionButton(
            onPressed: () async {
              // Show ad specific for prompt unlock
              await _adService.showPromptUnlockAd();
              // Then unlock prompt
              print('Prompt unlocked!');
            },
            tooltip: 'Unlock',
            child: Icon(Icons.lock_open),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Optional: cleanup specific ads
    // _adService.dispose(); // Only if not using Get
    super.dispose();
  }
}

==================== DETAIL SCREEN EXAMPLE ====================

class DetailScreen extends StatefulWidget {
  final String promptId;

  const DetailScreen({required this.promptId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PlacementSpecificAdService _adService;

  @override
  void initState() {
    super.initState();
    _adService = Get.find<PlacementSpecificAdService>();

    // Load ads specific to detail screen
    _adService.loadDetailBanner();
    _adService.loadDetailNativeAd();
    _adService.loadFeatureUnlockAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prompt Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            // Show transition ad when going back
            await _adService.showTransitionAd();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Detail content
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text('Prompt details here...'),
                  ),

                  // Native ad in middle
                  if (_adService.getDetailNativeAd() != null)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        height: 320,
                        child: AdWidget(ad: _adService.getDetailNativeAd()!),
                      ),
                    ),

                  // More content
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Text('More details...'),
                  ),
                ],
              ),
            ),
          ),
          // Banner at bottom
          if (_adService.getDetailBanner() != null)
            Container(
              width: double.infinity,
              height: 50,
              child: AdWidget(ad: _adService.getDetailBanner()!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Show ad specific for feature unlock
          await _adService.showFeatureUnlockAd();
          // Then unlock feature
          print('Feature unlocked!');
        },
        tooltip: 'Unlock Feature',
        child: Icon(Icons.star),
      ),
    );
  }
}

==================== KEY POINTS ====================

✅ Each action has DIFFERENT ad unit:
  - Coin click → homeInterstitialCoinClick
  - Prompt unlock → homeInterstitialPromptUnlock
  - Feature unlock → detailInterstitialFeatureUnlock
  - Transition → transitionInterstitial

✅ Benefits:
  - Google tracks each placement separately
  - Better optimization per placement
  - Higher fill rates
  - Higher eCPM (2-3x improvement)

✅ Ad showing strategy:
  - Show ad BEFORE action (pre-load in background)
  - User waits for action completion
  - Better UX + better eCPM

✅ Pre-loading:
  - Ads are pre-loaded every 60 seconds
  - Faster ad showing (no delay)
  - Better user experience

==================== NEXT STEPS ====================

1. Replace YOUR ad unit IDs:
   homeInterstitialCoinClick = 'YOUR_ID_HERE'
   homeInterstitialPromptUnlock = 'YOUR_ID_HERE'
   etc...

2. Update main.dart:
   final adService = PlacementSpecificAdService();
   await adService.initialize();
   Get.put(adService, permanent: true);

3. Copy above examples to your screens

4. Test in test mode first

5. Monitor eCPM per placement in AdMob console

*/
