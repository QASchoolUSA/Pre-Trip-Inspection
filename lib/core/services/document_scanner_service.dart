import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'document_storage_service.dart';
import '../../data/models/document_attachment.dart';

/// Enhanced document scanner service for PTI Mobile App
/// Provides CamScanner-like functionality for document scanning and processing
class DocumentScannerService {
  static final DocumentScannerService _instance = DocumentScannerService._internal();
  
  factory DocumentScannerService() => _instance;
  
  DocumentScannerService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final DocumentStorageService _storageService = DocumentStorageService.instance;

  /// Scan a document using the device camera with automatic edge detection
  /// Returns the path to the processed document image
  Future<String?> scanDocument({
    bool enableAutoCapture = true,
    bool enableTorch = false,
  }) async {
    try {
      // For web platform, skip advanced scanning and use regular photo capture directly
      if (kIsWeb) {
        debugPrint('Web platform detected - using regular photo capture instead of advanced scanning');
        return await captureSimplePhoto();
      }

      // Request camera permission for mobile platforms
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        debugPrint('Camera permission denied');
        return null;
      }

      // Use cunning_document_scanner for advanced document scanning on mobile
      List<String> pictures = await CunningDocumentScanner.getPictures(
        noOfPages: 1,
        isGalleryImportAllowed: true,
      ) ?? [];

      if (pictures.isNotEmpty) {
        return pictures.first;
      }

      return null;
    } catch (e) {
      debugPrint('Error scanning document: $e');
      // Fallback to image picker if cunning_document_scanner fails
      return await _scanDocumentFallback();
    }
  }

  /// Scan multiple pages of a document
  /// Returns a list of paths to the processed document images
  Future<List<String>> scanMultiplePages({
    int maxPages = 10,
    bool enableAutoCapture = true,
  }) async {
    try {
      // For web platform, use image picker as fallback
      if (kIsWeb) {
        return await _scanMultiplePagesWeb(maxPages);
      }

      // Request camera permission for mobile platforms
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        debugPrint('Camera permission denied');
        return [];
      }

      // Use cunning_document_scanner for multi-page scanning on mobile
      List<String> pictures = await CunningDocumentScanner.getPictures(
        noOfPages: maxPages,
        isGalleryImportAllowed: true,
      ) ?? [];

      return pictures;
    } catch (e) {
      debugPrint('Error scanning multiple pages: $e');
      return [];
    }
  }

  /// Process and enhance a scanned image
  /// Applies filters, adjusts brightness/contrast, and improves clarity
  Future<String?> enhanceImage(String imagePath, {
    double brightness = 0.0,
    double contrast = 1.0,
    bool applyGrayscale = false,
    bool sharpen = true,
  }) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return null;
      }

      // Read the image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        debugPrint('Failed to decode image');
        return null;
      }

      // Apply enhancements
      if (brightness != 0.0) {
        image = img.adjustColor(image, brightness: brightness);
      }
      
      if (contrast != 1.0) {
        image = img.adjustColor(image, contrast: contrast);
      }
      
      if (applyGrayscale) {
        image = img.grayscale(image);
      }
      
      if (sharpen) {
        // Apply a simple sharpening effect by adjusting contrast
        image = img.adjustColor(image, contrast: 1.2);
      }

      // Save the enhanced image
      final Directory tempDir = await getTemporaryDirectory();
      final String enhancedPath = '${tempDir.path}/enhanced_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File enhancedFile = File(enhancedPath);
      
      await enhancedFile.writeAsBytes(img.encodeJpg(image, quality: 95));
      
      return enhancedPath;
    } catch (e) {
      debugPrint('Error enhancing image: $e');
      return null;
    }
  }

  /// Convert scanned images to a PDF document
  /// Supports multiple pages and maintains high quality
  Future<String?> convertToPdf(
    List<String> imagePaths, {
    String? fileName,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    double quality = 0.8,
  }) async {
    try {
      // Skip PDF conversion on web to avoid _Namespace errors
      if (kIsWeb) {
        debugPrint('PDF conversion skipped on web platform');
        return null;
      }
      
      if (imagePaths.isEmpty) {
        debugPrint('No images provided for PDF conversion');
        return null;
      }

      final pdf = pw.Document();
      
      for (String imagePath in imagePaths) {
        final File imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          debugPrint('Image file does not exist: $imagePath');
          continue;
        }

        final Uint8List imageBytes = await imageFile.readAsBytes();
        final pw.MemoryImage image = pw.MemoryImage(imageBytes);
        
        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }

      // Save the PDF
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String pdfFileName = fileName ?? 'scanned_document_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final String pdfPath = '${appDocDir.path}/$pdfFileName';
      final File pdfFile = File(pdfPath);
      
      await pdfFile.writeAsBytes(await pdf.save());
      
      debugPrint('PDF saved to: $pdfPath');
      return pdfPath;
    } catch (e) {
      debugPrint('Error converting to PDF: $e');
      return null;
    }
  }

  /// Crop an image to remove unwanted areas
  /// Returns the path to the cropped image
  Future<String?> cropImage(String imagePath, {
    int? x,
    int? y,
    int? width,
    int? height,
  }) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        debugPrint('Image file does not exist: $imagePath');
        return null;
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        debugPrint('Failed to decode image');
        return null;
      }

      // Use provided dimensions or default to center crop
      final int cropX = x ?? (image.width * 0.1).round();
      final int cropY = y ?? (image.height * 0.1).round();
      final int cropWidth = width ?? (image.width * 0.8).round();
      final int cropHeight = height ?? (image.height * 0.8).round();

      // Crop the image
      img.Image croppedImage = img.copyCrop(
        image,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // Save the cropped image
      final Directory tempDir = await getTemporaryDirectory();
      final String croppedPath = '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File croppedFile = File(croppedPath);
      
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 95));
      
      return croppedPath;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  /// Get image from gallery instead of camera
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      
      return image?.path;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Delete temporary files to free up storage
  Future<void> cleanupTempFiles() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();
      
      for (FileSystemEntity file in files) {
        if (file is File && 
            (file.path.contains('enhanced_') || 
             file.path.contains('cropped_') ||
             file.path.contains('temp_scan_'))) {
          await file.delete();
        }
      }
      
      debugPrint('Temporary files cleaned up');
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }

  /// Create a secure DocumentAttachment from a scanned/selected image
  Future<DocumentAttachment> createDocumentAttachment({
    required String imagePath,
    required String inspectionId,
    required String itemId,
    required DocumentType documentType,
    String? description,
  }) async {
    try {
      // Store the document securely
      final secureFilePath = await _storageService.storeDocument(
        sourceFilePath: imagePath,
        inspectionId: inspectionId,
        itemId: itemId,
        documentType: documentType,
      );

      // Get file size
      final fileSize = await _storageService.getFileSize(secureFilePath);

      // Generate thumbnail if it's an image
      String? thumbnailPath;
      if (documentType == DocumentType.scannedDocument || 
          documentType == DocumentType.photo) {
        thumbnailPath = await _storageService.generateThumbnail(
          imagePath: secureFilePath,
          inspectionId: inspectionId,
          itemId: itemId,
        );
      }

      // Create the DocumentAttachment
      final attachment = DocumentAttachment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: path.basename(secureFilePath),
        filePath: secureFilePath,
        type: documentType,
        fileSizeBytes: fileSize,
        createdAt: DateTime.now(),
        description: description,
        thumbnailPath: thumbnailPath,
      );

      return attachment;
    } catch (e) {
      debugPrint('Error creating document attachment: $e');
      rethrow;
    }
  }

  /// Scan document and create secure attachment
  Future<DocumentAttachment?> scanAndCreateAttachment({
    required String inspectionId,
    required String itemId,
    String? description,
  }) async {
    try {
      final scannedPath = await scanDocument();
      if (scannedPath == null) return null;

      return await createDocumentAttachment(
        imagePath: scannedPath,
        inspectionId: inspectionId,
        itemId: itemId,
        documentType: DocumentType.scannedDocument,
        description: description,
      );
    } catch (e) {
      debugPrint('Error scanning and creating attachment: $e');
      return null;
    }
  }

  /// Pick from gallery and create secure attachment
  Future<DocumentAttachment?> pickFromGalleryAndCreateAttachment({
    required String inspectionId,
    required String itemId,
    String? description,
  }) async {
    try {
      final imagePath = await pickImageFromGallery();
      if (imagePath == null) return null;

      return await createDocumentAttachment(
        imagePath: imagePath,
        inspectionId: inspectionId,
        itemId: itemId,
        documentType: DocumentType.photo,
        description: description,
      );
    } catch (e) {
      debugPrint('Error picking from gallery and creating attachment: $e');
      return null;
    }
  }

  /// Get the size of an image file
  Future<Size?> getImageSize(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        return null;
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);
      
      if (image == null) {
        return null;
      }

      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return null;
    }
  }

  /// Web-specific document scanning using image picker
  Future<String?> _scanDocumentWeb() async {
    try {
      debugPrint('Starting web document scan...');
      
      debugPrint('Attempting to pick image from camera...');
      
      // Try camera first with explicit web configuration
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        debugPrint('Web camera scan successful: ${image.path}');
        debugPrint('Image size: ${await image.length()} bytes');
        return image.path;
      }
      
      debugPrint('Camera scan returned null, user may have cancelled');
      return null;
    } catch (e) {
      debugPrint('Error scanning document on web: $e');
      debugPrint('Error type: ${e.runtimeType}');
      
      // Show user-friendly error message
      if (e.toString().contains('NotAllowedError') || e.toString().contains('permission')) {
        debugPrint('Camera permission denied or not available');
        throw Exception('Camera permission denied. Please allow camera access and try again.');
      }
      
      // For other errors, don't try gallery fallback as it might cause confusion
      // Let the calling code handle the fallback to captureSimplePhoto
      debugPrint('Web document scan failed, letting caller handle fallback');
      throw Exception('Web document scanning failed: $e');
    }
  }

  /// Simple photo capture for web without any advanced processing
  /// This is used as a fallback when advanced scanning fails
  Future<String?> captureSimplePhoto() async {
    try {
      debugPrint('Starting simple photo capture...');
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (image != null) {
        debugPrint('Simple photo capture successful: ${image.path}');
        debugPrint('Image size: ${await image.length()} bytes');
        return image.path;
      }
      
      debugPrint('Simple photo capture returned null - user cancelled or no image selected');
      return null; // Return null instead of throwing exception for user cancellation
    } catch (e) {
      debugPrint('Error capturing simple photo: $e');
      debugPrint('Error type: ${e.runtimeType}');
      
      // Check for specific Safari/mobile web errors
      if (e.toString().contains('NotAllowedError') || 
          e.toString().contains('permission') ||
          e.toString().contains('denied')) {
        debugPrint('Camera permission denied on mobile Safari');
        throw Exception('Camera permission denied. Please allow camera access in your browser settings.');
      }
      
      // For user cancellation or other non-critical errors, return null
      if (e.toString().contains('cancelled') || 
          e.toString().contains('abort') ||
          e.toString().contains('user')) {
        debugPrint('Photo capture cancelled by user');
        return null;
      }
      
      // For other errors, throw with more context
      throw Exception('Failed to capture photo on mobile browser: $e');
    }
  }

  /// Fallback document scanning using image picker
   Future<String?> _scanDocumentFallback() async {
     try {
       final XFile? image = await _imagePicker.pickImage(
         source: ImageSource.camera,
         imageQuality: 85,
       );
       
       if (image != null) {
         return image.path;
       }
       
       return null;
     } catch (e) {
       debugPrint('Error with fallback document scanning: $e');
       return null;
     }
   }

   /// Web-specific multiple page scanning using image picker
   Future<List<String>> _scanMultiplePagesWeb(int maxPages) async {
     List<String> scannedPages = [];
     
     for (int i = 0; i < maxPages; i++) {
       try {
         final XFile? image = await _imagePicker.pickImage(
           source: ImageSource.camera,
           imageQuality: 85,
         );
         
         if (image != null) {
           scannedPages.add(image.path);
         } else {
           break; // User cancelled, stop scanning
         }
       } catch (e) {
         debugPrint('Error scanning page ${i + 1}: $e');
         break;
       }
     }
     
     return scannedPages;
   }
   
   /// Scan document and automatically convert to PDF
   /// This simplifies the workflow by combining scanning and PDF generation
   Future<String?> scanDocumentToPdf({
    String? fileName,
    bool enableAutoCapture = true,
    bool enableTorch = false,
  }) async {
    try {
      debugPrint('DocumentScannerService: Starting scan-to-PDF workflow...');
      
      // Scan the document (now web-friendly)
      final scannedPath = await scanDocument(
        enableAutoCapture: enableAutoCapture,
        enableTorch: enableTorch,
      );
      
      if (scannedPath == null) {
        debugPrint('DocumentScannerService: Scan cancelled or failed');
        throw Exception('Document scanning was cancelled or failed');
      }
      
      debugPrint('DocumentScannerService: Document scanned, converting to PDF...');
      
      // Automatically convert to PDF
      final pdfPath = await convertToPdf(
        [scannedPath],
        fileName: fileName ?? 'scanned_document_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      
      if (pdfPath != null) {
        debugPrint('DocumentScannerService: PDF generated successfully: $pdfPath');
        
        // Clean up the temporary image file
        try {
          final tempFile = File(scannedPath);
          if (await tempFile.exists()) {
            await tempFile.delete();
            debugPrint('DocumentScannerService: Temporary image file cleaned up');
          }
        } catch (e) {
          debugPrint('DocumentScannerService: Error cleaning up temp file: $e');
        }
        
        return pdfPath;
      } else {
        throw Exception('Failed to convert scanned image to PDF');
      }
    } catch (e) {
      debugPrint('DocumentScannerService: Error in scan-to-PDF workflow: $e');
      rethrow;
    }
  }
   
   /// Scan multiple documents and automatically convert to PDF
   /// This simplifies the workflow for multi-page documents
   Future<String?> scanMultipleDocumentsToPdf({
     int maxPages = 10,
     String? fileName,
     bool enableAutoCapture = true,
   }) async {
     try {
       debugPrint('DocumentScannerService: Starting multi-page scan-to-PDF workflow...');
       
       // Scan multiple pages
       final scannedPaths = await scanMultiplePages(
         maxPages: maxPages,
         enableAutoCapture: enableAutoCapture,
       );
       
       if (scannedPaths.isEmpty) {
         debugPrint('DocumentScannerService: No pages scanned');
         return null;
       }
       
       debugPrint('DocumentScannerService: ${scannedPaths.length} pages scanned, converting to PDF...');
       
       // Automatically convert to PDF
       final pdfPath = await convertToPdf(
         scannedPaths,
         fileName: fileName ?? 'scanned_document_${DateTime.now().millisecondsSinceEpoch}.pdf',
       );
       
       if (pdfPath != null) {
         debugPrint('DocumentScannerService: Multi-page PDF generated successfully: $pdfPath');
         
         // Clean up temporary image files
         for (String imagePath in scannedPaths) {
           try {
             final tempFile = File(imagePath);
             if (await tempFile.exists()) {
               await tempFile.delete();
             }
           } catch (e) {
             debugPrint('DocumentScannerService: Error cleaning up temp file $imagePath: $e');
           }
         }
         debugPrint('DocumentScannerService: Temporary image files cleaned up');
       }
       
       return pdfPath;
     } catch (e) {
       debugPrint('DocumentScannerService: Error in multi-page scan-to-PDF workflow: $e');
       return null;
     }
   }
 }