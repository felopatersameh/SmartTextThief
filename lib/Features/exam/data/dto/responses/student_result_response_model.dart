import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_result_model.dart';

class StudentResultResponseModel extends Equatable {
  const StudentResultResponseModel({
    required this.message,
    this.data,
    this.dataList,
  });

  final String message;
  final ExamResultModel? data;
  final List<ExamResultModel>? dataList;

  factory StudentResultResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    if (rawData is List) {
      final parsedList = rawData
          .whereType<Map>()
          .map(
            (item) => ExamResultModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      return StudentResultResponseModel(
        message: (json['message'] ?? '').toString(),
        dataList: parsedList,
      );
    }

    if (rawData is Map) {
      return StudentResultResponseModel(
        message: (json['message'] ?? '').toString(),
        data: ExamResultModel.fromJson(Map<String, dynamic>.from(rawData)),
      );
    }

    return StudentResultResponseModel(
      message: (json['message'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data != null
            ? data!.toJson()
            : (dataList ?? []).map((item) => item.toJson()).toList(),
      };

  bool get isSingleResult => data != null;
  bool get isListResult => dataList != null;

  @override
  List<Object?> get props => [message, data, dataList];
}
