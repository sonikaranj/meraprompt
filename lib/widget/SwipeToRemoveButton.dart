// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class SwipeToRemoveButton extends StatefulWidget {
//   final VoidCallback onSwiped;
//
//   const SwipeToRemoveButton({super.key, required this.onSwiped});
//
//   @override
//   State<SwipeToRemoveButton> createState() => _SwipeToRemoveButtonState();
// }
//
// class _SwipeToRemoveButtonState extends State<SwipeToRemoveButton> {
//   double _dragDistance = 0.0;
//   final double _threshold = 150;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onHorizontalDragUpdate: (details) {
//         setState(() {
//           _dragDistance += details.delta.dx;
//         });
//       },
//       onHorizontalDragEnd: (details) {
//         if (_dragDistance > _threshold) {
//           widget.onSwiped();
//         }
//         setState(() {
//           _dragDistance = 0.0;
//         });
//       },
//       child: Stack(
//         children: [
//           Container(
//             height: 60,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               color: Colors.deepPurple.shade100,
//               borderRadius: BorderRadius.circular(30),
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               'Swipe to Remove Background',
//               style: TextStyle(
//                 color: Colors.deepPurple.shade700,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//           Positioned(
//             left: _dragDistance.clamp(0, MediaQuery.of(context).size.width - 60),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 100),
//               curve: Curves.easeOut,
//               height: 60,
//               width: 60,
//               decoration: BoxDecoration(
//                 color: Colors.deepPurple,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: const Icon(Icons.check, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
