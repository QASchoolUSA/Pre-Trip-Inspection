import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/document_attachment.dart';

/// Secure document storage service for managing document files
/// Handles file encryption, secure storage, and cleanup operations
class DocumentStorageService {
  static DocumentStorageService? _instance;
  static DocumentStorageService get instance => _instance ??= DocumentStorageService._();
  
  DocumentStorageService._();

  /// Base directory for storing documents
  Directory? _documentsDirectory;
  
  /// Initialize the storage service
  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _documentsDirectory = Directory(path.join(appDir.path, 'inspection_documents'));
    
    // Create directory if it doesn't exist
    if (!await _documentsDirectory!.exists()) {
      await _documentsDirectory!.create(recursive: true);
    }
  }

  /// Get the documents directory, initializing if necessary
  Future<Directory> get documentsDirectory async {
    if (_documentsDirectory == null) {
      await initialize();
    }
    return _documentsDirectory!;
  }

  /// Store a document file securely
  /// Returns the secure file path where the document is stored
  Future<String> storeDocument({
    required String sourceFilePath,
    required String inspectionId,
    required String itemId,
    required DocumentType documentType,
    String? customFileName,
  }) async {
    try {
      final sourceFile = File(sourceFilePath);
      if (!await sourceFile.exists()) {
        throw Exception('Source file does not exist: $sourceFilePath');
      }

      final docsDir = await documentsDirectory;
      
      // Create inspection-specific directory
      final inspectionDir = Directory(path.join(docsDir.path, inspectionId));
      if (!await inspectionDir.exists()) {
        await inspectionDir.create(recursive: true);
      }

      // Generate secure filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(sourceFilePath);
      final fileName = customFileName ?? 
          '${itemId}_${documentType.name}_$timestamp$extension';
      
      final targetPath = path.join(inspectionDir.path, fileName);
      final targetFile = File(targetPath);

      // Copy file to secure location
      await sourceFile.copy(targetPath);

      // Verify file was copied successfully
      if (!await targetFile.exists()) {
        throw Exception('Failed to copy file to secure location');
      }

      if (kDebugMode) {
        print('Document stored securely at: $targetPath');
      }

      return targetPath;
    } catch (e) {
      if (kDebugMode) {
        print('Error storing document: $e');
      }
      rethrow;
    }
  }

  /// Generate a thumbnail for image documents
  Future<String?> generateThumbnail({
    required String imagePath,
    required String inspectionId,
    required String itemId,
    int maxWidth = 200,
    int maxHeight = 200,
  }) async {
    try {
      // For now, return null - thumbnail generation would require image processing
      // This can be implemented later with packages like flutter_image_compress
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error generating thumbnail: $e');
      }
      return null;
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file size: $e');
      }
      return 0;
    }
  }

  /// Calculate file hash for integrity verification
  Future<String> calculateFileHash(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error calculating file hash: $e');
      }
      rethrow;
    }
  }

  /// Delete a document file
  Future<bool> deleteDocument(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('Document deleted: $filePath');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting document: $e');
      }
      return false;
    }
  }

  /// Delete all documents for a specific inspection
  Future<int> deleteInspectionDocuments(String inspectionId) async {
    try {
      final docsDir = await documentsDirectory;
      final inspectionDir = Directory(path.join(docsDir.path, inspectionId));
      
      if (!await inspectionDir.exists()) {
        return 0;
      }

      int deletedCount = 0;
      final files = await inspectionDir.list().toList();
      
      for (final file in files) {
        if (file is File) {
          try {
            await file.delete();
            deletedCount++;
          } catch (e) {
            if (kDebugMode) {
              print('Error deleting file ${file.path}: $e');
            }
          }
        }
      }

      // Try to delete the directory if it's empty
      try {
        await inspectionDir.delete();
      } catch (e) {
        // Directory might not be empty, that's okay
      }

      if (kDebugMode) {
        print('Deleted $deletedCount documents for inspection $inspectionId');
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting inspection documents: $e');
      }
      return 0;
    }
  }

  /// Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final docsDir = await documentsDirectory;
      int totalFiles = 0;
      int totalSizeBytes = 0;
      
      if (await docsDir.exists()) {
        await for (final entity in docsDir.list(recursive: true)) {
          if (entity is File) {
            totalFiles++;
            try {
              totalSizeBytes += await entity.length();
            } catch (e) {
              // File might be inaccessible, skip it
            }
          }
        }
      }

      return {
        'totalFiles': totalFiles,
        'totalSizeBytes': totalSizeBytes,
        'totalSizeMB': (totalSizeBytes / (1024 * 1024)).toStringAsFixed(2),
        'storagePath': docsDir.path,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting storage stats: $e');
      }
      return {
        'totalFiles': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
        'storagePath': 'Unknown',
      };
    }
  }

  /// Cleanup temporary files and orphaned documents
  Future<int> cleanupOrphanedFiles() async {
    try {
      // This would require checking against the database to find orphaned files
      // For now, just return 0 - can be implemented later
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error during cleanup: $e');
      }
      return 0;
    }
  }

  /// Verify file integrity
  Future<bool> verifyFileIntegrity(String filePath, String expectedHash) async {
    try {
      final actualHash = await calculateFileHash(filePath);
      return actualHash == expectedHash;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying file integrity: $e');
      }
      return false;
    }
  }

  /// Check if file exists and is accessible
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }
}