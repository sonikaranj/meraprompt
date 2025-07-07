import 'package:aiimagegenerator2/screen/homescreeen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() => isLastPage = index == 2);
              },
              children: const [
                OnboardPage(
                  image: 'asset/slider1.webp',
                  title: 'Generate AI Headshots',
                  description:
                  'Transform your selfies into professional headshots using powerful AI.',
                ),
                OnboardPage(
                  image: 'asset/slider2.webp',
                  title: 'Perfect for LinkedIn & Resumes',
                  description:
                  'Stand out with high-quality images ideal for job profiles and networking.',
                ),
                OnboardPage(
                  image: 'asset/slider3.webp',
                  title: 'No Account Needed',
                  description:
                  'Just upload your photo, choose style, and get your headshot. Simple & secure!',
                ),
              ],
            ),

            // Skip Button
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => _controller.jumpToPage(2),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ),

            // Indicator + Next/Done Button
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white24,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (isLastPage) {
                        // Navigate to main screen
                      Get.offAll(() => Homescreeen());
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      }
                    },
                    child: Text(isLastPage ? 'Get Started' : 'Next'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String image, title, description;

  const OnboardPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 60),
          ClipRRect(
              borderRadius: BorderRadius.circular(10),child: Image.asset(image, height: 300)),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
