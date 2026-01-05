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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Mediscribe',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI-powered solution for effortless\nprescription documentation',
                    style: AppTextStyles.heroTitle(context),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upload medical prescriptions and instantly convert them into readable digital text using AI.',
                    style: AppTextStyles.subtitle(context),
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
            Text(
              'Why Mediscribe?',
              style: AppTextStyles.sectionTitle(context),
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
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
