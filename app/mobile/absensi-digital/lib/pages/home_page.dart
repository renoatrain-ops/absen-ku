diff --git a/app/mobile/absensi-digital/lib/pages/home_page.dart b/app/mobile/absensi-digital/lib/pages/home_page.dart
index 0000000..0000000 100644
--- a/app/mobile/absensi-digital/lib/pages/home_page.dart
+++ b/app/mobile/absensi-digital/lib/pages/home_page.dart
@@
 import 'package:flutter/material.dart';
 import 'scan_page.dart';
+import 'report_page.dart';
@@
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
+            const SizedBox(height: 12),
+            ElevatedButton.icon(
+              icon: const Icon(Icons.file_download),
+              label: const Text('Generate Laporan'),
+              onPressed: () async {
+                await Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportPage()));
+              },
+            ),
