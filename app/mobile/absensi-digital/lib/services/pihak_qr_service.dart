import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:barcode/barcode.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PihakQrService {
  String payload(Map<String, dynamic> pihak) {
    final flag = (pihak['flag'] as String? ?? '').toUpperCase();
    return jsonEncode({
      'id_pihak': pihak['id_pihak'],
      'kode_unik': pihak['kode_unik'],
      'nama': pihak['nama'],
      'flag': flag,
      'jenis_kelamin': flag == 'P' ? 'Perempuan' : (flag == 'L' ? 'Laki-laki' : 'Lainnya'),
    });
  }

  Future<Uint8List> generatePdfBytes(List<Map<String, dynamic>> pihakList) async {
    final pdf = pw.Document();
    final qr = Barcode.qrCode();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('QR Code Pihak')),
          pw.Text('P = Perempuan    L = Laki-laki'),
          pw.SizedBox(height: 12),
          pw.Wrap(
            spacing: 12,
            runSpacing: 12,
            children: pihakList.map((pihak) {
              final flag = (pihak['flag'] as String? ?? '').toUpperCase();
              final gender = flag == 'P' ? 'Perempuan' : (flag == 'L' ? 'Laki-laki' : 'Lainnya');
              return pw.Container(
                width: 250,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.BarcodeWidget(
                      barcode: qr,
                      data: payload(pihak),
                      width: 150,
                      height: 150,
                      drawText: false,
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(pihak['nama'] as String? ?? '', textAlign: pw.TextAlign.center),
                    pw.Text('${pihak['kode_unik']} | $flag = $gender'),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  Future<File> generatePdf(List<Map<String, dynamic>> pihakList) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'qr-pihak.pdf'));
    await file.writeAsBytes(await generatePdfBytes(pihakList));
    return file;
  }

  Future<void> shareFile(File file) async {
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      text: 'QR Code semua pihak',
    ));
  }
}