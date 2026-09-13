import 'package:flutter/material.dart';
import '../data/database.dart';

class PihakPage extends StatefulWidget {
  const PihakPage({super.key});

  @override
  State<PihakPage> createState() => _PihakPageState();
}

class _PihakPageState extends State<PihakPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await DatabaseHelper.instance.getAllPihak();
    setState(() {
      _items = rows;
      _loading = false;
    });
  }

  Future<void> _showEditDialog({Map<String, dynamic>? item}) async {
    final namaCtl = TextEditingController(text: item?['nama'] as String? ?? '');
    final tipeCtl = TextEditingController(text: item?['tipe'] as String? ?? '');
    final kodeCtl = TextEditingController(text: item?['kode_unik'] as String? ?? '');
    final indukCtl = TextEditingController(text: item?['kode_induk'] as String? ?? '');
    final flagCtl = TextEditingController(text: item?['flag'] as String? ?? '');
    final gradeCtl = TextEditingController(text: item?['grade'] as String? ?? '');
    bool aktif = (item?['aktif'] as int? ?? 0) == 1;

    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Tambah Pihak' : 'Edit Pihak'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: namaCtl, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: tipeCtl, decoration: const InputDecoration(labelText: 'Tipe')),
              TextField(controller: kodeCtl, decoration: const InputDecoration(labelText: 'Kode Unik')),
              TextField(controller: indukCtl, decoration: const InputDecoration(labelText: 'Kode Induk')),
              TextField(controller: flagCtl, decoration: const InputDecoration(labelText: 'Flag')),
              TextField(controller: gradeCtl, decoration: const InputDecoration(labelText: 'Grade')),
              Row(
                children: [
                  const Text('Aktif'),
                  Switch(value: aktif, onChanged: (v) => setState(() => aktif = v)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final map = {
                'id': item?['id'] ?? DateTime.now().millisecondsSinceEpoch,
                'id_pihak': item?['id_pihak'] ?? kodeCtl.text,
                'tipe': tipeCtl.text,
                'nama': namaCtl.text,
                'kode_unik': kodeCtl.text,
                'kode_induk': indukCtl.text,
                'flag': flagCtl.text,
                'grade': gradeCtl.text,
                'aktif': aktif ? 1 : 0,
              };
              if (item == null) {
                await DatabaseHelper.instance.insertPihak(map);
              } else {
                await DatabaseHelper.instance.updatePihak(item['id'] as int, map);
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (res == true) await _load();
  }

  Future<void> _delete(int id) async {
    final yes = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Konfirmasi'), content: const Text('Hapus pihak ini?'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')), ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Hapus'))]));
    if (yes == true) {
      await DatabaseHelper.instance.deletePihak(id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Pihak')),
      floatingActionButton: FloatingActionButton(onPressed: () => _showEditDialog(), child: const Icon(Icons.add)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final p = _items[i];
                return ListTile(
                  title: Text(p['nama'] as String? ?? ''),
                  subtitle: Text('${p['id_pihak']} - ${p['kode_unik']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(item: p)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(p['id'] as int)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
