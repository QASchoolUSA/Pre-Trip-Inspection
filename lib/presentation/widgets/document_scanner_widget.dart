import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/document_scanner_service.dart';
import '../../data/models/document_attachment.dart';

/// Document Scanner Widget with CamScanner-like interface
/// Provides intuitive controls for document scanning and processing
class DocumentScannerWidget extends StatefulWidget {
  final Function(List<String> scannedPaths)? onDocumentsScanned;
  final Function(String pdfPath)? onPdfGenerated;
  final Function(List<DocumentAttachment> documents)? onDocumentsChanged;
  final List<DocumentAttachment>? initialDocuments;
  final bool allowMultiplePages;
  final int maxPages;
  final String? title;
  final bool autoGeneratePdf; // New parameter for simplified workflow

  const DocumentScannerWidget({
    super.key,
    this.onDocumentsScanned,
    this.onPdfGenerated,
    this.onDocumentsChanged,
    this.initialDocuments,
    this.allowMultiplePages = false,
    this.maxPages = 5,
    this.title,
    this.autoGeneratePdf = true, // Default to simplified workflow
  });

  @override
  State<DocumentScannerWidget> createState() => _DocumentScannerWidgetState();
}

class _DocumentScannerWidgetState extends State<DocumentScannerWidget> {
  final DocumentScannerService _scannerService = DocumentScannerService();
  List<String> _scannedImages = [];
  List<DocumentAttachment> _documentAttachments = [];
  bool _isScanning = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing documents if provided
    if (widget.initialDocuments != null) {
      _documentAttachments = List.from(widget.initialDocuments!);
      _scannedImages = _documentAttachments.map((doc) => doc.filePath).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Scanner Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isScanning ? null : (_canScanMore() ? _scanDocument : null),
                      icon: _isScanning 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.document_scanner),
                      label: Text(_isScanning ? 'Scanning...' : (_canScanMore() ? 'Scan Document' : 'Document Attached')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canScanMore() ? Theme.of(context).primaryColor : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _canScanMore() ? _pickFromGallery : null,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canScanMore() ? Colors.grey[600] : Colors.grey[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.allowMultiplePages && _scannedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_scannedImages.length}/${widget.maxPages} pages',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Scanned Images Display
        Expanded(
          child: _scannedImages.isEmpty 
            ? _buildEmptyState()
            : _buildImagesList(),
        ),
        
        // Bottom Actions
        if (_scannedImages.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                // Only show Generate PDF button if autoGeneratePdf is disabled
                if (!widget.autoGeneratePdf) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _generatePdf,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf),
                      label: Text(_isProcessing ? 'Processing...' : 'Generate PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No documents scanned yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Scan Document" to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scannedImages.length,
      itemBuilder: (context, index) {
        final imagePath = _scannedImages[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: kIsWeb
                    ? (imagePath.startsWith('data:')
                        ? Image.memory(
                            base64Decode(imagePath.split(',')[1]),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
                              );
                            },
                          )
                        : Image.network(
                            imagePath,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
                              );
                            },
                          ))
                    : Image.file(
                        File(imagePath),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                          );
                        },
                      ),
              ),
              
              // Image Actions
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Text(
                      'Page ${index + 1}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _enhanceImage(index),
                      icon: const Icon(Icons.auto_fix_high),
                      tooltip: 'Enhance',
                    ),
                    IconButton(
                      onPressed: () => _cropImage(index),
                      icon: const Icon(Icons.crop),
                      tooltip: 'Crop',
                    ),
                    IconButton(
                      onPressed: () => _removeImage(index),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Remove',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _canScanMore() {
    if (widget.allowMultiplePages) {
      return _scannedImages.length < widget.maxPages;
    } else {
      return _scannedImages.isEmpty;
    }
  }

  Future<void> _scanDocument() async {
    if (!widget.allowMultiplePages && _scannedImages.isNotEmpty) {
      _showSnackBar('Only one document allowed');
      return;
    }

    if (_scannedImages.length >= widget.maxPages) {
      _showSnackBar('Maximum ${widget.maxPages} pages allowed');
      return;
    }

    setState(() {
      _isScanning = true;
    });

    try {
      debugPrint('DocumentScannerWidget: Starting document scan...');
      
      // For web, skip PDF generation and just capture photos
      if (kIsWeb) {
        debugPrint('DocumentScannerWidget: Web platform - capturing photo without PDF conversion');
        String? scannedPath;
        
        try {
          scannedPath = await _scannerService.scanDocument();
          debugPrint('DocumentScannerWidget: Photo capture result: $scannedPath');
        } catch (e) {
          debugPrint('DocumentScannerWidget: Photo capture failed: $e');
          _showSnackBar('Photo capture failed: $e');
          scannedPath = null;
        }
        
        if (scannedPath != null) {
          // For web, we can't get file size from blob URLs, so use a default value
          int fileSizeBytes = 0;
          if (!kIsWeb) {
            try {
              fileSizeBytes = await File(scannedPath).length();
            } catch (e) {
              debugPrint('DocumentScannerWidget: Could not get file size: $e');
              fileSizeBytes = 0;
            }
          }
          
          final documentAttachment = DocumentAttachment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fileName: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
            filePath: scannedPath,
            type: DocumentType.photo,
            fileSizeBytes: fileSizeBytes,
            createdAt: DateTime.now(),
          );

          setState(() {
            _scannedImages.add(scannedPath!);
            _documentAttachments.add(documentAttachment);
          });
          
          _showSnackBar('Photo captured successfully');
          widget.onDocumentsScanned?.call(_scannedImages);
          widget.onDocumentsChanged?.call(_documentAttachments);
          
          // Haptic feedback
          HapticFeedback.lightImpact();
        } else {
          debugPrint('DocumentScannerWidget: Photo capture returned null');
          _showSnackBar('Photo capture cancelled or failed');
        }
      } else if (widget.autoGeneratePdf) {
        // Mobile: Simplified workflow: scan and automatically generate PDF
        String? pdfPath;
        
        try {
          pdfPath = widget.allowMultiplePages 
            ? await _scannerService.scanMultipleDocumentsToPdf(
                maxPages: widget.maxPages,
                fileName: 'scanned_document_${DateTime.now().millisecondsSinceEpoch}.pdf',
              )
            : await _scannerService.scanDocumentToPdf(
                fileName: 'scanned_document_${DateTime.now().millisecondsSinceEpoch}.pdf',
              );
        } catch (pdfError) {
          debugPrint('DocumentScannerWidget: PDF generation failed: $pdfError');
          _showSnackBar('Failed to generate PDF: $pdfError');
          pdfPath = null;
        }
        
        if (pdfPath != null) {
          // Create PDF document attachment
          final pdfAttachment = DocumentAttachment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fileName: pdfPath.split('/').last,
            filePath: pdfPath,
            type: DocumentType.pdf,
            fileSizeBytes: await File(pdfPath).length(),
            createdAt: DateTime.now(),
          );

          setState(() {
            _documentAttachments.add(pdfAttachment);
            // For simplified workflow, we don't store individual images
            _scannedImages.clear();
          });
          
          _showSnackBar('Document scanned and PDF generated successfully');
          widget.onPdfGenerated?.call(pdfPath);
          widget.onDocumentsChanged?.call(_documentAttachments);
          
          // Haptic feedback
          HapticFeedback.lightImpact();
        } else {
          debugPrint('DocumentScannerWidget: Scan-to-PDF failed');
          _showSnackBar('Scan cancelled or failed');
        }
      } else {
        // Original workflow: scan individual images
        String? scannedPath;
        
        try {
          scannedPath = await _scannerService.scanDocument();
          debugPrint('DocumentScannerWidget: Scan result: $scannedPath');
        } catch (e) {
          debugPrint('DocumentScannerWidget: Scanning failed: $e');
          _showSnackBar('Scan cancelled or failed: $e');
          scannedPath = null;
        }
        
        if (scannedPath != null) {
          final documentAttachment = DocumentAttachment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fileName: 'scanned_${DateTime.now().millisecondsSinceEpoch}.jpg',
            filePath: scannedPath,
            type: DocumentType.scannedDocument,
            fileSizeBytes: await File(scannedPath).length(),
            createdAt: DateTime.now(),
          );

          setState(() {
            _scannedImages.add(scannedPath!);
            _documentAttachments.add(documentAttachment);
          });
          
          _showSnackBar('Document scanned successfully');
          widget.onDocumentsScanned?.call(_scannedImages);
          widget.onDocumentsChanged?.call(_documentAttachments);
          
          // Haptic feedback
          HapticFeedback.lightImpact();
        } else {
          debugPrint('DocumentScannerWidget: Scan returned null');
          _showSnackBar('Scan cancelled or failed');
        }
      }
    } catch (e) {
      debugPrint('DocumentScannerWidget: Error scanning document: $e');
      _showSnackBar('Error scanning document: $e');
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    if (!widget.allowMultiplePages && _scannedImages.isNotEmpty) {
      _showSnackBar('Only one document allowed');
      return;
    }

    if (_scannedImages.length >= widget.maxPages) {
      _showSnackBar('Maximum ${widget.maxPages} pages allowed');
      return;
    }

    try {
      final imagePath = await _scannerService.pickImageFromGallery();
      if (imagePath != null) {
        // For web, we can't get file size from blob URLs, so use a default value
        int fileSizeBytes = 0;
        if (!kIsWeb) {
          try {
            fileSizeBytes = await File(imagePath).length();
          } catch (e) {
            debugPrint('DocumentScannerWidget: Could not get file size: $e');
            fileSizeBytes = 0;
          }
        }
        
        final documentAttachment = DocumentAttachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          fileName: 'gallery_${DateTime.now().millisecondsSinceEpoch}.jpg',
          filePath: imagePath,
          type: DocumentType.photo,
          fileSizeBytes: fileSizeBytes,
          createdAt: DateTime.now(),
        );

        setState(() {
          if (widget.allowMultiplePages) {
            _scannedImages.add(imagePath);
            _documentAttachments.add(documentAttachment);
          } else {
            _scannedImages = [imagePath];
            _documentAttachments = [documentAttachment];
          }
        });
        _showSnackBar('Image selected from gallery');
        widget.onDocumentsScanned?.call(_scannedImages);
        widget.onDocumentsChanged?.call(_documentAttachments);
      }
    } catch (e) {
      _showSnackBar('Error selecting image: $e');
    }
  }

  Future<void> _enhanceImage(int index) async {
    try {
      final enhancedPath = await _scannerService.enhanceImage(
        _scannedImages[index],
        brightness: 0.1,
        contrast: 1.2,
        sharpen: true,
      );
      
      if (enhancedPath != null) {
        setState(() {
          _scannedImages[index] = enhancedPath;
        });
        _showSnackBar('Image enhanced');
        widget.onDocumentsScanned?.call(_scannedImages);
      }
    } catch (e) {
      _showSnackBar('Error enhancing image: $e');
    }
  }

  Future<void> _cropImage(int index) async {
    try {
      final croppedPath = await _scannerService.cropImage(_scannedImages[index]);
      if (croppedPath != null) {
        setState(() {
          _scannedImages[index] = croppedPath;
        });
        _showSnackBar('Image cropped');
        widget.onDocumentsScanned?.call(_scannedImages);
      }
    } catch (e) {
      _showSnackBar('Error cropping image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _scannedImages.removeAt(index);
      _documentAttachments.removeAt(index);
    });
    _showSnackBar('Image removed');
    widget.onDocumentsScanned?.call(_scannedImages);
    widget.onDocumentsChanged?.call(_documentAttachments);
  }

  void _clearAll() {
    setState(() {
      _scannedImages.clear();
      _documentAttachments.clear();
    });
    _showSnackBar('All images cleared');
    widget.onDocumentsScanned?.call(_scannedImages);
    widget.onDocumentsChanged?.call(_documentAttachments);
  }

  Future<void> _generatePdf() async {
    if (_scannedImages.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final pdfPath = await _scannerService.convertToPdf(
        _scannedImages,
        fileName: 'scanned_document_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (pdfPath != null) {
        _showSnackBar('PDF generated successfully');
        widget.onPdfGenerated?.call(pdfPath);
        
        // Haptic feedback
        HapticFeedback.lightImpact();
      } else {
        _showSnackBar('Error generating PDF');
      }
    } catch (e) {
      _showSnackBar('Error generating PDF: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up temporary files
    _scannerService.cleanupTempFiles();
    super.dispose();
  }
}