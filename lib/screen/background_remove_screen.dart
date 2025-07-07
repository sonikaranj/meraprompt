import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/background_remove_controller.dart';

class BackgroundRemovePickScreen extends StatelessWidget {
  final controller = Get.put(BackgroundRemoveController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pick Image')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (controller.pickedImage.value != null)
                Image.file(controller.pickedImage.value!, height: 200),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: controller.pickImage,
                icon: Icon(Icons.image),
                label: Text('Pick Image'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
