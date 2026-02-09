// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentAttachment _$DocumentAttachmentFromJson(Map<String, dynamic> json) =>
    DocumentAttachment(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      type: $enumDecode(_$DocumentTypeEnumMap, json['type']),
      fileSizeBytes: (json['fileSizeBytes'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      extractedText: json['extractedText'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      thumbnailPath: json['thumbnailPath'] as String?,
      isUploaded: json['isUploaded'] as bool? ?? false,
      serverUrl: json['serverUrl'] as String?,
      uploadedAt: json['uploadedAt'] == null
          ? null
          : DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$DocumentAttachmentToJson(DocumentAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'filePath': instance.filePath,
      'type': _$DocumentTypeEnumMap[instance.type]!,
      'fileSizeBytes': instance.fileSizeBytes,
      'createdAt': instance.createdAt.toIso8601String(),
      'description': instance.description,
      'extractedText': instance.extractedText,
      'metadata': instance.metadata,
      'thumbnailPath': instance.thumbnailPath,
      'isUploaded': instance.isUploaded,
      'serverUrl': instance.serverUrl,
      'uploadedAt': instance.uploadedAt?.toIso8601String(),
    };

const _$DocumentTypeEnumMap = {
  DocumentType.scannedDocument: 'scanned_document',
  DocumentType.photo: 'photo',
  DocumentType.pdf: 'pdf',
  DocumentType.cdlLicense: 'cdl_license',
  DocumentType.dotMedicalCard: 'dot_medical_card',
  DocumentType.vehicleRegistration: 'vehicle_registration',
  DocumentType.insuranceDocument: 'insurance_document',
  DocumentType.other: 'other',
};
