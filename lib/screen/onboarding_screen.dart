import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:promptseen/controller/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF221610),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF221610),
              const Color(0xFF2a1f1a).withOpacity(0.8),
              const Color(0xFF221610),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background glow effects
            Positioned(
              top: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFec5b13).withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFec5b13).withOpacity(0.1),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFec5b13).withOpacity(0.05),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFec5b13).withOpacity(0.05),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: controller.skipOnboarding,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: const Color(0xFFec5b13),
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PageView with onboarding screens
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: (index) {
                        controller.currentPage.value = index;
                      },
                      itemCount: controller.pages.length,
                      itemBuilder: (context, index) {
                        return OnboardingPageWidget(
                          page: controller.pages[index],
                          index: index,
                        );
                      },
                    ),
                  ),

                  // Bottom section with indicators and button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 32.h,
                    ),
                    child: Column(
                      children: [
                        // Page indicators
                        Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.pages.length,
                                (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: controller.currentPage.value == index ? 24.w : 8.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.r),
                                color: controller.currentPage.value == index
                                    ? const Color(0xFFec5b13)
                                    : const Color(0xFFec5b13).withOpacity(0.3),
                                boxShadow: controller.currentPage.value == index
                                    ? [
                                  BoxShadow(
                                    color: const Color(0xFFec5b13).withOpacity(0.6),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                                    : [],
                              ),
                            ),
                          ),
                        )),
                        SizedBox(height: 32.h),

                        // Next/Get Started Button
                        GestureDetector(
                          onTap: controller.nextPage,
                          child: Container(
                            width: double.infinity,
                            height: 56.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              gradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFFec5b13),
                                  Color(0xFFff8c52),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFec5b13).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() => Text(
                                  controller.currentPage.value ==
                                      controller.pages.length - 1
                                      ? 'Get Started'
                                      : 'Next Step',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                )),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;
  final int index;

  const OnboardingPageWidget({
    Key? key,
    required this.page,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image section with cards layout
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
              child: _buildImageSection(index),
            ),
          ),
        ),

        // Text content section
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title with highlight
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: page.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (page.title.isNotEmpty)
                        TextSpan(
                          text: ' ',
                          style: TextStyle(fontSize: 32.sp),
                        ),
                      TextSpan(
                        text: page.titleHighlight,
                        style: TextStyle(
                          color: const Color(0xFFec5b13),
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                // Description
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(int index) {
    if (index == 0) {
      return _buildPage1Layout();
    } else if (index == 1) {
      return _buildPage2Layout();
    } else {
      return _buildPage3Layout();
    }
  }

  // Page 1: Rotating cards layout with actual images
  Widget _buildPage1Layout() {
    return Transform.rotate(
      angle: -0.1,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, 30),
                  child: _buildImageCard(
                    imageUrl: page.images.isNotEmpty ? page.images[0] : '',
                    width: 130.w,
                    height: 180.h,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: _buildImageCard(
                    imageUrl: page.images.length > 1 ? page.images[1] : '',
                    width: 130.w,
                    height: 180.h,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, 20),
                  child: _buildImageCard(
                    imageUrl: page.images.length > 2 ? page.images[2] : '',
                    width: 130.w,
                    height: 180.h,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: _buildImageCard(
                    imageUrl: page.images.length > 3 ? page.images[3] : '',
                    width: 130.w,
                    height: 180.h,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Page 2: Single large card with overlay
  Widget _buildPage2Layout() {
    return Center(
      child: Container(
        width: 240.w,
        height: 320.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFec5b13).withOpacity(0.3),
            width: 1.5,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFec5b13).withOpacity(0.1),
              const Color(0xFF221610),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFec5b13).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Image from URL
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
               '${page.images[0]}',
                fit: BoxFit.cover,
                width: 240.w,
                height: 320.h,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFec5b13).withOpacity(0.15),
                          const Color(0xFF1a110d),
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 60.sp,
                      color: const Color(0xFFec5b13).withOpacity(0.5),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFec5b13).withOpacity(0.15),
                          const Color(0xFF1a110d),
                        ],
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFFec5b13),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Overlay gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 120.h,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),

            // Style badges
            Positioned(
              top: 12.h,
              left: 12.w,
              child: _buildStyleBadge('Cinematic'),
            ),
            Positioned(
              bottom: 12.h,
              right: 12.w,
              child: _buildStyleBadge('Anime v3'),
            ),
          ],
        ),
      ),
    );
  }

  // Page 3: Grid layout with transformation
  Widget _buildPage3Layout() {
    return Column(
      children: [
        // Original photo (larger)
        Container(
          width: double.infinity,
          height: 160.h,
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFec5b13).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Original image
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCUKp_atf__VK7iWK-WVYVFyL_JOWV3qVREdGbolzS96C5IF-D_nFUrGtgCWUzqAhV63u7nLXDv0DJ_3OsnIacidUbkbKPfuQhCYSr-diOi4TEUmH4-lI4LuhZD35LgQp9n0H-QUnJ4RC9h2k7jRdLQ6oswmIfMaoPOGzxWbNXjlazZEOzaBPqwvqLhNeAXiNpZNobIcmE9JNbtPtZ-atmz42TDpLrBvtNcekg-yGesUgPIO52oJg3Jy7rt0Oen1icB-CnhWJ0Nf-xv',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 160.h,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFec5b13).withOpacity(0.1),
                            const Color(0xFF1a110d),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 40.sp,
                        color: const Color(0xFFec5b13).withOpacity(0.5),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFec5b13).withOpacity(0.1),
                            const Color(0xFF1a110d),
                          ],
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFFec5b13),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),

                // Overlay gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80.h,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),

                // Original Photo Label
                Positioned(
                  bottom: 8.h,
                  left: 8.w,
                  child: Row(
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Original Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Style grid
        Row(
          children: [
            Expanded(
              child: _buildStyleCardWithImage(
                'Cinematic',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDpG1U4714Ft20CoN3I3IuB073pWmsoA7j2y-hxTofnEnxNpCyQVM5fKKzsGHJ_sUMqpfm-AJi3GduACQwiEFB3nk-nZFWX9httqzE6_FS5asYtgMAlxUutlPeBI5a_Va6SlkRbGIHwkX9e8dxRbVRdxWfgva_f_m6Jji4PogrwZ2K5WYZd-HQwSe3d5uhuMAQpm-HIamiZNyIOUEqkP8KYD6FH5SffX2wZKyIypDNNzVOTItq-DyL0EvnjivFHYuKv-TANPfpbN6na',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildStyleCardWithImage(
                'Anime',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAQBRts-dRmyq3A8KdnRO5vNG_SuIKSHProRGYDWWbdF-22C1yOpYA2Gv2pNylvMfCP8zs9duKMFmVxWwv-Om7JyBbs5PAQGOsUmrcDHD_b9EApniEQShD9kJgJbU_Yec7uKFWSc5oa79_dTLQrB6IB9Ubj1vuDH-iNUmm8lHJQmOWBzqmK0da7DMLnVPjM_IpPgkF2buz-JNedV65GMUVzdIzvuEIj7bhHbeVcqmZjhwnZ_NKXOjRnwl8mKk8d9GYk-undf3LiPwqw',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStyleCardWithImage(String style, String imageUrl) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFec5b13).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Style image
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 160.h,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFec5b13).withOpacity(0.1),
                        const Color(0xFF1a110d),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    size: 40.sp,
                    color: const Color(0xFFec5b13).withOpacity(0.5),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFec5b13).withOpacity(0.1),
                        const Color(0xFF1a110d),
                      ],
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFec5b13),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),

            // Overlay gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),

            // Style name label
            Positioned(
              bottom: 8.h,
              left: 8.w,
              child: Text(
                style,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // AI Badge
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFec5b13),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 10.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard({
    required String imageUrl,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFec5b13).withOpacity(0.08),
            const Color(0xFFec5b13).withOpacity(0.02),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFec5b13).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Image
            imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: width,
              height: height,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF1a110d),
                  child: Icon(
                    Icons.image_not_supported,
                    color: const Color(0xFFec5b13).withOpacity(0.5),
                    size: 30.sp,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFF1a110d),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: const Color(0xFFec5b13),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            )
                : Container(
              color: const Color(0xFF1a110d),
              child: Icon(
                Icons.image_outlined,
                color: const Color(0xFFec5b13).withOpacity(0.5),
                size: 30.sp,
              ),
            ),

            // Overlay gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60.h,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),

            // Skeleton lines
            Positioned(
              bottom: 8.h,
              left: 8.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 3.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.r),
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    height: 2.h,
                    width: 30.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.r),
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFec5b13).withOpacity(0.08),
            const Color(0xFFec5b13).withOpacity(0.02),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFec5b13).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Placeholder content
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFec5b13).withOpacity(0.1),
                  const Color(0xFF1a110d),
                ],
              ),
            ),
            margin: EdgeInsets.all(4.w),
          ),

          // Skeleton lines
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 3.h,
                width: 40.w,
                margin: EdgeInsets.only(
                  left: 8.w,
                  bottom: 6.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.r),
                  color: const Color(0xFFec5b13).withOpacity(0.4),
                ),
              ),
              Container(
                height: 2.h,
                width: 30.w,
                margin: EdgeInsets.only(
                  left: 8.w,
                  bottom: 8.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.r),
                  color: const Color(0xFFec5b13).withOpacity(0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyleBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.r),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        // backdropFilter: const BoxFilter(),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStyleCard(String style) {
    return Container(
      height: 160.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFec5b13).withOpacity(0.3),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFec5b13).withOpacity(0.1),
            const Color(0xFF1a110d),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 40.sp,
            color: const Color(0xFFec5b13).withOpacity(0.5),
          ),
          Positioned(
            bottom: 8.h,
            left: 8.w,
            child: Text(
              style,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFec5b13),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 10.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}