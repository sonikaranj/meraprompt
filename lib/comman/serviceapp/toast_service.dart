import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

 class ToastService {
 static void showToast({
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 16.0,
    int durationSeconds = 2,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: durationSeconds == 0 ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
    );
  }
}
