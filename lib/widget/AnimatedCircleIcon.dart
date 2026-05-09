// import 'package:flutter/material.dart';
//
// class AnimatedCircleIcon extends StatefulWidget {
//   final IconData iconData;
//   final IconData iconDataEnd;
//   final Color iconColor;
//   final Color iconActiveColor;
//   final Color borderColor;
//   final double iconSize;
//   final double padding;
//   final bool active;
//   final VoidCallback? onToggle;
//
//   const AnimatedCircleIcon({
//     super.key,
//     required this.iconData,
//     required this.iconDataEnd,
//     required this.iconColor,
//     required this.iconActiveColor,
//     required this.borderColor,
//     required this.iconSize,
//     required this.padding,
//     required this.active,
//     this.onToggle,
//   });
//
//   @override
//   State<AnimatedCircleIcon> createState() => _AnimatedCircleIconState();
// }
//
// class _AnimatedCircleIconState extends State<AnimatedCircleIcon> {
//   double _scale = 1.0;
//   double _offsetX = 0;
//
//   void _onTap() {
//     widget.onToggle?.call(); // Notify parent
//   }
//
//   void _onLongPressStart(LongPressStartDetails details) {
//     setState(() {
//       _scale = 1.2;
//       _offsetX = -10;
//     });
//     widget.onToggle?.call();
//   }
//
//   void _onLongPressEnd(LongPressEndDetails details) {
//     setState(() {
//       _scale = 1.0;
//       _offsetX = 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPressStart: _onLongPressStart,
//       onLongPressEnd: _onLongPressEnd,
//       onTap: _onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeInOut,
//         transform: Matrix4.identity()
//           ..translate(_offsetX)
//           ..scale(_scale),
//         padding: EdgeInsets.all(widget.padding),
//         decoration: BoxDecoration(
//           color: Colors.black26,
//           borderRadius: BorderRadius.circular(100),
//           border: Border.all(color: widget.borderColor, width: 0.8),
//         ),
//         child: Icon(
//           widget.active ? widget.iconDataEnd : widget.iconData,
//           size: widget.iconSize,
//           color: widget.active ? widget.iconActiveColor : widget.iconColor,
//         ),
//       ),
//     );
//   }
// }
