import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:promptseen/Admob/Admob_service.dart';
import 'package:promptseen/Admob/app_config.dart';
import 'package:promptseen/comman/purchase/PrivacyScreen.dart';
import 'package:promptseen/comman/purchase/TermsScreen.dart';
import 'package:promptseen/comman/serviceapp/PrimiumService.dart';

class promptseenPremium extends StatefulWidget {
  final bool home;
  promptseenPremium({super.key, this.home = false});

  @override
  State<promptseenPremium> createState() => _promptseenPremiumState();
}

class _promptseenPremiumState extends State<promptseenPremium> {
  bool _isLoading = false;
  bool _isRestoring = false;
  List<StoreProduct> _products = [];
  bool _isLoadingProducts = true;
  String? _selectedProductId;
  bool _isPremiumUser = false;
  bool _isCheckingPremiumStatus = true;
  String? _activeSubscriptionId;
  bool _showCloseIcon = false;


  // ---- Paywall palette (like screenshot) ----
  static const Color _bgTop = Color(0xFF07081A);
  static const Color _bgMid = Color(0xFF0D0F2C);
  static const Color _bgBottom = Color(0xFF050511);

  static const Color _accentA = Color(0xFF7C3AED); // purple
  static const Color _accentB = Color(0xFF22D3EE); // cyan
  static const Color _accentPink = Color(0xFFEC4899);
  static const Color _textMuted = Color(0xFF9AA4B2);
  static const Color _stroke = Color(0xFF2A2E45);

  // RevenueCat product ids (change to your transcription product ids)
  static const String _weeklyId = "monthly_primium_plan";
  static const String _monthlyId = "yearly_premium_plan";

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    _loadProducts();

