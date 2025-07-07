import 'package:aiimagegenerator2/comman/Admob/Admob_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:aiimagegenerator2/screen/background_remove_screen.dart';
import 'package:aiimagegenerator2/screen/generate_image.dart';

class Homescreeen extends StatelessWidget {
  Homescreeen({super.key});

  final adController = Get.find<AdController>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            50.verticalSpace,
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => GenerateImage());
                },
                child: Text("Generate Image"),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => GenerateImage());
                },
                child: Text("Image Upscale"),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => BackgroundRemovePickScreen());
                },
                child: Text("Background Removed"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
