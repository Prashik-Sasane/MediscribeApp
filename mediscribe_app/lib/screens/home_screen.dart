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

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),

            // HERO TITLE
            const Text(
              'AI-powered solution for effortless\nprescription documentation',
              style: AppTextStyles.heroTitle,
            ),

            const SizedBox(height: 16),

            // SUBTITLE
            const Text(
              'Upload medical prescriptions and instantly convert them into readable digital text using AI.',
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 40),

            // CTA BUTTON
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

            const SizedBox(height: 40),

            // FEATURES
            const Text(
              'Why Mediscribe?',
              style: AppTextStyles.sectionTitle,
            ),

            const SizedBox(height: 16),

            _featureItem('📸', 'Easy prescription upload'),
            _featureItem('⚡', 'Fast AI-powered processing'),
            _featureItem('🩺', 'Designed for medical use'),
          ],
        ),
      ),
    );
  }

  Widget _featureItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
