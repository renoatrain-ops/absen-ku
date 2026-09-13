diff --git a/app/mobile/absensi-digital/lib/pages/home_page.dart b/app/mobile/absensi-digital/lib/pages/home_page.dart
index 0000000..0000000 100644
--- a/app/mobile/absensi-digital/lib/pages/home_page.dart
+++ b/app/mobile/absensi-digital/lib/pages/home_page.dart
@@
 import 'package:flutter/material.dart';
 import 'scan_page.dart';
 import 'report_page.dart';
+import 'history_page.dart';
+import 'pihak_page.dart';
@@
             ElevatedButton.icon(
               icon: const Icon(Icons.file_download),
               label: const Text('Generate Laporan'),
               onPressed: () async {
                 await Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportPage()));
               },
             ),
+            const SizedBox(height: 12),
+            ElevatedButton.icon(
+              icon: const Icon(Icons.history),
+              label: const Text('History Absensi'),
+              onPressed: () async {
+                await Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
+              },
+            ),
+            const SizedBox(height: 12),
+            ElevatedButton.icon(
+              icon: const Icon(Icons.group),
+              label: const Text('Manajemen Pihak'),
+              onPressed: () async {
+                await Navigator.push(context, MaterialPageRoute(builder: (_) => const PihakPage()));
+              },
+            ),
