import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../model/speed_test_record.dart';

class PdfService {
  String _fmt(DateTime dt) {
    // yyyy-MM-dd HH:mm:ss
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} '
        '${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }

  Future<File> exportAll(List<SpeedTestRecord> items) async {
    final doc = pw.Document();

    double avg(List<double> xs) =>
        xs.isEmpty ? 0 : xs.reduce((a, b) => a + b) / xs.length;

    final dls = items.map((e) => e.downloadMbps).toList();
    final uls = items.map((e) => e.uploadMbps).toList();
    final pings = items.map((e) => e.pingMs).toList();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (_) => [
          pw.Text(
            'Internet Speed Test - History Report',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Generated: ${_fmt(DateTime.now().toLocal())}'),
          pw.SizedBox(height: 10),
          pw.Text('Total tests: ${items.length}'),
          pw.Text('Average Download: ${avg(dls).toStringAsFixed(2)} Mbps'),
          pw.Text('Average Upload: ${avg(uls).toStringAsFixed(2)} Mbps'),
          pw.Text('Average Ping: ${avg(pings).toStringAsFixed(2)} ms'),
          pw.SizedBox(height: 12),

          pw.TableHelper.fromTextArray(
            headers: const ['Date/Time', 'Download (Mbps)', 'Upload (Mbps)', 'Ping (ms)'],
            data: items.map((e) {
              final dt = DateTime.fromMillisecondsSinceEpoch(e.ts).toLocal();
              return [
                _fmt(dt),
                e.downloadMbps.toStringAsFixed(2),
                e.uploadMbps.toStringAsFixed(2),
                e.pingMs.toStringAsFixed(1),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/speedtest_history_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }
}