import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promptseen/const.dart';
import 'package:promptseen/service/connectivity_service.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  static const Color _bg = Color(0xFF080C18);
  static const Color _surface = Color(0xFF0F1422);
  static const Color _c1 = Color(0xFF0EA5E9);
  static const Color _c2 = Color(0xFF00BCD4);

  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();

    return Obx(() {
      // If connected, return empty so the main app shows
      if (connectivityService.isConnected.value) {
        return const SizedBox.shrink();
      }

      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with glow
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow background
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _c1.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [_c1, _c2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _c1.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Title
                const Text(
                  'No Internet Connection',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Check your WiFi or mobile data connection and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[400],
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Retry button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_c1, _c2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _c1.withValues(alpha: 0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // Trigger another check
                      connectivityService.onInit();
                    },
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
