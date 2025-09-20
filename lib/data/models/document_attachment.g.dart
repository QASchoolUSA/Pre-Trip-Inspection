// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_attachment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentAttachmentAdapter extends TypeAdapter<DocumentAttachment> {
  @override
  final int typeId = 31;

  @override
  DocumentAttachment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentAttachment(
      id: fields[0] as String,
      fileName: fields[1] as String,
      filePath: fields[2] as String,
      type: fields[3] as DocumentType,
      fileSizeBytes: fields[4] as int,
      createdAt: fields[5] as DateTime,
      description: fields[6] as String?,
      extractedText: fields[7] as String?,
      metadata: (fields[8] as Map?)?.cast<String, dynamic>(),
      thumbnailPath: fields[9] as String?,
      isUploaded: fields[10] as bool,
      serverUrl: fields[11] as String?,
      uploadedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentAttachment obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.fileSizeBytes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.extractedText)
      ..writeByte(8)
      ..write(obj.metadata)
      ..writeByte(9)
      ..write(obj.thumbnailPath)
      ..writeByte(10)
      ..write(obj.isUploaded)
      ..writeByte(11)
      ..write(obj.serverUrl)
      ..writeByte(12)
      ..write(obj.uploadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentAttachmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DocumentTypeAdapter extends TypeAdapter<DocumentType> {
  @override
  final int typeId = 30;

  @override
  DocumentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DocumentType.scannedDocument;
      case 1:
        return DocumentType.photo;
      case 2:
        return DocumentType.pdf;
      case 3:
        return DocumentType.cdlLicense;
      case 4:
        return DocumentType.dotMedicalCard;
      case 5:
        return DocumentType.vehicleRegistration;
      case 6:
        return DocumentType.insuranceDocument;
      case 7:
        return DocumentType.other;
      default:
        return DocumentType.scannedDocument;
    }
  }

  @override
  void write(BinaryWriter writer, DocumentType obj) {
    switch (obj) {
      case DocumentType.scannedDocument:
        writer.writeByte(0);
        break;
      case DocumentType.photo:
        writer.writeByte(1);
        break;
      case DocumentType.pdf:
        writer.writeByte(2);
        break;
      case DocumentType.cdlLicense:
        writer.writeByte(3);
        break;
      case DocumentType.dotMedicalCard:
        writer.writeByte(4);
        break;
      case DocumentType.vehicleRegistration:
        writer.writeByte(5);
        break;
      case DocumentType.insuranceDocument:
        writer.writeByte(6);
        break;
      case DocumentType.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