    if (widget.home) {
      _showCloseIcon = false; // pehle hide
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showCloseIcon = true);
        }
      });
    } else {
      _showCloseIcon = true; // instantly show
    }
  }

  // ---------------- RevenueCat ----------------
  Future<void> _checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final hasActive = customerInfo.entitlements.all.values.any((e) => e.isActive);

      String? activeProductId;
      if (hasActive) {

        print("active sssssss");
        for (final ent in customerInfo.entitlements.all.values) {
          if (ent.isActive) {
            activeProductId = ent.productIdentifier;
            break;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        print("active sssssss");
        _isPremiumUser = hasActive;
        _activeSubscriptionId = activeProductId;
        _isCheckingPremiumStatus = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPremiumUser = false;
        _isCheckingPremiumStatus = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final productList = await Purchases.getProducts([_weeklyId, _monthlyId]);

      if (!mounted) return;
      setState(() {
        _products = productList;
        _isLoadingProducts = false;

        if (_products.isNotEmpty) {
          _selectedProductId = _products.firstWhere(
                (p) => p.identifier == _monthlyId,
            orElse: () => _products.first,
          ).identifier;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _restorePurchases() async {
    if (_isRestoring) return;

    setState(() => _isRestoring = true);

    try {
      final customerInfo = await Purchases.restorePurchases();
      final hasActiveSubscription = customerInfo.activeSubscriptions.isNotEmpty;

      if (!mounted) return;

      if (hasActiveSubscription) {
        setState(() {
          _isPremiumUser = true;
          _activeSubscriptionId =
          customerInfo.activeSubscriptions.isNotEmpty ? customerInfo.activeSubscriptions.first : null;
        });
        _showSuccessDialog(
          'Restore Successful',
          'Your subscription has been restored successfully!',
          shouldClose: true,
        );
      } else {
        final hasPurchasedAny = customerInfo.allPurchasedProductIdentifiers.isNotEmpty;
        if (hasPurchasedAny) {
          setState(() {
            _isPremiumUser = true;
            _activeSubscriptionId = customerInfo.allPurchasedProductIdentifiers.first;
          });
          _showSuccessDialog(
            'Restore Successful',
            'Your subscription has been restored successfully!',
            shouldClose: true,
          );
        } else {
          _showErrorDialog('No Purchases Found', 'No active subscriptions were found to restore.');
        }
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Restore Failed', 'Unable to restore purchases. Please try again.');
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _purchaseProduct(StoreProduct product) async {
    if (_activeSubscriptionId == product.identifier) {
      _showAlreadySubscribedDialog(product.title);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final customerInfo = await Purchases.purchaseStoreProduct(product);
      debugPrint("Purchase successful: $customerInfo");
      // PremiumService.activatePremium();
      await SubscriptionService.checkPremiumStatus();
      AppConfig.IsPrimiumUser = true;

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: _bgBottom,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Purchase Failed',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: const Text('Unable to complete purchase. Please try again.',
              style: TextStyle(color: _textMuted)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: _accentA, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------- Dialogs ----------------
  void _showSuccessDialog(String title, String message, {bool shouldClose = false}) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _bgBottom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(message, style: const TextStyle(color: _textMuted)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (shouldClose && mounted) {
                Future.delayed(const Duration(milliseconds: 150), () {
                  if (mounted) Navigator.pop(context, true);
                });
              }
            },
            child: const Text('OK', style: TextStyle(color: _accentA, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _bgBottom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text(message, style: const TextStyle(color: _textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK', style: TextStyle(color: _accentA, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showAlreadySubscribedDialog(String productName) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _bgBottom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Already Subscribed',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text("You're already subscribed to\n$productName",
            textAlign: TextAlign.center, style: const TextStyle(color: _textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK', style: TextStyle(color: _accentA, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ---------------- UI helpers ----------------
  LinearGradient get _ctaGradient => const LinearGradient(
    colors: [_accentA, _accentPink],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  LinearGradient get _bestValueGradient => const LinearGradient(
    colors: [_accentA, _accentB],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  bool _isYearlyLike(StoreProduct p) {
    // In your old code, "monthlys" was treated as special. Here we show it like screenshot "Yearly Plan".
    return p.identifier.contains('monthlys') || p.identifier == _monthlyId;
  }

  String _billingSuffix(StoreProduct p) => _isYearlyLike(p) ? '/year' : '/mo';

  BoxDecoration _glassCard({required bool selected}) => BoxDecoration(
    borderRadius: BorderRadius.circular(26),
    gradient: LinearGradient(
      colors: [
        const Color(0xFF171A33).withOpacity(0.85),
        const Color(0xFF0F1228).withOpacity(0.85),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(color: selected ? _accentA : _stroke, width: selected ? 2.2 : 1.4),
    boxShadow: [
      if (selected)
        BoxShadow(
          color: _accentA.withOpacity(0.35),
          blurRadius: 26,
          spreadRadius: 2,
        ),
    ],
  );

  Widget _pill({required String text, required Gradient gradient}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _featureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [_accentA.withOpacity(0.95), _accentB.withOpacity(0.95)]),
            ),
            child: const Icon(Icons.check, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _planCard(StoreProduct product) {
    final bool selected = _selectedProductId == product.identifier;
    final bool bestValue = _isYearlyLike(product);

    // Show price like "$30" + "/year" (suffix separated)
    final String price = product.priceString;

    return GestureDetector(
      onTap: () => setState(() => _selectedProductId = product.identifier),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(18),
            decoration: _glassCard(selected: selected),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bestValue ? 'Yearly Plan' : 'Monthly Plan',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        bestValue ? 'Auto-renews yearly' : 'Auto-renews monthly',
                        style: const TextStyle(color: _textMuted, fontSize: 12.5, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: price,
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                          ),
                          TextSpan(
                            text: ' ${_billingSuffix(product)}',
                            style: const TextStyle(color: _textMuted, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (bestValue)
                      Text(
                        'SAVE 80%',
                        style: TextStyle(color: _accentB.withOpacity(0.95), fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (bestValue)
            Positioned(
              top: 0,
              right: 14,
              child: _pill(text: 'BEST VALUE', gradient: _bestValueGradient),
            ),
        ],
      ),
    );
  }

  // ---------------- Footer links ----------------
  Widget _footerLinks() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Get.to(() => Termsscreen()),
              child: const Text('Terms of Service',
                  style: TextStyle(color: _textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            const Text('  •  ', style: TextStyle(color: _textMuted)),
            GestureDetector(
              onTap: () => Get.to(() => PrivacyScreen()),
              child: const Text('Privacy Policy',
                  style: TextStyle(color: _textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Payment will be charged to your account at confirmation. Subscription automatically renews unless auto-renew is turned off at least 24-hours before the end of the current period.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, height: 1.35),
          ),
        ),
      ],
    );
  }

  // ---------------- Premium screen shown after purchase ----------------
  Widget _premiumActiveUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _bestValueGradient,
                boxShadow: [BoxShadow(color: _accentA.withOpacity(0.45), blurRadius: 34, spreadRadius: 4)],
              ),
              child: const Icon(Icons.verified, size: 64, color: Colors.white),
            ),
            const SizedBox(height: 18),
            const Text("You're Premium!",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text(
              'Unlimited transcription and pro tools are active.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 14.5, height: 1.35),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: _ctaGradient, borderRadius: BorderRadius.circular(28)),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Main build ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgBottom,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgMid, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Soft glow
              Positioned(
                left: -80,
                top: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_accentA.withOpacity(0.35), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -90,
                bottom: 40,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_accentB.withOpacity(0.22), Colors.transparent],
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  // Top bar: Close + Restore (like screenshot)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Material(
                              color: Colors.white.withOpacity(0.06),
                              child: InkWell(
                                onTap: _showCloseIcon
                                    ? () {
                                  if (widget.home) {
                                    // Get.offAll(() => MainAppScreen()); // 🔥 home screen
                                  } else {
                                    Navigator.pop(context);
                                  }
                                }
                                    : null,

                                child: !_showCloseIcon  ?  SizedBox.shrink(): const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(Icons.close, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Material(
                              color: Colors.white.withOpacity(0.06),
                              child: InkWell(
                                onTap: _isRestoring ? null : _restorePurchases,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_isRestoring)
                                        const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(_accentB)),
                                        ),
                                      if (_isRestoring) const SizedBox(width: 8),
                                      const Text(
                                        'Restore',
                                        style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: (_isCheckingPremiumStatus || _isLoadingProducts)
                        ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(_accentA),
                        strokeWidth: 3,
                      ),
                    )
                        : _isPremiumUser
                        ? _premiumActiveUI()
                        : _products.isEmpty
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Products Under Review',
                                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 10),
                            const Text(
                              'Your subscription products are not available right now.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: _textMuted),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton(
                              onPressed: _loadProducts,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentA,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Check Again', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                      ),
                    )
                        : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                      child: Column(
                        children: [
                          // Center app icon bubble
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.03),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                              boxShadow: [
                                BoxShadow(color: _accentA.withOpacity(0.25), blurRadius: 40, spreadRadius: 2),
                              ],
                            ),
                            child: const Icon(Icons.diamond_outlined, color: Colors.white, size: 38),
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            'Unlock Pro Access',
                            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Supercharge your workflow with our\nadvanced AI tools',
                            style: TextStyle(color: _textMuted, fontSize: 14.5, height: 1.35),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),

                          // Plans
                          ..._products.map(_planCard).toList(),
                          const SizedBox(height: 10),

                          // Features (video transcription)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'PREMIUM FEATURES',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _featureRow('Unlimited Transcriptions'),
                          _featureRow('Advanced AI Mind Maps'),
                          _featureRow('Ad-free Experience'),
                          _featureRow('Priority 24/7 AI Support'),
                          const SizedBox(height: 18),

                          // CTA button
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: _ctaGradient,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(color: _accentPink.withOpacity(0.25), blurRadius: 26, offset: const Offset(0, 10)),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading || _selectedProductId == null
                                    ? null
                                    : () {
                                  final selected = _products.firstWhere((p) => p.identifier == _selectedProductId);
                                  _purchaseProduct(selected);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.6,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                                    : const Text(
                                  'Start Free Trial',
                                  style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _footerLinks(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
