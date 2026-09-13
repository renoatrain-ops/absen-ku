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
  Map<String, String> _overrides = {}; // kode_pihak -> status ('ijin' or 'alpha')
  List<Map<String, dynamic>> _pihakList = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPihak();
  }

  Future<void> _loadPihak() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('pihak', orderBy: 'nama_alias');
    setState(() {
      _pihakList = rows;
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
    if (d != null) setState(() => _selectedDate = d);
  }

  Widget _buildPihakRow(Map<String, dynamic> p) {
    final kode = p['kode_pihak'] as String;
    final current = _overrides[kode] ?? 'alpha';
    return ListTile(
      title: Text(p['nama_lengkap'] as String? ?? ''),
      subtitle: Text(kode),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: current,
            items: const [
              DropdownMenuItem(value: 'alpha', child: Text('Alpha')),
              DropdownMenuItem(value: 'ijin', child: Text('Ijin')),
            ],
            onChanged: (v) {
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
      if (type == 'json') file = await service.generateJson(_selectedDate, _overrides);
      if (type == 'csv') file = await service.generateCsv(_selectedDate, _overrides);
      if (type == 'pdf') file = await service.generatePdf(_selectedDate, _overrides);

      if (file != null) {
        await service.shareFile(file);
      }
    } catch (e) {
      await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('Error'), content: Text(e.toString()), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))]));
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
                  trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Set status untuk pihak yang tidak hadir (default: Alpha)'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _pihakList.length,
                    itemBuilder: (_, i) => _buildPihakRow(_pihakList[i]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(onPressed: () => _generateAndShare('pdf'), icon: const Icon(Icons.picture_as_pdf), label: const Text('PDF')),
                      ElevatedButton.icon(onPressed: () => _generateAndShare('csv'), icon: const Icon(Icons.table_chart), label: const Text('CSV')),
                      ElevatedButton.icon(onPressed: () => _generateAndShare('json'), icon: const Icon(Icons.code), label: const Text('JSON')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
