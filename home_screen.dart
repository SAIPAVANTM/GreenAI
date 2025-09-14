import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBDBDBD), // Light grey background like in image
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50), // Green top bar like in image
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
            size: 26,
          ),
          onPressed: () => Get.toNamed('/menu'),
        ),
        title: const Text(
          'GREENGRAM',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.black,
              size: 26,
            ),
            onPressed: () => Get.toNamed('/profile'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: GridView.count(
            shrinkWrap: true, // Allow grid to take only needed space
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.0,
            children: [
              _buildProfessionalCard(
                iconPath: 'assets/wheat.png',
                title: 'GREEN AI',
                backgroundColor: const Color(0xFF4CAF50),
                iconColor: Colors.white,
                onTap: () => Get.toNamed('/green-ai'),
              ),
              _buildProfessionalCard(
                iconPath: 'assets/location.png',
                title: 'Live Map',
                backgroundColor: const Color(0xFFE53935),
                iconColor: Colors.white,
                onTap: () => Get.toNamed('/live-map'),
              ),
              _buildProfessionalCard(
                iconPath: 'assets/stock-market.png',
                title: 'Market Price',
                backgroundColor: const Color(0xFF4CAF50),
                iconColor: Colors.white,
                onTap: () => Get.toNamed('/market-price'),
              ),
              _buildProfessionalCard(
                iconPath: 'assets/chat.png',
                title: 'Community',
                backgroundColor: const Color(0xFF2196F3),
                iconColor: Colors.white,
                onTap: () => Get.toNamed('/community'),
              ),
              _buildProfessionalCard(
                iconPath: 'assets/notification-bell.png',
                title: 'Reminders',
                backgroundColor: const Color(0xFF2196F3),
                iconColor: Colors.white,
                onTap: () => Get.toNamed('/reminder'),
              ),
              _buildProfessionalCard(
                iconPath: 'assets/helpline.png',
                title: 'Helpline',
                backgroundColor: const Color(0xFFE53935),
                iconColor: Colors.white,
                onTap: () => Get.toNamed('/helpline'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalCard({
    required String iconPath,
    required String title,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF9E9E9E), // Darker grey for card background
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF757575),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Circle Background
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: 32,
                  height: 32,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}