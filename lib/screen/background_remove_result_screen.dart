import 'package:aiimagegenerator2/comman/serviceapp/image_service.dart';
import 'package:aiimagegenerator2/comman/serviceapp/toast_service.dart';
import 'package:aiimagegenerator2/const.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/background_remove_controller.dart';

class BackgroundRemoveResultScreen extends StatelessWidget {
  final controller = Get.find<BackgroundRemoveController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      appBar: AppBar(
        backgroundColor: AppColor.black,
        title: Text('Background Removed',style: TextStyle(color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.white,),
          onPressed: () {
            // Go back to pick screen
            Get.back();
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Obx(() {
              if (controller.resultImageBytes.value != null) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.memory(
                    controller.resultImageBytes.value!,
                    fit: BoxFit.contain,
                  ),
                );
              } else {
                return Text('No result available.');
              }
            }),

            ElevatedButton(
              onPressed: () {
                final bytes = controller.resultImageBytes.value;
                if (bytes != null) {
                  ImageService.saveImageFromBytes(bytes);
                } else {
                  ToastService.showToast(message: "No image to save");
                }
              },
              child: Text("Save Image"),
            ),

            ElevatedButton(
              onPressed: () {
                final bytes = controller.resultImageBytes.value;
                if (bytes != null) {
                  ImageService.shareImageFromBytes(bytes);
                } else {
                  ToastService.showToast(message: "No image to share");
                }
              },
              child: Text("Share Image"),
            ),


          ],
        ),
      ),
    );
  }
}
