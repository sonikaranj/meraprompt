import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIConsentService extends GetxService {
  static const String _consentKey = "ai_processing_consent";

  static AIConsentService get to => Get.find();

  final RxBool hasConsent = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    final prefs = await SharedPreferences.getInstance();
    hasConsent.value = prefs.getBool(_consentKey) ?? false;
  }

  Future<void> saveConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
    hasConsent.value = true;
  }

  Future<bool> showConsentIfNeeded() async {
    if (hasConsent.value) return true;

    bool? result = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(
                  Icons.privacy_tip_outlined,
                  color: Colors.white,
                  size: 40,
                ),

                const SizedBox(height: 16),

                const Text(
                  "AI Data Processing Consent",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "To provide AI-powered transcript, summarization, and chat features, "
                      "the following data will be securely sent to OpenAI API:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 16),

                _buildFeatureRow(
                  Icons.link,
                  "YouTube video transcript text",
                ),
                const SizedBox(height: 8),

                _buildFeatureRow(
                  Icons.description,
                  "Uploaded document text (PDF, DOC, PPT, images)",
                ),
                const SizedBox(height: 8),

                _buildFeatureRow(
                  Icons.chat,
                  "Your AI chat questions and prompts",
                ),

                const SizedBox(height: 16),

                const Text(
                  "This data is used only to generate AI responses. "
                      "We do not store or sell your personal data.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 12),


                const Text(
                  "By tapping Continue, you consent to sending this data to OpenAI for AI processing.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                        ),
                        onPressed: () => Get.back(result: false),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E54E9),
                        ),
                        onPressed: () => Get.back(result: true),
                        child: const Text("Continue"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    if (result == true) {
      await saveConsent();
      return true;
    }

    return false;
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8E54E9), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
