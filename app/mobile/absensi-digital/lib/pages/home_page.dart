import 'package:flutter/material.dart';
import 'scan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _lastCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi Digital')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR (Kamera Depan)'),
              onPressed: () async {
                final result = await Navigator.push<String?>(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanPage()),
                );
                if (result != null) {
                  setState(() => _lastCode = result);
                }
              },
            ),
            const SizedBox(height: 24),
            const Text('Hasil Scan Terakhir:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(_lastCode ?? 'Belum ada scan'),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: Container()),
            const Text('Catatan: Pastikan aplikasi memiliki izin kamera dan perangkat mendukung kamera depan.'),
          ],
        ),
      ),
    );
  }
}
