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
    final namaCtl = TextEditingController(text: item?['nama_lengkap'] as String? ?? '');
    final aliasCtl = TextEditingController(text: item?['nama_alias'] as String? ?? '');
    final kodeCtl = TextEditingController(text: item?['kode_pihak'] as String? ?? '');
    bool aktif = (item?['flag_aktif'] as int? ?? 0) == 1;

    final res = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Tambah Pihak' : 'Edit Pihak'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: namaCtl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
              TextField(controller: aliasCtl, decoration: const InputDecoration(labelText: 'Nama Alias')),
              TextField(controller: kodeCtl, decoration: const InputDecoration(labelText: 'Kode Pihak')),
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
                'nama_lengkap': namaCtl.text,
                'nama_alias': aliasCtl.text,
                'kode_pihak': kodeCtl.text,
                'flag_aktif': aktif ? 1 : 0,
              };
              if (item == null) {
                await DatabaseHelper.instance.insertPihak(map);
              } else {
                await DatabaseHelper.instance.updatePihak(item['id_pihak'] as int, map);
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
                  title: Text(p['nama_lengkap'] as String? ?? ''),
                  subtitle: Text(p['kode_pihak'] as String? ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(item: p)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(p['id_pihak'] as int)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
