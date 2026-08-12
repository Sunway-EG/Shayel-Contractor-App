import '../../domain/entities/document_definition.dart';

class DocumentDefinitionDto extends DocumentDefinition {
  const DocumentDefinitionDto({
    required super.id,
    required super.entityId,
    required super.nameEn,
    required super.nameAr,
    required super.required,
    required super.status,
  });

  factory DocumentDefinitionDto.fromJson(Map<String, dynamic> json) {
    return DocumentDefinitionDto(
      id: json['id'] as int,
      entityId: json['entityId'] as int,
      nameEn: json['nameEn'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      required: json['required'] as bool? ?? false,
      status: json['status'] as int? ?? 0,
    );
  }
}