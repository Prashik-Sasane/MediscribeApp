import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import '../core/color.dart';
import '../services/image_preprocessor.dart';
import '../services/prescription_analyze_service.dart';
import 'result_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final File image;

  const ProcessingScreen({super.key, required this.image});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double _progress = 0.0;
  bool _done = false;

  static const _nonMedicineKeywords = <String>[
    'patient',
    'name',
    'age',
    'gender',
    'date',
    'dob',
    'dr.',
    'doctor',
    'hospital',
    'license',
    'lic.',
    'address',
    'phone',
    'mobile',
    'rx',
  ];

  Map<String, dynamic> _normalizePrescriptionJson(Map<String, dynamic> data) {
    // Some model responses may use "medicine" instead of "medicines".
    if (data['medicines'] == null && data['medicine'] is List) {
      data['medicines'] = data['medicine'];
    }
    return data;
  }

  bool _looksLikeValidPrescription(Map<String, dynamic> data) {
    if (data.containsKey('error')) return false;

    final medsRaw = data['medicines'];
    if (medsRaw is! List) return false;

    bool looksLikeNonMedicineLine(String s) {
      final t = s.trim().toLowerCase();
      if (t.isEmpty) return true;
      if (t == 'not mentioned') return true;
      for (final k in _nonMedicineKeywords) {
        if (t.contains(k)) return true;
      }
      return false;
    }

    // Require at least 1 plausible medicine entry.
    int good = 0;
    for (final m in medsRaw) {
      if (m is! Map) continue;
      final name = (m['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      if (looksLikeNonMedicineLine(name)) continue;
      good++;
    }
    return good > 0;
  }

  @override
  void initState() {
    super.initState();
    _startPipeline();
  }

  Future<void> _startPipeline() async {
    // STEP 0 — Preprocess image (stabilize + improve readability)
    setState(() => _progress = 0.1);
    File imageForOcr = widget.image;
    try {
      imageForOcr = await ImagePreprocessor.process(widget.image);
    } catch (_) {
      // If preprocessing fails, continue with original image.
      imageForOcr = widget.image;
    }

    // STEP 1 — Backend (uploads image, calls Gemini server-side)
    setState(() => _progress = 0.65);

    final String geminiTextFinal =
        await PrescriptionAnalyzeService.analyzePrescriptionImage(imageForOcr);

    // STEP 3 — Finish
    setState(() {
      _progress = 1.0;
      _done = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    // Only navigate to ResultScreen for a non-empty response.
    if (geminiTextFinal.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not analyze this image right now. Please try again (check internet / API key) or upload a clearer prescription.',
          ),
        ),
      );
      Navigator.pop(context);
      return;
    }

    String s = geminiTextFinal;
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      s = s.substring(start, end + 1);
    }

    Map<String, dynamic>? parsed;
    try {
      parsed = Map<String, dynamic>.from(jsonDecode(s) as Map);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not read a valid prescription result. Please try again with a clear, full-page prescription photo.',
          ),
        ),
      );
      Navigator.pop(context);
      return;
    }

    parsed = _normalizePrescriptionJson(parsed);

    if (parsed.containsKey('error')) {
      final msg = (parsed['error'] ?? '').toString().trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg.isEmpty
                ? 'The provided image does not appear to be a medical prescription.'
                : msg,
          ),
        ),
      );
      Navigator.pop(context);
      return;
    }

    if (!_looksLikeValidPrescription(parsed)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not extract medicines from this prescription. Please upload a clearer photo (full page, readable medicine names).',
          ),
        ),
      );
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(text: geminiTextFinal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _done
                  ? const Icon(
                      Icons.check_circle_rounded,
                      key: ValueKey('done'),
                      size: 72,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.health_and_safety_rounded,
                      key: const ValueKey('loading'),
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),

            const SizedBox(height: 24),

            Text(
              _done
                  ? 'Prescription processed successfully'
                  : 'Processing prescription…',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 220,
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(6),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              '${(_progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}