import 'package:flutter/material.dart';
import '../data/database.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await DatabaseHelper.instance.getAbsensiByDate(_selectedDate);
    setState(() {
      _items = rows;
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
      await _load();
    }
  }

  Future<void> _delete(int id) async {
    await DatabaseHelper.instance.deleteAbsensi(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final label = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return Scaffold(
      appBar: AppBar(title: const Text('History Absensi')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Tanggal'),
            subtitle: Text(label),
            trailing: IconButton(
                icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
          ),
          const Divider(),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: _items.isEmpty
                      ? const Center(
                          child: Text('Belum ada absensi untuk tanggal ini.'))
                      : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (_, i) {
                            final item = _items[i];
                            final nama = item['nama'] as String? ?? '';
                            final kode = item['kode_unik'] as String;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Text(
                                    nama.isEmpty ? '?' : nama.substring(0, 1)),
                              ),
                              title: Text(
                                  nama.isEmpty ? 'Pihak tidak dikenal' : nama),
                              subtitle: Text(
                                  '$kode  |  ${DateFormat('HH:mm:ss').format(DateTime.parse(item['tgl_hadir'] as String))}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _delete(item['id_absensi'] as int),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }
}
