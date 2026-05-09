import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:promptseen/comman/serviceapp/profile_screen.dart';
import 'package:promptseen/controller/bottom_screen_controller.dart';
import 'package:promptseen/screen/FavoriteScreen.dart';
import 'home_screen.dart';

class BottomNavScreen extends StatefulWidget {
  BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  late BottomNavController controller;

  final List<Widget> pages = [
    HomeScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  final List<NavItem> navItems = [
    NavItem(
      icon: Icons.home,
      label: "Home",
      color: const Color(0xFF00D4FF), // Cyan
    ),
    NavItem(
      icon: Icons.favorite,
      label: "Favorite",
      color: const Color(0xFF00D4FF), // Cyan
    ),
    NavItem(
      icon: Icons.person,
      label: "Profile",
      color: const Color(0xFF00D4FF), // Cyan
    ),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(BottomNavController());
  }

  void _changeTab(int index) {
    if (controller.currentIndex != index) {
      controller.changeTab(index);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BottomNavController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0E27), // Dark navy background
          body: IndexedStack(
            index: controller.currentIndex,
            children: pages,
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return GetBuilder<BottomNavController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F1428), // Darker navy background
            border: Border(
              top: BorderSide(
                color: const Color(0xFF1a1f3a),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              navItems.length,
                  (index) => _buildNavItem(
                navItems[index],
                index,
                controller.currentIndex == index,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
      NavItem item,
      int index,
      bool isActive,
      ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _changeTab(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: isActive ? item.color : const Color(0xFF6B7280),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? item.color : const Color(0xFF6B7280),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Navigation item model
class NavItem {
  final IconData icon;
  final String label;
  final Color color;

  NavItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}