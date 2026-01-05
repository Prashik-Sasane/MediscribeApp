import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<File> generatePrescriptionPdf(String rawText) async {
    final pdf = pw.Document();

    // 🔹 Temporary structured data (same as ResultScreen)
    final Map<String, dynamic> data = {
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Prescription Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 16),

              /// 👨‍⚕️ Doctor
              _infoBlock(
                title: data['doctor'].toString(),
                subtitle:
                    '${data['hospital']}\nLicense No: ${data['license']}',
              ),

              pw.SizedBox(height: 10),

              /// 👤 Patient
              _infoBlock(
                title: data['patient'].toString(),
                subtitle:
                    'Age: ${data['age']} | Gender: ${data['gender']}\nDate: ${data['date']}',
              ),

              pw.SizedBox(height: 20),

              /// 💊 Table title
              pw.Text(
                'Prescribed Medicines',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 8),

              _medicineTable(List<Map<String, dynamic>>.from(data['medicines'])),

              pw.SizedBox(height: 16),

              /// 📝 Notes
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.yellow100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'Notes: ${data['notes']}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/prescription_report.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// 🔹 Info block
  static pw.Widget _infoBlock({
    required String title,
    required String subtitle,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// 💊 Medicine Table
  static pw.Widget _medicineTable(List<Map<String, dynamic>> medicines) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(1.2),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        _tableHeader(),
        ...medicines.map((m) {
          return _tableRow(
            m['name'].toString(),
            m['dosage'].toString(),
            m['frequency'].toString(),
            m['instructions'].toString(),
          );
        }),
      ],
    );
  }

  static pw.TableRow _tableHeader() {
    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
      children: [
        _headerCell('Medicine'),
        _headerCell('Dosage'),
        _headerCell('Frequency'),
        _headerCell('Instructions'),
      ],
    );
  }

  static pw.TableRow _tableRow(
    String name,
    String dosage,
    String frequency,
    String instructions,
  ) {
    return pw.TableRow(
      children: [
        _cell(name),
        _cell(dosage),
        _cell(frequency),
        _cell(instructions),
      ],
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }
}
