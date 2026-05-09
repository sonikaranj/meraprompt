
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  // Check premium status and update AppLovinService
  static Future<void> checkPremiumStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      bool hasActiveSubscription = customerInfo.entitlements.all.values
          .any((entitlement) => entitlement.isActive);
      if (hasActiveSubscription) {
        for (var entitlement in customerInfo.entitlements.all.values) {
          if (entitlement.isActive) {
            break;
          }
        }
      }
      // Save to AppLovin service
      // AppLovinService.isPrimiumUser = hasActiveSubscription;

    } catch (e) {
      // AppLovinService.isPrimiumUser = false;
    }
  }

}
