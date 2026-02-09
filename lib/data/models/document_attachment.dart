
import 'package:json_annotation/json_annotation.dart';

part 'document_attachment.g.dart';

/// Document attachment types
enum DocumentType {
  @HiveField(0)
  @JsonValue('scanned_document')
  scannedDocument,
  
  @HiveField(1)
  @JsonValue('photo')
  photo,
  
  @HiveField(2)
  @JsonValue('pdf')
  pdf,
  
  @HiveField(3)
  @JsonValue('cdl_license')
  cdlLicense,
  
  @HiveField(4)
  @JsonValue('dot_medical_card')
  dotMedicalCard,
  
  @HiveField(5)
  @JsonValue('vehicle_registration')
  vehicleRegistration,
  
  @HiveField(6)
  @JsonValue('insurance_document')
  insuranceDocument,
  
  @HiveField(7)
  @JsonValue('other')
  other,
}

/// Document attachment model for inspection items
@JsonSerializable()
class DocumentAttachment {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String fileName;
  
  @HiveField(2)
  final String filePath;
  
  @HiveField(3)
  final DocumentType type;
  
  @HiveField(4)
  final int fileSizeBytes;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final String? description;
  
  @HiveField(7)
  final String? extractedText; // OCR text content
  
  @HiveField(8)
  final Map<String, dynamic>? metadata; // Additional metadata
  
  @HiveField(9)
  final String? thumbnailPath; // Thumbnail for quick preview
  
  @HiveField(10)
  final bool isUploaded; // Sync status
  
  @HiveField(11)
  final String? serverUrl; // URL after upload to server
  
  @HiveField(12)
  final DateTime? uploadedAt;

  const DocumentAttachment({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.fileSizeBytes,
    required this.createdAt,
    this.description,
    this.extractedText,
    this.metadata,
    this.thumbnailPath,
    this.isUploaded = false,
    this.serverUrl,
    this.uploadedAt,
  });

  factory DocumentAttachment.fromJson(Map<String, dynamic> json) =>
      _$DocumentAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentAttachmentToJson(this);

  DocumentAttachment copyWith({
    String? id,
    String? fileName,
    String? filePath,
    DocumentType? type,
    int? fileSizeBytes,
    DateTime? createdAt,
    String? description,
    String? extractedText,
    Map<String, dynamic>? metadata,
    String? thumbnailPath,
    bool? isUploaded,
    String? serverUrl,
    DateTime? uploadedAt,
  }) {
    return DocumentAttachment(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      extractedText: extractedText ?? this.extractedText,
      metadata: metadata ?? this.metadata,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isUploaded: isUploaded ?? this.isUploaded,
      serverUrl: serverUrl ?? this.serverUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  /// Get file extension from fileName
  String get fileExtension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Check if document is a PDF
  bool get isPdf => fileExtension == 'pdf' || type == DocumentType.pdf;

  /// Check if document is an image
  bool get isImage => ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(fileExtension);

  /// Get human-readable file size
  String get formattedFileSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else if (fileSizeBytes < 1024 * 1024 * 1024) {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Get document type display name
  String get typeDisplayName {
    switch (type) {
      case DocumentType.scannedDocument:
        return 'Scanned Document';
      case DocumentType.photo:
        return 'Photo';
      case DocumentType.pdf:
        return 'PDF Document';
      case DocumentType.cdlLicense:
        return 'CDL License';
      case DocumentType.dotMedicalCard:
        return 'DOT Medical Card';
      case DocumentType.vehicleRegistration:
        return 'Vehicle Registration';
      case DocumentType.insuranceDocument:
        return 'Insurance Document';
      case DocumentType.other:
        return 'Other Document';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentAttachment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DocumentAttachment{id: $id, fileName: $fileName, type: $type, size: $formattedFileSize}';
  }
}