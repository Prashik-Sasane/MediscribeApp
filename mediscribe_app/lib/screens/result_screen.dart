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
    final lines = raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final doctorLine = lines.cast<String?>().firstWhere(
          (line) => line!.toLowerCase().contains('dr.'),
          orElse: () => null,
        );
    final patientLine = lines.cast<String?>().firstWhere(
          (line) => line!.toLowerCase().contains('patient'),
          orElse: () => null,
        );

    final medicines = <Map<String, String>>[];
    for (final line in lines.take(6)) {
      medicines.add({
        'name': line.length > 28 ? '${line.substring(0, 28)}...' : line,
        'dosage': 'As advised',
        'frequency': 'Daily',
        'instructions': 'After meal',
      });
    }

    return {
      'doctor': doctorLine ?? 'Doctor not clearly recognized',
      'hospital': 'Nearby Care Network',
      'license': 'N/A',
      'patient': patientLine ?? 'Patient details unavailable',
      'age': '--',
      'gender': '--',
      'date': DateTime.now().toString().split(' ').first,
      'medicines': medicines.isEmpty
          ? [
              {
                'name': 'No medicine extracted',
                'dosage': '-',
                'frequency': '-',
                'instructions': '-',
              }
            ]
          : medicines,
      'notes': lines.length > 1 ? lines.last : raw,
    };
  }

  Future<void> _exportPdf(BuildContext context) async {
    final File file = await PdfService.generatePrescriptionPdf(widget.text);
    Share.shareXFiles([XFile(file.path)], text: 'Prescription Report');
  }

  @override
  Widget build(BuildContext context) {
    final data = _parseData(widget.text);

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