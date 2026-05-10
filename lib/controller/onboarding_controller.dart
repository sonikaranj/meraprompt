import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  late PageController pageController;
  RxInt currentPage = 0.obs;

  late List<OnboardingPage> pages;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _initializePages();
  }

  void _initializePages() {
    pages = [
      OnboardingPage(
        title: 'Welcome to',
        titleHighlight: 'PromptSeen',
        description:
        'Transform your ideas into stunning visuals with AI-powered creativity. Create, explore, and share amazing content effortlessly.',
        images: [
          'https://cdn.bananaprompts.xyz/e6c0a513-c6ad-4edf-8b11-a4abf17dea9e/58fc38e1-69e3-452e-9624-2e64a60bda12.png?w=828&q=75',
          'https://cdn.bananaprompts.xyz/ae5f8289-1a58-4605-8d97-0ffa38b6a5cf/76bcf139-247c-40a9-adf1-a450be31a762.jpeg?w=828&q=75',
        ],
      ),
      OnboardingPage(
        title: 'Create',
        titleHighlight: 'Amazing Visuals',
        description:
        'Use advanced AI models to generate, edit, and transform images. From concepts to creations in seconds.',
        images: [
          'https://promptmera.com/applicationv1/1.png',
        ],
      ),
      OnboardingPage(
        title: 'Explore',
        titleHighlight: 'Infinite Styles',
        description:
        'Choose from cinematic, anime, realistic, and more. Each style brings unique magic to your creations.',
        images: [
          'https://promptmera.com/applicationv1/2.png',
          'https://promptmera.com/applicationv1/3.png',
          'https://promptmera.com/applicationv1/4.png',
          'https://promptmera.com/applicationv1/5.png',
          'https://promptmera.com/applicationv1/6.png',
          'https://promptmera.com/applicationv1/7.png',
        ],
      ),
    ];
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      skipOnboarding();
    }
  }

  void skipOnboarding() {
    // Navigate to home screen
    Get.offNamed('/home');
    // Or you can use: Get.off(() => const HomeScreen());
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class OnboardingPage {
  final String title;
  final String titleHighlight;
  final String description;
  final List<String> images;

  OnboardingPage({
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.images,
  });
}