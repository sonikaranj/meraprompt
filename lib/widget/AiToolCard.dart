// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'dart:ui';
//
// class AiToolCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final Widget preview;
//
//   const AiToolCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.preview,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 300.h,
//       width: Get.width * 0.9,
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(20.r),
//         border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.25),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Row(
//         children: [
//           // 👁 Preview Area
//           Container(
//             width: 250.w,
//             margin: EdgeInsets.symmetric(vertical: 30.h),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20.r),
//               color: AppColor.black,
//               image: const DecorationImage(
//                 image: AssetImage("assets/images/sample.jpg"), // Replace with actual image
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(20.r),
//               child: preview,
//             ),
//           ),
//           20.horizontalSpace,
//           // 📋 Text Area
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: AppColor.white,
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 10.verticalSpace,
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     color: AppColor.white.withOpacity(0.6),
//                     fontSize: 13.sp,
//                   ),
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
