import 'package:smart_text_thief/Core/Utils/Enums/upload_option.dart';

class InformationFileModel {
  final String name;
  final String path;
  final FilesType type;
  final int size;

  const InformationFileModel({
    required this.name,
    required this.path,
    required this.type,
    required this.size,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
