import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<File> generatePrescriptionPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

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
                title: (data['doctor'] ?? 'Not mentioned').toString(),
                subtitle:
                    '${data['hospital'] ?? 'Not mentioned'}\nLicense No: ${data['license'] ?? 'N/A'}',
              ),

              pw.SizedBox(height: 10),

              /// 👤 Patient
              _infoBlock(
                title: (data['patient'] ?? 'Not mentioned').toString(),
                subtitle:
                    'Age: ${data['age'] ?? 'N/A'} | Gender: ${data['gender'] ?? 'N/A'}\nDate: ${data['date'] ?? 'N/A'}',
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

              _medicineTable(List<dynamic>.from(data['medicines'] ?? [])),

              if (data['notes'] != null && data['notes'] != 'Not mentioned') ...[
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
  static pw.Widget _medicineTable(List<dynamic> medicines) {
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
          final medicine = Map<String, dynamic>.from(m as Map);
          return _tableRow(
            (medicine['name'] ?? 'N/A').toString(),
            (medicine['dosage'] ?? 'N/A').toString(),
            (medicine['frequency'] ?? 'N/A').toString(),
            (medicine['instructions'] ?? 'N/A').toString(),
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
