import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';
import 'dart:convert';

import '../../../generated/l10n/app_localizations.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_router.dart';
import '../../../data/models/inspection_models.dart';
import '../../providers/app_providers.dart';

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
    final inspections = ref.read(enhancedInspectionsProvider);
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseProvideSignature),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save signature and complete inspection
      final signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes == null) {
        throw Exception('Failed to generate signature');
      }
      final signatureBase64 = base64Encode(signatureBytes);
      
      // Complete the inspection using the enhanced provider
      await ref.read(enhancedInspectionsProvider.notifier).completeInspection(
        widget.inspectionId,
        signatureBase64,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      
      // Navigate back to dashboard with success message using GoRouter
      context.goToDashboard();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.inspectionCompletedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing inspection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          title: Text(AppLocalizations.of(context)!.digitalSignature),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final completedItems = _inspection!.items.where(
      (item) => item.checkedAt != null,
    ).length;
    final failedItems = _inspection!.failedItemsCount;
    final hasCriticalDefects = _inspection!.hasCriticalDefects;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.completeInspection),
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
                                '${_getInspectionTypeText()} ${AppLocalizations.of(context)!.inspection}',
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
                            AppLocalizations.of(context)!.completed,
                            '$completedItems/${_inspection!.items.length}',
                            AppColors.infoBlue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            AppLocalizations.of(context)!.failed,
                            failedItems.toString(),
                            failedItems > 0 ? AppColors.errorRed : AppColors.successGreen,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            AppLocalizations.of(context)!.status,
                            hasCriticalDefects ? AppLocalizations.of(context)!.critical : AppLocalizations.of(context)!.ok,
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
                                  Text(
                                    AppLocalizations.of(context)!.criticalDefectsFound,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.errorRed,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppLocalizations.of(context)!.criticalDefectsWarning,
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
              AppLocalizations.of(context)!.overallNotes,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.overallNotesHint,
                border: const OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Signature section
            Text(
              AppLocalizations.of(context)!.driverSignature,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.signatureInstruction,
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
                    label: Text(AppLocalizations.of(context)!.clear),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${AppLocalizations.of(context)!.driver}: $_driverName',
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
                        AppLocalizations.of(context)!.certification,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.certificationText,
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
                  child: Text(AppLocalizations.of(context)!.backToInspection),
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
                      : Text(AppLocalizations.of(context)!.completeInspection),
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
    final l10n = AppLocalizations.of(context)!;
    switch (_inspection!.type) {
      case InspectionType.preTrip:
        return l10n.preTrip;
      case InspectionType.postTrip:
        return l10n.postTrip;
      case InspectionType.annual:
        return l10n.annual;
    }
  }
}