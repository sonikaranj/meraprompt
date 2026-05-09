import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0604),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0604),
        elevation: 0,
        title: const Text("Profile"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            child: Row(
              children: [

                // Avatar
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Color(0xFFec5b13),
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 16),

                // User Info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Guest User",
                      style: TextStyle(
                        color: Colors.grey[200],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "promptseen.app",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          _buildMenuItem(
            icon: Icons.favorite,
            title: "My Favorites",
            onTap: () {
              Get.toNamed('/favorites');
            },
          ),

          _buildMenuItem(
            icon: Icons.share,
            title: "Share App",
            onTap: () {},
          ),

          _buildMenuItem(
            icon: Icons.star,
            title: "Rate App",
            onTap: () {},
          ),

          _buildMenuItem(
            icon: Icons.privacy_tip,
            title: "Privacy Policy",
            onTap: () {},
          ),

          _buildMenuItem(
            icon: Icons.description,
            title: "Terms & Conditions",
            onTap: () {},
          ),

          _buildMenuItem(
            icon: Icons.info,
            title: "About App",
            onTap: () {},
          ),

          const SizedBox(height: 30),

          Center(
            child: Text(
              "PromptSeen v1.0",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Colors.white.withOpacity(0.05),
        leading: Icon(
          icon,
          color: const Color(0xFFec5b13),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.grey[200],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
