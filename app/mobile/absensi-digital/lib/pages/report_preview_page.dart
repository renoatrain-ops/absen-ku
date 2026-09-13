import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/report_service.dart';

class ReportPreviewPage extends StatefulWidget {
  final DateTime date;
  final Map<String, String> overrides;

  const ReportPreviewPage({super.key, required this.date, required this.overrides});

  @override
  State<ReportPreviewPage> createState() => _ReportPreviewPageState();
}

class _ReportPreviewPageState extends State<ReportPreviewPage> {
  final ReportService _service = ReportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview PDF')),
      body: PdfPreview(
        build: (format) async {
          final bytes = await _service.generatePdfBytes(widget.date, widget.overrides);
          return bytes;
        },
      ),
    );
  }
}
