import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatelessWidget {
  final NativeAd nativeAd;

  const NativeAdWidget({
    Key? key,
    required this.nativeAd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AdWidget(ad: nativeAd),
      width: double.infinity,
      height: 320,
    );
  }
}
