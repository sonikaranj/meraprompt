import 'package:promptseen/Admob/app_config.dart';
import 'package:promptseen/const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Termsscreen extends StatefulWidget {
  const Termsscreen({Key? key}) : super(key: key);

  @override
  State<Termsscreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<Termsscreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String privacyPolicyUrl = '';

  @override
  void initState() {
    super.initState();
    privacyPolicyUrl = AppConfig.termsAndConditionsUrl;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                isLoading = true;
                hasError = false;
              });
            }
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                isLoading = false;
                hasError = true;
                errorMessage = error.description;
              });
            }
            debugPrint('WebView error: ${error.description}');
          },
        ),
      );
    _loadPrivacyPolicy();
  }

  void _loadPrivacyPolicy() {
    controller.loadRequest(Uri.parse(privacyPolicyUrl));
  }

  // Launch URL in external browser
  Future<void> _launchUrlInBrowser() async {
    try {
      final Uri uri = Uri.parse(privacyPolicyUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        // Go back after launching URL
        Get.back();
      } else {
        _showErrorMessage('Cannot launch URL in browser');
      }
    } catch (e) {
      _showErrorMessage('Error launching URL: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
        ),
        backgroundColor: AppColor.black,
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          if (!hasError && !isLoading)
            WebViewWidget(controller: controller),
          if (hasError)
            _buildErrorWidget(),
          if (isLoading)
            _buildLoadingWidget(),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Loading Privacy Policy...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'SSL Certificate Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Cannot load privacy policy in WebView due to SSL certificate issues.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                  ),
                  child: const Text('Go Back'),
                ),
                ElevatedButton(
                  onPressed: _launchUrlInBrowser,
                  child: const Text('Open in Browser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
