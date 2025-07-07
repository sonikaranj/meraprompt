import 'dart:io';
import 'package:aiimagegenerator2/comman/serviceapp/toast_service.dart';
import 'package:aiimagegenerator2/const.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';


class ImagePreviewController extends GetxController {
  RxList<File> images = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadImages();
  }

  Future<void> loadImages() async {
    final tempDir = await getTemporaryDirectory();
    final folderPath = '${tempDir.path}/AssetDownload';
    final folder = Directory(folderPath);

    if (await folder.exists()) {
      final files = folder
          .listSync()
          .whereType<File>()
          .where((file) =>
      file.path.endsWith('.jpg') || file.path.endsWith('.png'))
          .toList();

      // ✅ Sort newest image first using last modified time
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      images.assignAll(files);
    }
  }



  Future<void> deleteImage(File file) async {
    try {
      await file.delete();
      images.remove(file);
      ToastService.showToast(message: "Image deleted");
    } catch (e) {
      ToastService.showToast(message: "Could not delete image");
    }
  }

  Future<void> shareImage(File file) async {
    try {
      await Share.shareXFiles([XFile(file.path)], text: "Check out this image!");
    } catch (e) {
      ToastService.showToast(message: "Failed to share image");
     }
  }
}



class ImagePreviewScreen extends StatelessWidget {
  final controller = Get.put(ImagePreviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      appBar: AppBar(

        backgroundColor: AppColor.black,
        title: Text('Saved Images', style: TextStyle(color: AppColor.white)),
      ),
      body: Obx(() {
        if (controller.images.isEmpty) {
          return Center(
            child: Text('No images found.', style: TextStyle(color: AppColor.white)),
          );
        }
        return GridView.builder(
          padding: EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: controller.images.length,
          itemBuilder: (context, index) {
            final imageFile = controller.images[index];
            return GestureDetector(
              onTap: () => Get.to(() => FullImageView(file: imageFile)),
              onLongPress: () => _showImageOptions(context, imageFile),
              child: Image.file(imageFile, fit: BoxFit.cover),
            );
          },
        );
      }),
    );
  }

  void _showImageOptions(BuildContext context, File file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.black,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share, color: AppColor.white),
              title: Text('Share', style: TextStyle(color: AppColor.white)),
              onTap: () {
                Navigator.pop(context);
                controller.shareImage(file);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                controller.deleteImage(file);
              },
            ),
          ],
        );
      },
    );
  }
}


class FullImageView extends StatelessWidget {
  final File file;
  final controller = Get.find<ImagePreviewController>();

  FullImageView({required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColor.white
        ),
        leading: GestureDetector(
            onTap: (){
              print("ş");
              Get.back();
            },
            child: Icon(Icons.arrow_back)),
        backgroundColor: AppColor.black,
        title: Text('Image Preview', style: TextStyle(color: AppColor.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () => controller.shareImage(file),
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Center(
        child: Image.file(file),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.defaultDialog(
      backgroundColor: AppColor.black,
      title: "Delete Image",
      titleStyle: TextStyle(color: Colors.red),
      content: Text("Are you sure you want to delete this image?",
          style: TextStyle(color: AppColor.white)),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: Text("Delete"),
        onPressed: () {
          controller.deleteImage(file);
          Get.back(); // Close dialog
          Get.back(); // Close preview
        },
      ),
      cancel: TextButton(
        child: Text("Cancel", style: TextStyle(color: Colors.white)),
        onPressed: () => Get.back(),
      ),
    );
  }
}

