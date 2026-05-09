import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:promptseen/controller/detail_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends GetView<DetailController> {
  const DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DetailController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFF221610),
          body: Stack(
            children: [
              // Main content
              CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    backgroundColor: const Color(0xFF221610),
                    elevation: 0,
                    leading: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3a2d26),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    title: Text(
                      'Prompt Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      GestureDetector(
                        onTap: () {
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(100, 50, 0, 0),
                            items: [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.share, color: Colors.white),
                                    SizedBox(width: 12),
                                    Text('Share',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                onTap: () => controller.sharePrompt(),
                              ),
                              // PopupMenuItem(
                              //   child: Row(
                              //     children: [
                              //       Icon(Icons.delete, color: Colors.red),
                              //       SizedBox(width: 12),
                              //       Text('Delete',
                              //           style: TextStyle(color: Colors.red)),
                              //     ],
                              //   ),
                              //   onTap: () {},
                              // ),
                            ],
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3a2d26),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Main Image
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildMainImage(controller),
                    ),
                  ),
                  // Prompt Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPromptCard(controller),
                    ),
                  ),
                  // Action Buttons
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildActionButtons(controller),
                    ),
                  ),
                  // Generate Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildGenerateButtons(controller),
                    ),
                  ),
                  // Related Section
                  // SliverToBoxAdapter(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(20),
                  //     child: _buildRelatedSection(),
                  //   ),
                  // ),
                  // // Bottom padding
                  SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ],
          ),

        );
      },
    );
  }

  Widget _buildMainImage(DetailController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Image
          CachedNetworkImage(
            imageUrl: controller.prompt.imageUrl,
            fit: BoxFit.cover,
            height: 400,
            width: double.infinity,
            placeholder: (context, url) => Container(
              height: 400,
              color: const Color(0xFF3a2d26),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFec5b13),
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 400,
              color: const Color(0xFF3a2d26),
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey[600],
                size: 50,
              ),
            ),
          ),
          // Top-left share button
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => controller.sharePrompt(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3a2d26),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          // Top-right favorite button
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () => controller.toggleFavorite(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3a2d26),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  controller.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: controller.isFavorite ? Colors.red : Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard(DetailController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3a2d26),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            'PROMPT STRING',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: const Color(0xFFec5b13),
            ),
          ),
          SizedBox(height: 10),
          // Prompt text
          Text(
            controller.prompt.promptText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DetailController controller) {
    return Row(
      children: [
        _buildActionButton(
          icon: Icons.content_copy,
          label: 'Copy',
          onTap: () => controller.copyPrompt(),
        ),


      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF3a2d26),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: const Color(0xFFec5b13),
                size: 18,
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButtons(DetailController controller) {
    final promptText = controller.prompt.promptText.trim();

    return Column(
      children: [
        _buildGenerateButtonTile(
          label: 'Generate with Gemini',
          icon: Icons.auto_awesome,
          onTap: () => _copyPromptAndOpenAi(
            controller,
            promptText: promptText,
            baseUrl: 'https://gemini.google.com/app',
            queryParam: 'prompt',
          ),
        ),
        const SizedBox(height: 10),
        _buildGenerateButtonTile(
          label: 'Generate with ChatGPT',
          icon: Icons.smart_toy_outlined,
          onTap: () => _copyPromptAndOpenAi(
            controller,
            promptText: promptText,
            baseUrl: 'https://chatgpt.com/',
            queryParam: 'q',
          ),
        ),
      ],
    );
  }

  Future<void> _copyPromptAndOpenAi(
    DetailController controller, {
    required String promptText,
    required String baseUrl,
    required String queryParam,
  }) async {
    if (promptText.isEmpty) {
      Get.snackbar(
        'Prompt missing',
        'No prompt text available to open.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    controller.copyPrompt();
    await _openAiUrl(
      promptText,
      baseUrl: baseUrl,
      queryParam: queryParam,
    );
  }

  Widget _buildGenerateButtonTile({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFec5b13),
              Color(0xFF4a342a),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFec5b13).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAiUrl(
    String promptText, {
    required String baseUrl,
    required String queryParam,
  }) async {

    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      queryParam: promptText,
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    Get.snackbar(
      'Unable to open',
      'Please try again later.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _buildRelatedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Related Generations',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'View all',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            itemBuilder: (context, index) {
              final images = [
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBqLHn0wfrmxGVUf3ifor5jDgTlNPL6A7BFy79K6YEhOSMv6rArcGsx2l1MLYRfctkW31Q0j6ydlJGQhyuZ_1DYE7EiPkAHNwf_Aa_bhEZXBTIOw1c--lnAsoVQ0S-xYTTXIxBXIDR3MTwwlzJ7WfWpCWiqQ-6JrS74rM748KEaMjUcInm8A8rKwbxjdryRaM1dOAhbYD10B-It3zbF1MtnGGDLhfUiUw07JVrhwTHbgJbq1G5DqzOJRaYv36p23aMMDaIT-QjKAinD',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuC30d5lqcA7qGDIai5rlSITjKZdVmtztmePnGSXI1DFRGBc-KkM3QFS-25cHIQml0IYoznZtqhHryomG80RSKsJw_bsKBLEa8S-6CmNICHs95ZlOSWrVPu6Djvo5dbCtjyxUvcTKMNZB8pao8JPAGUHwy2aLibM3lQhenhpqw2us5juRewBomFvAlNm27DdXM6iJjiCYyskrgmt_Z8XVnN_g7CgWAK67zBMBr-Graf-hd4NG0qIpRAMB5mKV2uAaVoT-SrXHWIXVps-',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBnIwgECCsRsMij_rM2iWjEG8CCDNBAaI6FAPTjYQpoADhS0KSkCiPnvdjwZJSJVewSh3nxBLpyNKpbDBTBjGL3qp27r-Y6NFyMQaPuyQeR6K4mtdqO4vHwxVmBbOF1YZR7fuxCTRoKc6r4DNQZajZqz4HXLAkjHRm2JUlcM71wZB_m-JnKzkXA_TMhYmnCkZiZiNwNt3b0keDUF9MpWUplQ3JSDlahV3sdfb02wPm4TBnI6yPJLLCn9Sg74xoTG_UYqwZQOxRbR28a',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuB0AfTcB3io4NM4WQ9t2a9ZsxWhBbCnyYK2wrv7LaHiiImhTWtOVo4m7BqULtJYSnX_iWE0R4VZ_6yLkBRjJCaXeYvPbBx9We6l-yMpkhkyG-UnDcDJVVqyy-CjTMnEfHpqATc6beWi8dW9zVtyqX1y9vRu5HGCgwtBIRdV7rxDII_91lp6H2zesX31_-XpeCbQoEmmJHtRQRwo48r04XqlGTLZ-VFsRjUsrhYR0EPbk_RP5BhqX8TT91uszxAu8kWaN_C2fABRCGuj',
              ];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    width: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFF3a2d26),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF3a2d26),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


}