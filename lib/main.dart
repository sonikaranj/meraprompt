import 'package:aiimagegenerator2/comman/Admob/Admob_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:aiimagegenerator2/screen/homescreeen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  Get.put(AdController()); // Register AdController globally
  await Firebase.initializeApp(); // Firebase initialize
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1290, 2796),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: Homescreeen()
      ),
    );
  }
}
