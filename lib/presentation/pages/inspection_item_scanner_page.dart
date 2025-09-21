import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/inspection_models.dart';
import '../../data/models/document_attachment.dart';
import '../../data/repositories/enhanced_inspection_repository.dart';
import '../widgets/document_scanner_widget.dart';
import '../providers/app_providers.dart';

/// Page for scanning documents for specific inspection items
class InspectionItemScannerPage extends ConsumerStatefulWidget {
  final String inspectionId;
  final String itemId;
  final String itemName;

  const InspectionItemScannerPage({
    super.key,
    required this.inspectionId,
    required this.itemId,
    required this.itemName,
  });

  @override
  ConsumerState<InspectionItemScannerPage> createState() => _InspectionItemScannerPageState();
}

class _InspectionItemScannerPageState extends ConsumerState<InspectionItemScannerPage> {
  InspectionItem? _currentItem;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInspectionItem();
  }

  Future<void> _loadInspectionItem() async {
    try {
      final repository = ref.read(enhancedInspectionRepositoryProvider);
      final inspection = await repository.getInspectionById(widget.inspectionId);
      
      if (inspection != null) {
        final item = inspection.items.firstWhere(
          (item) => item.id == widget.itemId,
          orElse: () => throw Exception('Item not found'),
        );
        
        setState(() {
          _currentItem = item;
          _isLoading = false;
        });
      } else {
        throw Exception('Inspection not found');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading inspection item: $e')),
        );
      }
    }
  }

  Future<void> _onDocumentsUpdated(List<DocumentAttachment> documents) async {
    if (_currentItem == null) return;

    try {
      final repository = ref.read(inspectionRepositoryProvider);
      
      // Update the item with new document attachments
      final updatedItem = _currentItem!.copyWith(
        documentAttachments: documents,
      );

      // Update the inspection item in the repository
      await repository.updateInspectionItem(widget.inspectionId, updatedItem);

      setState(() {
        _currentItem = updatedItem;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documents updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating documents: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Documents - ${widget.itemName}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentItem == null
              ? const Center(child: Text('Item not found'))
              : DocumentScannerWidget(
                  initialDocuments: _currentItem!.documentAttachments,
                  autoGeneratePdf: true, // Enable simplified scan-to-PDF workflow
                  onDocumentsChanged: _onDocumentsUpdated,
                ),
    );
  }
}