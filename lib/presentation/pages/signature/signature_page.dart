import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/inspection_models.dart';
import '../../providers/app_providers.dart';
import '../report/report_preview_page.dart';

/// Digital signature page for inspection completion
class SignaturePage extends ConsumerStatefulWidget {
  final String inspectionId;
  
  const SignaturePage({super.key, required this.inspectionId});

  @override
  ConsumerState<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends ConsumerState<SignaturePage> {
  late SignatureController _signatureController;
  bool _isLoading = false;
  Inspection? _inspection;
  String _driverName = '';
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: AppColors.primaryBlue,
      exportBackgroundColor: AppColors.white,
    );
    _loadInspection();
  }

  @override
  void dispose() {
    _signatureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadInspection() {
    final inspections = ref.read(inspectionsProvider);
    _inspection = inspections.firstWhere(
      (inspection) => inspection.id == widget.inspectionId,
      orElse: () => throw Exception('Inspection not found'),
    );
    
    if (_inspection != null) {
      _driverName = _inspection!.driverName;
      setState(() {});
    }
  }

  Future<void> _completeInspection() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide your signature'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Convert signature to base64 string
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes == null) {
        throw Exception('Failed to capture signature');
      }

      final String signatureBase64 = _bytesToBase64(signatureBytes);
      
      // Complete the inspection
      await ref.read(inspectionsProvider.notifier).completeInspection(
        widget.inspectionId,
        'data:image/png;base64,$signatureBase64',
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inspection completed successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        // Navigate to report preview
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReportPreviewPage(inspectionId: widget.inspectionId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to complete inspection: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _bytesToBase64(Uint8List bytes) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    int pad = bytes.length % 3;
    String result = '';
    
    for (int i = 0; i < bytes.length; i += 3) {
      int b1 = bytes[i];
      int b2 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      int b3 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      
      int bitmap = (b1 << 16) | (b2 << 8) | b3;
      
      result += chars[(bitmap >> 18) & 63];
      result += chars[(bitmap >> 12) & 63];
      result += chars[(bitmap >> 6) & 63];
      result += chars[bitmap & 63];
    }
    
    if (pad == 1) {
      result = '${result.substring(0, result.length - 2)}==';
    } else if (pad == 2) {
      result = '${result.substring(0, result.length - 1)}=';
    }
    
    return result;
  }

  void _clearSignature() {
    _signatureController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_inspection == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Digital Signature'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final completedItems = _inspection!.items.where(
      (item) => item.status != InspectionItemStatus.notChecked,
    ).length;
    final failedItems = _inspection!.failedItemsCount;
    final hasCriticalDefects = _inspection!.hasCriticalDefects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Inspection'),
        backgroundColor: hasCriticalDefects 
            ? AppColors.errorRed 
            : AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inspection summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment_turned_in,
                          color: hasCriticalDefects 
                              ? AppColors.errorRed 
                              : AppColors.successGreen,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getInspectionTypeText()} Inspection',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_inspection!.vehicle.unitNumber} - ${_inspection!.vehicle.make} ${_inspection!.vehicle.model}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Inspection stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Completed',
                            '$completedItems/${_inspection!.items.length}',
                            AppColors.infoBlue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Failed',
                            failedItems.toString(),
                            failedItems > 0 ? AppColors.errorRed : AppColors.successGreen,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Status',
                            hasCriticalDefects ? 'Critical' : 'OK',
                            hasCriticalDefects ? AppColors.errorRed : AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                    
                    // Warning for critical defects
                    if (hasCriticalDefects) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.errorRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: AppColors.errorRed,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Critical Defects Found',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.errorRed,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'This vehicle has critical defects that may require immediate attention.',
                                    style: TextStyle(
                                      color: AppColors.errorRed.withValues(alpha: 0.8),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Overall notes section
            Text(
              'Overall Notes (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add any overall notes about this inspection...',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Signature section
            Text(
              'Driver Signature',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please sign below to certify that you have completed this inspection.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Signature pad
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey300, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: AppColors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Signature controls
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearSignature,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Driver: $_driverName',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Completion disclaimer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Certification',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By signing below, I certify that I have completed this pre-trip inspection in accordance with DOT regulations and that all defects have been properly documented.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Back to Inspection'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeInspection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasCriticalDefects 
                        ? AppColors.errorRed 
                        : AppColors.successGreen,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        )
                      : const Text('Complete Inspection'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  String _getInspectionTypeText() {
    switch (_inspection!.type) {
      case InspectionType.preTrip:
        return 'Pre-Trip';
      case InspectionType.postTrip:
        return 'Post-Trip';
      case InspectionType.annual:
        return 'Annual';
    }
  }
}