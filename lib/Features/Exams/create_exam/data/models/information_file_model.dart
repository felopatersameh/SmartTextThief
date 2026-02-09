import 'package:smart_text_thief/Core/Utils/Enums/upload_option.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';

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
    if (size < 1024) return '$size ${AppConstants.sizeUnitBytes}';
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} ${AppConstants.sizeUnitKilobytes}';
    }
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} ${AppConstants.sizeUnitMegabytes}';
  }
}
