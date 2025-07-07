import 'dart:io';
import 'dart:typed_data';
import 'package:aiimagegenerator2/screen/background_remove_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class BackgroundRemoveController extends GetxController {
  var pickedImage = Rx<File?>(null);
  var isLoading = false.obs;
  var resultImageBytes = Rx<Uint8List?>(null);

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      pickedImage.value = File(image.path);
      resultImageBytes.value = null;

      await removeBackground();
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while picking image.');
    }
  }

  Future<void> removeBackground() async {
    if (pickedImage.value == null) return;

    isLoading.value = true;

    final uri = Uri.parse('https://api2.pixelcut.app/image/matte/v1');

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'accept': 'application/json',
        'x-client-version': 'web',
        'x-locale': 'en',
      })
      ..fields['format'] = 'png'
      ..fields['model'] = 'v1'
      ..files.add(await http.MultipartFile.fromPath('image', pickedImage.value!.path));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        resultImageBytes.value = response.bodyBytes;

        // Navigate to result screen after success
        Get.to(() => BackgroundRemoveResultScreen());
      } else {
        Get.snackbar('Error', 'API Error: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove background');
    } finally {
      isLoading.value = false;
    }
  }
}
