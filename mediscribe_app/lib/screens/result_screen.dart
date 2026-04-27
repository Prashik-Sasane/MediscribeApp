import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mediscribe_app/core/app_state.dart';
import 'package:share_plus/share_plus.dart';

import '../core/color.dart';
import '../services/pdf_service.dart';
import '../widgets/primary_button.dart';

class ResultScreen extends StatefulWidget {
  final String text;

  const ResultScreen({super.key, required this.text});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).setPrescriptionText(widget.text);
    });
  }

  Map<String, dynamic> _parseData(String raw) {
    String s = raw.trim();

    // Gemini sometimes returns JSON wrapped in extra text / markdown fences.
    // Extract the outermost JSON object before decoding.
    final start = s.indexOf('{');
    final end = s.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      s = s.substring(start, end + 1);
    }

    try {
      final decoded = jsonDecode(s);
      return Map<String, dynamic>.from(decoded as Map);
    } catch (_) {
      // Fix #1: do NOT guess medicines from OCR lines.
      // If it isn't valid JSON, treat it as an invalid/unsupported upload.
      return {
        'error':
            'Could not extract a valid prescription. Please upload a clear photo of a prescription (full page, good lighting, readable medicines).',
      };
    }
  }

  List<Map<String, dynamic>> _sanitizeMedicines(Map<String, dynamic> data) {
    final raw = data['medicines'];
    if (raw is! List) return const [];

    final patient = (data['patient'] ?? '').toString().trim().toLowerCase();
    final doctor = (data['doctor'] ?? '').toString().trim().toLowerCase();
    final hospital = (data['hospital'] ?? '').toString().trim().toLowerCase();

    bool looksLikeNonMedicineLine(String s) {
      final t = s.trim().toLowerCase();
      if (t.isEmpty) return true;
      if (t == 'not mentioned') return true;

      // Common header/metadata lines that should never be medicines.
      const badKeywords = [
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
      for (final k in badKeywords) {
        if (t.contains(k)) return true;
      }

      // If Gemini mistakenly repeats patient/doctor/hospital in medicines, drop it.
      if (patient.isNotEmpty && t == patient) return true;
      if (doctor.isNotEmpty && t == doctor) return true;
      if (hospital.isNotEmpty && t == hospital) return true;

      return false;
    }

    final out = <Map<String, dynamic>>[];
    for (final m in raw) {
      if (m is! Map) continue;
      final mm = Map<String, dynamic>.from(m as Map);
      final name = (mm['name'] ?? '').toString();
      if (looksLikeNonMedicineLine(name)) continue;
      out.add(mm);
    }
    return out;
  }

  Future<void> _exportPdf(BuildContext context, Map<String, dynamic> data) async {
    final File file = await PdfService.generatePrescriptionPdf(data);
    Share.shareXFiles([XFile(file.path)], text: 'Prescription Report');
  }

  @override
  Widget build(BuildContext context) {
    final data = _parseData(widget.text);

    if (data.containsKey('error')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Processing Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 80),
                const SizedBox(height: 20),
                Text(
                  data['error'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: 'Go Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sanitizedMedicines = _sanitizeMedicines(data);
    if (sanitizedMedicines.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Processing Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.red, size: 80),
                const SizedBox(height: 20),
                const Text(
                  'Could not extract medicines from this prescription. Please upload a clearer photo (full page, good lighting, readable medicine names).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  text: 'Go Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 👨‍⚕️ Doctor Section
                    _infoCard(
                      icon: Icons.medical_services,
                      title: data['doctor'] ?? 'Doctor not mentioned',
                      subtitle:
                          '${data['hospital'] ?? 'Hospital not mentioned'}\nLic. No: ${data['license'] ?? 'N/A'}',
                    ),

                    const SizedBox(height: 12),

                    /// 👤 Patient Section
                    _infoCard(
                      icon: Icons.person,
                      title: data['patient'] ?? 'Patient not mentioned',
                      subtitle:
                          'Age: ${data['age'] ?? 'N/A'} | Gender: ${data['gender'] ?? 'N/A'}\nDate: ${data['date'] ?? 'N/A'}',
                    ),

                    const SizedBox(height: 20),

                    /// 💊 Medicine Table
                    Text(
                      'Prescribed Medicines',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 12),

                    _medicineTable(sanitizedMedicines),

                    if (data['notes'] != null && data['notes'] != 'Not mentioned') ...[
                      const SizedBox(height: 20),
                      _notesCard(data['notes']),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// 🔘 Actions
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Export PDF',
                    onPressed: () => _exportPdf(context, data),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Share',
                    onPressed: () => Share.share(widget.text),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _infoCard({
  required IconData icon,
  required String title,
  required String subtitle,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Doctor / Patient NAME (BLACK)
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),

              // ✅ Details (Hospital / Age / Date)
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  /// 💊 Medicine Table
  Widget _medicineTable(List medicines) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(2),
        },
        border: TableBorder.symmetric(
          inside: BorderSide(color: Colors.grey.shade300),
        ),
        children: [
          _tableHeader(),
          ...medicines.map<TableRow>((m) => _tableRow(
                m['name'],
                m['dosage'],
                m['frequency'],
                m['instructions'],
              )),
        ],
      ),
    );
  }

  TableRow _tableHeader() {
    return const TableRow(
      decoration: BoxDecoration(color: Color.fromARGB(255, 7, 65, 106)),
      children: [
        _HeaderCell('Medicine'),
        _HeaderCell('Dosage'),
        _HeaderCell('Frequency'),
        _HeaderCell('Instructions'),
      ],
    );
  }

  TableRow _tableRow(
      String name, String dosage, String freq, String inst) {
    return TableRow(children: [
      _Cell(name),
      _Cell(dosage),
      _Cell(freq),
      _Cell(inst),
    ]);
  }

  /// 📝 Notes
  Widget _notesCard(String note) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 244, 188, 5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(note)),
        ],
      ),
    );
  }
}

/// Table Cells
class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  const _Cell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(text),
    );
  }
}