import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/inspection_models.dart';
import '../../data/models/document_attachment.dart';
import '../../data/repositories/enhanced_inspection_repository.dart';
import '../providers/app_providers.dart';
import '../widgets/document_scanner_widget.dart';

/// Document Scanner Page for inspection items
/// Integrates with specific inspection items to attach scanned documents
class DocumentScannerPage extends ConsumerStatefulWidget {
  final String inspectionId;
  final String inspectionItemId;
  final String itemName;
  final String itemCategory;

  const DocumentScannerPage({
    super.key,
    required this.inspectionId,
    required this.inspectionItemId,
    required this.itemName,
    required this.itemCategory,
  });

  @override
  ConsumerState<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends ConsumerState<DocumentScannerPage> {
  final EnhancedInspectionRepository _inspectionRepository = EnhancedInspectionRepository.instance;
  final Uuid _uuid = const Uuid();
  
  InspectionItem? _inspectionItem;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInspectionItem();
  }

  Future<void> _loadInspectionItem() async {
    try {
      final inspection = await _inspectionRepository.getInspectionById(widget.inspectionId);
      if (inspection != null) {
        final item = inspection.items.firstWhere(
          (item) => item.id == widget.inspectionItemId,
        );
        setState(() {
          _inspectionItem = item;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading inspection item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_inspectionItem == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Inspection item not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Paperwork - ${widget.itemName}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Item info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.itemName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.itemCategory,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (_inspectionItem!.documentAttachments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${_inspectionItem!.documentAttachments.length} document(s) attached',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Document Scanner Widget
          Expanded(
            child: DocumentScannerWidget(
              title: 'Scan ${_getDocumentTypeForItem()}',
              allowMultiplePages: _shouldAllowMultiplePages(),
              maxPages: 5,
              autoGeneratePdf: true, // Enable simplified scan-to-PDF workflow
              onDocumentsScanned: _onDocumentsScanned,
              onPdfGenerated: _onPdfGenerated,
            ),
          ),

          // Existing Documents
          if (_inspectionItem!.documentAttachments.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attached Documents',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _inspectionItem!.documentAttachments.length,
                      itemBuilder: (context, index) {
                        final doc = _inspectionItem!.documentAttachments[index];
                        return _buildDocumentThumbnail(doc, index);
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentThumbnail(DocumentAttachment doc, int index) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      child: Card(
        child: InkWell(
          onTap: () => _viewDocument(doc),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      doc.isPdf ? Icons.picture_as_pdf : Icons.image,
                      color: doc.isPdf ? Colors.red : Colors.blue,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  doc.typeDisplayName,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDocumentTypeForItem() {
    switch (widget.inspectionItemId) {
      case 'cdl_license':
        return 'CDL License';
      case 'dot_medical_card':
        return 'DOT Medical Card';
      case 'paperwork':
        return 'Vehicle Documents';
      default:
        return 'Documents';
    }
  }

  DocumentType _getDocumentTypeEnum() {
    switch (widget.inspectionItemId) {
      case 'cdl_license':
        return DocumentType.cdlLicense;
      case 'dot_medical_card':
        return DocumentType.dotMedicalCard;
      case 'paperwork':
        return DocumentType.vehicleRegistration;
      default:
        return DocumentType.scannedDocument;
    }
  }

  bool _shouldAllowMultiplePages() {
    // Allow multiple pages for paperwork items
    return widget.inspectionItemId == 'paperwork';
  }

  void _onDocumentsScanned(List<String> scannedPaths) {
    // For web platform, photos are captured directly and need to be saved immediately
    // since PDF generation is not available
    if (scannedPaths.isNotEmpty) {
      // Save the most recent photo (last in the list)
      final latestPhotoPath = scannedPaths.last;
      _attachDocumentToInspectionItem(latestPhotoPath, DocumentType.photo);
    }
  }

  Future<void> _onPdfGenerated(String pdfPath) async {
    await _attachDocumentToInspectionItem(pdfPath, DocumentType.pdf);
  }

  Future<void> _attachDocumentToInspectionItem(
    String filePath, 
    DocumentType? documentType,
  ) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Handle web platform blob URLs differently
      int fileSize;
      String fileName;
      
      if (filePath.startsWith('blob:')) {
        // For web platform blob URLs, we can't use File() constructor
        // Instead, we'll use a placeholder size and generate a filename
        fileSize = 0; // Will be updated when we implement proper blob handling
        fileName = 'captured_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else {
        // For mobile platforms, use File operations
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('File not found: $filePath');
        }
        
        final fileStats = await file.stat();
        fileSize = fileStats.size;
        fileName = file.path.split('/').last;
      }

      // Create document attachment
      final attachment = DocumentAttachment(
        id: _uuid.v4(),
        fileName: fileName,
        filePath: filePath,
        type: documentType ?? _getDocumentTypeEnum(),
        fileSizeBytes: fileSize,
        createdAt: DateTime.now(),
        description: 'Scanned document for ${widget.itemName}',
      );

      // Update inspection item with new attachment
      final updatedAttachments = List<DocumentAttachment>.from(
        _inspectionItem!.documentAttachments,
      )..add(attachment);

      final updatedItem = _inspectionItem!.copyWith(
        documentAttachments: updatedAttachments,
        checkedAt: DateTime.now(),
        status: InspectionItemStatus.passed, // Mark as passed when document is attached
      );

      // Save to repository
      await _inspectionRepository.updateInspectionItem(
        widget.inspectionId,
        updatedItem,
      );

      // Refresh the enhanced inspections provider state
      await ref.read(enhancedInspectionsProvider.notifier).updateInspectionItem(
        widget.inspectionId,
        updatedItem,
      );

      // Update local state
      setState(() {
        _inspectionItem = updatedItem;
      });

      _showSuccessSnackBar('Document attached successfully');
    } catch (e) {
      _showErrorSnackBar('Error attaching document: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _viewDocument(DocumentAttachment doc) {
    // TODO: Implement document viewer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doc.typeDisplayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${doc.fileName}'),
            Text('Size: ${doc.formattedFileSize}'),
            Text('Created: ${doc.createdAt.toString().split('.')[0]}'),
            if (doc.description != null)
              Text('Description: ${doc.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeDocument(doc);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeDocument(DocumentAttachment doc) async {
    try {
      // Remove from attachments list
      final updatedAttachments = _inspectionItem!.documentAttachments
          .where((attachment) => attachment.id != doc.id)
          .toList();

      final updatedItem = _inspectionItem!.copyWith(
        documentAttachments: updatedAttachments,
      );

      // Save to repository
      await _inspectionRepository.updateInspectionItem(
        widget.inspectionId,
        updatedItem,
      );

      // Update local state
      setState(() {
        _inspectionItem = updatedItem;
      });

      // Delete file
      try {
        final file = File(doc.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // File deletion error is not critical
        debugPrint('Error deleting file: $e');
      }

      _showSuccessSnackBar('Document removed');
    } catch (e) {
      _showErrorSnackBar('Error removing document: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}