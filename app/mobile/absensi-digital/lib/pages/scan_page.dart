import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../data/database.dart';
import '../models/pihak.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController cameraController = MobileScannerController(
    facing: CameraFacing.front,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _isProcessing = false;

  Future<void> _handleScan(String code) async {
    // QR hanya berisi kode pihak
    final kodePihak = code.trim();

    // Simpan absensi
    final absensiId = await DatabaseHelper.instance.insertAbsensi(kodePihak);

    // Cek di tabel pihak
    final pihakRow = await DatabaseHelper.instance.getPihakByKode(kodePihak);

    if (pihakRow == null) {
      // masukkan sebagai pihak baru dengan flag_aktif = 0
      await DatabaseHelper.instance.insertPihakIfNotExists(kodePihak);
    }

    final known = pihakRow != null;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Absensi Tersimpan'),
        content: Text(
            'ID Absensi: $absensiId\nKode Pihak: $kodePihak\nDikenal di tabel pihak: ${known ? 'Ya' : 'Tidak (ditambahkan sebagai non-aktif)'}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    setState(() => _isProcessing = true);
    final code = barcodes.first.rawValue ?? '';

    if (code.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('QR Kosong'),
          content: Text('Kode QR kosong atau tidak terbaca.'),
        ),
      );
      setState(() => _isProcessing = false);
      return;
    }

    // Tangani scan: simpan ke sqlite dan kembalikan hasil
    await _handleScan(code);

    // Kembali ke halaman sebelumnya dengan kode sebagai hasil
    Navigator.of(context).pop(code);
    setState(() => _isProcessing = false);
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            allowDuplicates: false,
            onDetect: _onDetect,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 24),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Arahkan QR ke kamera depan', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
