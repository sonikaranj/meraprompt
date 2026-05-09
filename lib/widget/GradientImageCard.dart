// import 'dart:ui';
// import 'package:promptseen/const.dart';
// import 'package:promptseen/widget/AnimatedCircleIcon.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shimmer/shimmer.dart';
//
// class GradientImageCard extends StatelessWidget {
//   final String imageUrl;
//   final String imageTitle;
//   final String center;
//
//   const GradientImageCard({
//     super.key,
//     required this.imageUrl,
//     required this.imageTitle,
//     required this.center,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       margin: const EdgeInsets.all(16),
//       clipBehavior: Clip.antiAlias,
//       elevation: 8,
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           // Background Image
//           SizedBox(
//             width: Get.width / 1.1,
//             height: Get.height / 2.5,
//             child: CachedNetworkImage(
//               imageUrl: imageUrl,
//               alignment:
//                   center == "true" ? Alignment.center : Alignment.topCenter,
//               fit: BoxFit.fitWidth,
//               width: double.infinity,
//               height: double.infinity,
//               placeholder:
//                   (context, url) => Shimmer.fromColors(
//                     baseColor: Colors.grey[800]!,
//                     highlightColor: Colors.grey[600]!,
//                     child: Container(
//                       width: double.infinity,
//                       height: double.infinity,
//                       color: Colors.grey[850],
//                     ),
//                   ),
//               errorWidget: (context, url, error) => const Icon(Icons.error),
//             ),
//           ),
//
//           // Top icons row
//           Positioned(
//             top: 12,
//             left: 12,
//             child: Row(
//               children: [
//                 GestureDetector(onTap: () {
//
//                 }, child: _circleIcon(Icons.share)),
//                 const SizedBox(width: 6),
//                 GestureDetector(
//                   onTap: () {},
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: const BoxDecoration(
//                       color: Colors.black26,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Image.asset(
//                       'asset/instagram.png',
//                       height: 20,
//                       width: 20,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 GestureDetector(
//                   onTap: () {},
//                   child: Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: const BoxDecoration(
//                       color: Colors.black26,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Image.asset(
//                       'asset/whatsapp.png',
//                       height: 20,
//                       width: 20,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Animated Bookmark Icon
//           Positioned(
//             top: 12,
//             right: 12,
//             child: AnimatedCircleIcon(
//               iconActiveColor: Colors.white,
//               active: false,
//               iconSize: 20,
//               iconColor: Colors.white,
//               iconData: Icons.share,
//               iconDataEnd: Icons.share,
//               borderColor: AppColor.white,
//               padding: 8,
//             ),
//           ),
//
//           // Bottom overlay
//           Positioned(
//             bottom: 20,
//             left: 20,
//             right: 20,
//             child: ClipRRect(
//               borderRadius: const BorderRadius.all(
//               Radius.circular(24)
//               ),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.08), // translucent fill
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: Colors.deepPurpleAccent.withOpacity(0.1), // soft white border
//                       width: 4
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.25), // outer shadow
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                       BoxShadow(
//                         color: Colors.white.withOpacity(
//                           0.003,
//                         ), // inner-glow-like soft white
//                         blurRadius: 0.1,
//                         offset: const Offset(0, -5),
//                         spreadRadius: -1,
//                       ),
//                     ],
//                   ),
//
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         imageTitle,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: const [
//                           Icon(
//                             Icons.remove_red_eye,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                           SizedBox(width: 4),
//                           Text(
//                             "2.5K",
//                             style: TextStyle(color: Colors.white, fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _circleIcon(IconData iconData) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       decoration: const BoxDecoration(
//         color: Colors.black26,
//         shape: BoxShape.circle,
//       ),
//       child: Icon(iconData, size: 23, color: Colors.white),
//     );
//   }
// }
