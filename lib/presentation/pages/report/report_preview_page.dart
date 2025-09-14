import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../core/themes/app_theme.dart';
import '../../../data/models/inspection_models.dart';
import '../../providers/app_providers.dart';
import '../dashboard/dashboard_page.dart';

/// Report preview and PDF generation page
class ReportPreviewPage extends ConsumerStatefulWidget {
  final String inspectionId;
  
  const ReportPreviewPage({super.key, required this.inspectionId});

  @override
  ConsumerState<ReportPreviewPage> createState() => _ReportPreviewPageState();
}

class _ReportPreviewPageState extends ConsumerState<ReportPreviewPage> {
  Inspection? _inspection;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadInspection();
  }

  void _loadInspection() {
    final inspections = ref.read(inspectionsProvider);
    _inspection = inspections.firstWhere(
      (inspection) => inspection.id == widget.inspectionId,
      orElse: () => throw Exception('Inspection not found'),
    );
    setState(() {});
  }

  Future<void> _generateAndDownloadPdf() async {
    if (_inspection == null) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdf = await _generatePdf(_inspection!);
      
      if (kIsWeb) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf,
          name: 'PTI_Report_${_inspection!.vehicle.unitNumber}_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        await Printing.sharePdf(
          bytes: pdf,
          filename: 'PTI_Report_${_inspection!.vehicle.unitNumber}.pdf',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF report generated successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  Future<Uint8List> _generatePdf(Inspection inspection) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Pre-Trip Inspection Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildPdfHeader(inspection),
            pw.SizedBox(height: 20),
            _buildPdfSummary(inspection),
            pw.SizedBox(height: 20),
            _buildPdfDefects(inspection),
          ];
        },
      ),
    );
    
    return pdf.save();
  }

  pw.Widget _buildPdfHeader(Inspection inspection) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Vehicle: ${inspection.vehicle.unitNumber}'),
              pw.Text('Date: ${_formatDate(inspection.createdAt)}'),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text('Driver: ${inspection.driverName}'),
          pw.Text('${inspection.vehicle.make} ${inspection.vehicle.model} (${inspection.vehicle.year})'),
        ],
      ),
    );
  }

  pw.Widget _buildPdfSummary(Inspection inspection) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Inspection Summary',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Total Items: ${inspection.items.length}'),
          pw.Text('Passed: ${inspection.passedItemsCount}'),
          pw.Text('Failed: ${inspection.failedItemsCount}'),
          pw.Text('Status: ${inspection.hasCriticalDefects ? "CRITICAL DEFECTS" : "PASSED"}'),
        ],
      ),
    );
  }

  pw.Widget _buildPdfDefects(Inspection inspection) {
    final failedItems = inspection.items.where((item) => item.status == InspectionItemStatus.failed).toList();
    
    if (failedItems.isEmpty) {
      return pw.Text('No defects found.');
    }
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Defects Found',
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        ...failedItems.map((item) => pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(item.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Category: ${item.category}'),
              if (item.defectSeverity != null)
                pw.Text('Severity: ${item.defectSeverity.toString().split('.').last}'),
              if (item.notes != null && item.notes!.isNotEmpty)
                pw.Text('Notes: ${item.notes}'),
            ],
          ),
        )).toList(),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_inspection == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report Preview')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _isGeneratingPdf ? null : _generateAndDownloadPdf,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inspection Complete!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: _inspection!.hasCriticalDefects ? AppColors.errorRed : AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Vehicle: ${_inspection!.vehicle.unitNumber}'),
                    Text('Driver: ${_inspection!.driverName}'),
                    Text('Completed: ${_formatDate(_inspection!.completedAt!)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isGeneratingPdf ? null : _generateAndDownloadPdf,
              child: _isGeneratingPdf
                  ? const CircularProgressIndicator()
                  : const Text('Generate PDF Report'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                  (route) => false,
                );
              },
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}