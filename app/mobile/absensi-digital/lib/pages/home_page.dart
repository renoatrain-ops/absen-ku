import 'package:flutter/material.dart';
import 'scan_page.dart';
import 'report_page.dart';
import 'history_page.dart';
import 'pihak_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _openPage(BuildContext context, Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Absensi Digital')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan QR Absensi'),
                onPressed: () => _openPage(context, const ScanPage()),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.file_download),
                label: const Text('Generate Laporan'),
                onPressed: () => _openPage(context, const ReportPage()),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('History Absensi'),
                onPressed: () => _openPage(context, const HistoryPage()),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.group),
                label: const Text('Manajemen Pihak'),
                onPressed: () => _openPage(context, const PihakPage()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
