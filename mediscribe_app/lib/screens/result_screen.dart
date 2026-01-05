import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/color.dart';
import '../widgets/primary_button.dart';
import '../services/pdf_service.dart';

class ResultScreen extends StatelessWidget {
  final String text;

  const ResultScreen({super.key, required this.text});

  // 🔹 Very simple medicine highlighting heuristic
  List<TextSpan> _highlightMedicines(String input) {
    final medicineKeywords = [
      'tablet',
      'tab',
      'capsule',
      'cap',
      'syrup',
      'mg',
      'ml'
    ];

    final words = input.split(' ');
    return words.map((word) {
      final lower = word.toLowerCase();

      final isMedicine = medicineKeywords.any(lower.contains);

      return TextSpan(
        text: '$word ',
        style: TextStyle(
          fontSize: 15,
          color: isMedicine ? Colors.blueAccent : null,
          fontWeight: isMedicine ? FontWeight.w600 : FontWeight.normal,
        ),
      );
    }).toList();
  }

  Future<void> _exportPdf(BuildContext context) async {
    final File file = await PdfService.generatePrescriptionPdf(text);
    Share.shareXFiles([XFile(file.path)], text: 'Prescription Report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Prescription Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🩺 Header
            Row(
              children: [
                Icon(Icons.medical_services,
                    color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Extracted Medical Data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📋 Result Card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
                ),
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      children: _highlightMedicines(text),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔘 Actions
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Export PDF',
                    onPressed: () => _exportPdf(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Share',
                    onPressed: () {
                      Share.share(text);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
