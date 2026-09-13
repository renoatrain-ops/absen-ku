import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';

class ReportRow {
  final int? idPihak;
  final String namaLengkap;
  final String namaAlias;
  final String kodePihak;
  final String status; // hadir, ijin, alpha, unknown
  final String? tglHadir; // ISO if hadir

  ReportRow({this.idPihak, required this.namaLengkap, required this.namaAlias, required this.kodePihak, required this.status, this.tglHadir});

  Map<String, dynamic> toJson() => {
        'id_pihak': idPihak,
        'nama_lengkap': namaLengkap,
        'nama_alias': namaAlias,
        'kode_pihak': kodePihak,
        'status': status,
        'tgl_hadir': tglHadir,
      };
}

class ReportService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<List<ReportRow>> buildReportForDate(DateTime date, Map<String, String> absentOverrides) async {
    final allPihakRows = await _db.database.then((db) => db.query('pihak'));
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final absensiRows = await _db.database.then((db) => db.query('absensi'));

    // Map kode_pihak -> latest tgl_hadir for that date
    final Map<String, String> hadirMap = {};
    for (final a in absensiRows) {
      final tgl = a['tgl_hadir'] as String;
      if (tgl.startsWith(dateStr)) {
        final kode = a['kode_pihak'] as String;
        // keep first found or overwrite with newest
        hadirMap[kode] = tgl;
      }
    }

    final List<ReportRow> rows = [];

    // Include known pihak
    for (final p in allPihakRows) {
      final kode = p['kode_pihak'] as String;
      final isHadir = hadirMap.containsKey(kode);
      final status = isHadir ? 'hadir' : (absentOverrides[kode] ?? 'alpha');
      rows.add(ReportRow(
        idPihak: p['id_pihak'] as int?,
        namaLengkap: p['nama_lengkap'] as String? ?? '',
        namaAlias: p['nama_alias'] as String? ?? '',
        kodePihak: kode,
        status: status,
        tglHadir: hadirMap[kode],
      ));
    }

    // Include unknown hadir (kode that in absensi but not in pihak)
    for (final kode in hadirMap.keys) {
      final found = allPihakRows.any((p) => (p['kode_pihak'] as String) == kode);
      if (!found) {
        rows.add(ReportRow(
          idPihak: null,
          namaLengkap: '',
          namaAlias: '',
          kodePihak: kode,
          status: 'hadir (unknown)',
          tglHadir: hadirMap[kode],
        ));
      }
    }

    // sort by nama_alias or kode
    rows.sort((a, b) => a.namaAlias.compareTo(b.namaAlias));
    return rows;
  }

  Future<File> generateJson(DateTime date, Map<String, String> absentOverrides) async {
    final rows = await buildReportForDate(date, absentOverrides);
    final data = rows.map((r) => r.toJson()).toList();
    final jsonStr = jsonEncode({'date': date.toIso8601String(), 'data': data});

    final dir = await getApplicationDocumentsDirectory();
    final filePath = p.join(dir.path, 'absensi_${_fmtDate(date)}.json');
    final file = File(filePath);
    await file.writeAsString(jsonStr);
    return file;
  }

  Future<File> generateCsv(DateTime date, Map<String, String> absentOverrides) async {
    final rows = await buildReportForDate(date, absentOverrides);
    final header = ['id_pihak', 'nama_lengkap', 'nama_alias', 'kode_pihak', 'status', 'tgl_hadir'];
    final sb = StringBuffer();
    sb.writeln(header.join(','));
    for (final r in rows) {
      final line = [
        r.idPihak?.toString() ?? '',
        _escapeCsv(r.namaLengkap),
        _escapeCsv(r.namaAlias),
        _escapeCsv(r.kodePihak),
        _escapeCsv(r.status),
        r.tglHadir ?? '',
      ].join(',');
      sb.writeln(line);
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = p.join(dir.path, 'absensi_${_fmtDate(date)}.csv');
    final file = File(filePath);
    await file.writeAsString(sb.toString());
    return file;
  }

  Future<File> generatePdf(DateTime date, Map<String, String> absentOverrides) async {
    final bytes = await generatePdfBytes(date, absentOverrides);
    final dir = await getApplicationDocumentsDirectory();
    final filePath = p.join(dir.path, 'absensi_${_fmtDate(date)}.pdf');
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<Uint8List> generatePdfBytes(DateTime date, Map<String, String> absentOverrides) async {
    final rows = await buildReportForDate(date, absentOverrides);
    final pdf = pw.Document();

    // Add a header and styled table
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pw.PageFormat.a4,
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Laporan Absensi', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.Text('Tanggal: ${DateFormat('yyyy-MM-dd').format(date)}', style: pw.TextStyle(fontSize: 12)),
              ]),
              pw.Container(child: pw.Text('Absensi Digital', style: pw.TextStyle(fontSize: 12)))
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ['No', 'Nama Lengkap', 'Nama Alias', 'Kode Pihak', 'Status', 'Waktu Hadir'],
            data: List<List<String>>.generate(rows.length, (i) {
              final r = rows[i];
              return [
                (i + 1).toString(),
                r.namaLengkap,
                r.namaAlias,
                r.kodePihak,
                r.status,
                r.tglHadir ?? '',
              ];
            }),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xffeeeeee)),
            cellPadding: const pw.EdgeInsets.all(6),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    return bytes;
  }

  Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Laporan Absensi: ${p.basename(file.path)}');
  }

  String _fmtDate(DateTime d) => DateFormat('yyyyMMdd').format(d);
  String _escapeCsv(String s) {
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"' + s.replaceAll('"', '""') + '"';
    }
    return s;
  }
}
