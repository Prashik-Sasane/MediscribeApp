import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/color.dart';
import '../services/pdf_service.dart';
import '../widgets/primary_button.dart';

class ResultScreen extends StatelessWidget {
  final String text;

  const ResultScreen({super.key, required this.text});

  /// 🧠 Temporary structured extraction
  /// (Later Gemini will give better structured output)
  Map<String, dynamic> _parseData(String raw) {
    return {
      'doctor': 'Dr. Reynald O. Joson, M.D.',
      'hospital': 'Manila Doctors Hospital',
      'license': '44609',
      'patient': 'John Doe',
      'age': '45',
      'gender': 'Male',
      'date': '12-06-2014',
      'medicines': [
        {
          'name': 'Paracetamol',
          'dosage': '500 mg',
          'frequency': 'Thrice daily',
          'instructions': 'After food',
        },
        {
          'name': 'Amoxicillin',
          'dosage': '250 mg',
          'frequency': 'Twice daily',
          'instructions': 'Orally',
        },
        {
          'name': 'Cough Syrup',
          'dosage': '5 ml',
          'frequency': 'Twice daily',
          'instructions': 'Orally',
        },
      ],
      'notes': 'Follow-up after 7 days',
    };
  }

  Future<void> _exportPdf(BuildContext context) async {
    final File file = await PdfService.generatePrescriptionPdf(text);
    Share.shareXFiles([XFile(file.path)], text: 'Prescription Report');
  }

  @override
  Widget build(BuildContext context) {
    final data = _parseData(text);

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
                      title: data['doctor'],
                      subtitle:
                          '${data['hospital']}\nLic. No: ${data['license']}',
                    ),

                    const SizedBox(height: 12),

                    /// 👤 Patient Section
                    _infoCard(
                      icon: Icons.person,
                      title: data['patient'],
                      subtitle:
                          'Age: ${data['age']} | Gender: ${data['gender']}\nDate: ${data['date']}',
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

                    _medicineTable(data['medicines']),

                    if (data['notes'] != null) ...[
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
                    onPressed: () => _exportPdf(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: 'Share',
                    onPressed: () => Share.share(text),
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