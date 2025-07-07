import 'dart:io';
import 'dart:typed_data';
import 'package:aiimagegenerator2/comman/serviceapp/toast_service.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  /// Save image from URL to Gallery
  static Future<void> saveImageFromUrl(String imageUrl) async {
    try {
      await _requestStoragePermission();

      // 1. Download image
      final response = await http.get(Uri.parse(imageUrl));
      final Uint8List bytes = response.bodyBytes;

      // 2. Get temp dir & create custom folder
      final tempDir = await getTemporaryDirectory();
      final folderPath = '${tempDir.path}/AssetDownload';
      final folder = Directory(folderPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }

      // 3. Save image in AssetDownload folder
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('$folderPath/$fileName');
      await file.writeAsBytes(bytes);
      print("📁 Saved to temp: ${file.path}");

      // 4. Now save this file to gallery
      final result = await ImageGallerySaver.saveFile(file.path);
      print("✅ Image saved to gallery: $result");
      Get.back();
      ToastService.showToast(message: "Image saved to gallery");
      // 5. Optional: Feedback to user
    } catch (e) {
      ToastService.showToast(message: "Failed to save image");
    }
  }


  /// Share image from URL
  static Future<void> shareImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final Uint8List bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_image.jpg');
      await file.writeAsBytes(bytes);
      Get.back();
      await Share.shareXFiles([XFile(file.path)], text: "Check this out!");
    } catch (e) {
      print("❌ Failed to share image: $e");
    }
  }

  /// Request storage permission (Android)
  static Future<void> _requestStoragePermission() async {
    final status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  /// Save image from memory (Uint8List)
  static Future<void> saveImageFromBytes(Uint8List imageBytes) async {
    try {
      await _requestStoragePermission();

      final tempDir = await getTemporaryDirectory();
      final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      final result = await ImageGallerySaver.saveFile(file.path);
      print("✅ Saved to gallery: $result");

      ToastService.showToast(message: "Image saved to gallery");
    } catch (e) {
      print("❌ Save failed: $e");
      ToastService.showToast(message: "Failed to save image");
    }
  }

  /// Share image from memory (Uint8List)
  static Future<void> shareImageFromBytes(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'share_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles([XFile(file.path)], text: "Check this out!");
    } catch (e) {
      print("❌ Share failed: $e");
      ToastService.showToast(message: "Failed to share image");
    }
  }


}