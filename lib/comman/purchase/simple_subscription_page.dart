// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
//
// class SimpleSubscriptionPage extends StatefulWidget {
//   const SimpleSubscriptionPage({super.key});
//   @override
//   State<SimpleSubscriptionPage> createState() => _SimpleSubscriptionPageState();
// }
//
// class _SimpleSubscriptionPageState extends State<SimpleSubscriptionPage> {
//   final InAppPurchase _iap = InAppPurchase.instance;
//
//   // ✅ Add both product IDs here
//   final Set<String> _productIds = {
//     'ai.imaginexgenerator.com.weekly_offer',
//     'weekly_offer',
//     'monthly_plans'
//   };
//
//   List<ProductDetails> _products = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     debugPrint('🚀 initState called');
//
//     if (Platform.isIOS) {
//       debugPrint('📲 Platform is iOS, registering StoreKit platform');
//       InAppPurchaseStoreKitPlatform.registerPlatform();
//     }
//
//     debugPrint('🔔 Subscribing to purchase stream');
//     _iap.purchaseStream.listen(_handlePurchaseUpdates, onError: (error) {
//       debugPrint('❌ Purchase Stream Error: $error');
//     });
//
//     _loadProducts();
//   }
//
//   Future<void> _loadProducts() async {
//     debugPrint('🛒 Querying product details for: $_productIds');
//     final response = await _iap.queryProductDetails(_productIds);
//
//     if (response.error != null) {
//       debugPrint('❌ Failed to load products: ${response.error!.message}');
//     } else {
//       debugPrint('✅ Products loaded: ${response.productDetails.length}');
//     }
//
//     setState(() {
//       _products = response.productDetails.toList();
//       _isLoading = false;
//     });
//   }
//
//   void _buy(ProductDetails product) {
//     debugPrint('🛍️ Buy button pressed for: ${product.id}');
//
//     final purchaseParam = PurchaseParam(productDetails: product);
//     _iap.buyNonConsumable(purchaseParam: purchaseParam);
//   }
//
//   void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
//     debugPrint('📦 Handling purchase updates: ${purchases.length} item(s)');
//
//     for (final purchase in purchases) {
//       debugPrint('🔄 Purchase status: ${purchase.status} for ${purchase.productID}');
//
//       if (purchase.status == PurchaseStatus.purchased) {
//         debugPrint('🎉 Purchase completed');
//
//         if (purchase is AppStorePurchaseDetails) {
//           final transactionId = purchase.skPaymentTransaction.transactionIdentifier;
//           debugPrint('🧾 iOS Transaction ID: $transactionId');
//         } else if (Platform.isAndroid) {
//           final purchaseToken = purchase.verificationData.serverVerificationData;
//           debugPrint('🔑 Android Purchase Token: $purchaseToken');
//         }
//
//         if (purchase.pendingCompletePurchase) {
//           debugPrint('✅ Completing pending purchase');
//           _iap.completePurchase(purchase);
//         }
//       } else if (purchase.status == PurchaseStatus.error) {
//         debugPrint('❌ Purchase error: ${purchase.error?.message}');
//       } else if (purchase.status == PurchaseStatus.canceled) {
//         debugPrint('⚠️ Purchase was cancelled by user');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Choose Subscription')),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _products.isEmpty
//           ? const Center(child: Text('❌ No products found'))
//           : ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: _products.length,
//         itemBuilder: (context, index) {
//           final product = _products[index];
//           return Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.symmetric(vertical: 10),
//             child: ListTile(
//               title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
//               subtitle: Text(product.description),
//               trailing: Text(product.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               onTap: () => _buy(product),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
