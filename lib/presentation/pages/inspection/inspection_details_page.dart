import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/inspection_models.dart';
import '../../../data/models/document_attachment.dart';
import '../../widgets/photo_viewer.dart';
import '../../widgets/document_viewer.dart';
import '../../providers/app_providers.dart';

class InspectionDetailsPage extends ConsumerStatefulWidget {
  final String inspectionId;

  const InspectionDetailsPage({
    super.key,
    required this.inspectionId,
  });

  @override
  ConsumerState<InspectionDetailsPage> createState() => _InspectionDetailsPageState();
}

class _InspectionDetailsPageState extends ConsumerState<InspectionDetailsPage> {
  Inspection? _inspection;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInspectionData();
  }

  Future<void> _loadInspectionData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final inspection = await ref.read(enhancedInspectionRepositoryProvider).getInspectionById(widget.inspectionId);

      if (mounted) {
        setState(() {
          _inspection = inspection;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load inspection: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Details'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.reports),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInspectionData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_inspection == null) {
      return const Center(
        child: Text('Inspection not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInspectionHeader(),
          const SizedBox(height: 24),
          _buildInspectionItems(),
        ],
      ),
    );
  }

  Widget _buildInspectionHeader() {
    final inspection = _inspection!;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getInspectionTypeIcon(inspection.type),
                  size: 32,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getInspectionTypeText(inspection.type),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${inspection.id}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(inspection.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(inspection.status),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Vehicle Info
            Row(
              children: [
                Icon(Icons.directions_car, size: 20, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  '${inspection.vehicle.unitNumber} - ${inspection.vehicle.make} ${inspection.vehicle.model}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Driver Info
            Row(
              children: [
                Icon(Icons.person, size: 20, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  inspection.driverName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Date Info
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: AppColors.grey600),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(inspection.createdAt),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionItems() {
    final inspection = _inspection!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inspection Items',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...inspection.items.map((item) => _buildInspectionItemCard(item)),
      ],
    );
  }

  Widget _buildInspectionItemCard(InspectionItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Header
            Row(
              children: [
                Icon(
                  _getItemStatusIcon(item.status),
                  color: _getItemStatusColor(item.status),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.defectSeverity != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(item.defectSeverity!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.defectSeverity!.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            // Notes
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            
            // Photos
            if (item.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildPhotosSection(item.photoUrls),
            ],
            
            // Documents
            if (item.documentAttachments.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDocumentsSection(item.documentAttachments),
            ],
            
            // Checked info
            if (item.checkedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Checked: ${_formatDateTime(item.checkedAt!)}${item.checkedBy != null ? ' by ${item.checkedBy}' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosSection(List<String> photoUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library, size: 16, color: AppColors.primaryBlue),
            const SizedBox(width: 6),
            Text(
              'Photos (${photoUrls.length})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photoUrls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: GestureDetector(
                   onTap: () {
                     Navigator.of(context).push(
                       MaterialPageRoute(
                         builder: (context) => PhotoViewer(
                           photoUrls: [photoUrls[index]],
                           initialIndex: 0,
                         ),
                       ),
                     );
                   },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.grey100,
                          child: Icon(
                            Icons.broken_image,
                            color: AppColors.grey400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(List<DocumentAttachment> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, size: 16, color: AppColors.successGreen),
            const SizedBox(width: 6),
            Text(
              'Documents (${documents.length})',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...documents.map((doc) => _buildDocumentTile(doc)),
      ],
    );
  }

  Widget _buildDocumentTile(DocumentAttachment document) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DocumentViewer(
              document: document,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              _getDocumentIcon(document.type),
              size: 20,
              color: AppColors.successGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.fileName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (document.description?.isNotEmpty == true)
                    Text(
                      document.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              _formatFileSize(document.fileSizeBytes),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  IconData _getInspectionTypeIcon(InspectionType type) {
    switch (type) {
      case InspectionType.preTrip:
        return Icons.departure_board;
      case InspectionType.postTrip:
        return Icons.assignment_turned_in;
      case InspectionType.annual:
        return Icons.event_repeat;
    }
  }

  String _getInspectionTypeText(InspectionType type) {
    switch (type) {
      case InspectionType.preTrip:
        return 'Pre-Trip Inspection';
      case InspectionType.postTrip:
        return 'Post-Trip Inspection';
      case InspectionType.annual:
        return 'Annual Inspection';
    }
  }

  Color _getStatusColor(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.completed:
        return AppColors.successGreen;
      case InspectionStatus.inProgress:
        return AppColors.warningYellow;
      case InspectionStatus.failed:
        return AppColors.errorRed;
      case InspectionStatus.pending:
        return AppColors.warningYellow;
    }
  }

  String _getStatusText(InspectionStatus status) {
    switch (status) {
      case InspectionStatus.completed:
        return 'Completed';
      case InspectionStatus.inProgress:
        return 'In Progress';
      case InspectionStatus.failed:
        return 'Failed';
      case InspectionStatus.pending:
        return 'Pending';
    }
  }

  IconData _getItemStatusIcon(InspectionItemStatus status) {
    switch (status) {
      case InspectionItemStatus.passed:
        return Icons.check_circle;
      case InspectionItemStatus.failed:
        return Icons.cancel;
      case InspectionItemStatus.notApplicable:
        return Icons.remove_circle_outline;
    }
  }

  Color _getItemStatusColor(InspectionItemStatus status) {
    switch (status) {
      case InspectionItemStatus.passed:
        return AppColors.successGreen;
      case InspectionItemStatus.failed:
        return AppColors.errorRed;
      case InspectionItemStatus.notApplicable:
        return AppColors.grey400;
    }
  }

  Color _getSeverityColor(DefectSeverity severity) {
    switch (severity) {
      case DefectSeverity.minor:
        return AppColors.warningYellow;
      case DefectSeverity.major:
        return AppColors.warningYellow;
      case DefectSeverity.critical:
        return AppColors.errorRed;
      case DefectSeverity.outOfService:
        return AppColors.criticalRed;
    }
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf;
      case DocumentType.photo:
        return Icons.image;
      case DocumentType.scannedDocument:
        return Icons.scanner;
      case DocumentType.cdlLicense:
        return Icons.badge;
      case DocumentType.dotMedicalCard:
        return Icons.medical_services;
      case DocumentType.vehicleRegistration:
        return Icons.directions_car;
      case DocumentType.insuranceDocument:
        return Icons.security;
      case DocumentType.other:
        return Icons.description;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}