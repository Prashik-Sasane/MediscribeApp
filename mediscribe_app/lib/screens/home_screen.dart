import 'package:flutter/material.dart';

import 'package:mediscribe_app/core/color.dart';
import '../core/text_styles.dart';
import '../widgets/primary_button.dart';
import 'package:mediscribe_app/screens/upload_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Mediscribe',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'about') {
                showAboutDialog(
                  context: context,
                  applicationName: 'Mediscribe',
                  applicationVersion: '1.0.0',
                  children: const [
                    Text(
                      'AI-powered platform for effortless prescription documentation.',
                    ),
                  ],
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'about',
                child: Text('About'),
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // 🔷 HERO CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'AI-powered solution for effortless\nprescription documentation',
                    style: AppTextStyles.heroTitle,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Upload medical prescriptions and instantly convert them into readable digital text using AI.',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 🚀 CTA BUTTON
            PrimaryButton(
              text: 'Upload Prescription',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 36),

            // ⭐ FEATURES TITLE
            const Text(
              'Why Mediscribe?',
              style: AppTextStyles.sectionTitle,
            ),

            const SizedBox(height: 16),

            _featureItem(Icons.camera_alt_outlined, 'Easy prescription upload'),
            _featureItem(Icons.flash_on_outlined, 'Fast AI-powered processing'),
            _featureItem(Icons.medical_services_outlined, 'Designed for medical use'),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
