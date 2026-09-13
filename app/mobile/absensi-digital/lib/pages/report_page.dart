import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database.dart';
import '../services/report_service.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, String> _overrides =
      {}; // kode_unik -> status ('ijin' or 'alpha')
  List<Map<String, dynamic>> _pihakList = [];
  Set<String> _presentCodes = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPihak();
  }

  Future<void> _loadPihak() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('pihak', orderBy: 'nama');
    final attendanceRows =
        await DatabaseHelper.instance.getAbsensiByDate(_selectedDate);
    setState(() {
      _pihakList = rows;
      _presentCodes =
          attendanceRows.map((row) => row['kode_unik'] as String).toSet();
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() => _selectedDate = d);
      await _loadPihak();
    }
  }

  Widget _buildPihakRow(Map<String, dynamic> p) {
    final kode = p['kode_unik'] as String;
    final isPresent = _presentCodes.contains(kode);
    final current = isPresent ? 'hadir' : (_overrides[kode] ?? 'alpha');
    return ListTile(
      title: Text(p['nama'] as String? ?? ''),
      subtitle: Text(kode),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: current,
            items: const [
              DropdownMenuItem(value: 'hadir', child: Text('Hadir')),
              DropdownMenuItem(value: 'ijin', child: Text('Ijin')),
              DropdownMenuItem(value: 'alpha', child: Text('Alpha')),
              DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
            ],
            onChanged: isPresent
                ? null
                : (v) {
                    setState(() {
                      _overrides[kode] = v ?? 'alpha';
                    });
                  },
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndShare(String type) async {
    final service = ReportService();
    try {
      late final file;
      if (type == 'json')
        file = await service.generateJson(_selectedDate, _overrides);
      if (type == 'csv')
        file = await service.generateCsv(_selectedDate, _overrides);
      if (type == 'pdf')
        file = await service.generatePdf(_selectedDate, _overrides);

      if (file != null) {
        await service.shareFile(file);
      }
    } catch (e) {
      await showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
                  title: const Text('Error'),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'))
                  ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Laporan Absensi')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ListTile(
                  title: const Text('Tanggal'),
                  subtitle: Text(dateLabel),
                  trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'Pihak yang sudah memindai otomatis berstatus Hadir. Atur status lainnya di bawah.'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _pihakList.length,
                    itemBuilder: (_, i) => _buildPihakRow(_pihakList[i]),
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () => _generateAndShare('pdf'),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('PDF')),
                      ElevatedButton.icon(
                          onPressed: () => _generateAndShare('csv'),
                          icon: const Icon(Icons.table_chart),
                          label: const Text('CSV')),
                      ElevatedButton.icon(
                          onPressed: () => _generateAndShare('json'),
                          icon: const Icon(Icons.code),
                          label: const Text('JSON')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
