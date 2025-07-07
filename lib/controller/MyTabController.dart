// file: controllers/tab_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyTabController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      currentIndex.value = tabController.index;
    });
  }

  void changeTab(int index) {
    currentIndex.value = index;
    tabController.index = index;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
