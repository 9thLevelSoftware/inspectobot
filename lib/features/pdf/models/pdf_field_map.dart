import '../../inspection/domain/form_type.dart';

enum PdfFieldType {
  text,
  checkbox,
  image,
  signature;

  static PdfFieldType fromWireValue(String value) {
    switch (value) {
      case 'text':
        return PdfFieldType.text;
      case 'checkbox':
        return PdfFieldType.checkbox;
      case 'image':
        return PdfFieldType.image;
      case 'signature':
        return PdfFieldType.signature;
      default:
        throw PdfFieldMapError('Unsupported field type: $value');
    }
  }
}

class PdfFieldMap {
  const PdfFieldMap({
    required this.formType,
    required this.mapVersion,
    required this.fields,
  });

  final FormType formType;
  final String mapVersion;
  final List<PdfFieldDefinition> fields;
}

class PdfFieldDefinition {
  const PdfFieldDefinition({
    required this.key,
    required this.sourceKey,
    required this.type,
    required this.page,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final String key;
  final String sourceKey;
  final PdfFieldType type;
  final int page;
  final double x;
  final double y;
  final double width;
  final double height;
}

class PdfFieldMapError implements Exception {
  const PdfFieldMapError(this.message);

  final String message;

  @override
  String toString() => message;
}
