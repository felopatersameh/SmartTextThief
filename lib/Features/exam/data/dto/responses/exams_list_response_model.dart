import 'package:equatable/equatable.dart';
import 'package:smart_text_thief/Features/exam/data/models/exam_contract_model.dart';

class ExamsListResponseModel extends Equatable {
  const ExamsListResponseModel({
    required this.message,
    required this.data,
  });

  final String message;
  final List<ExamModel> data;

  factory ExamsListResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final parsedData = rawData is List
        ? rawData
            .whereType<Map>()
            .map((item) => ExamModel.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <ExamModel>[];

    return ExamsListResponseModel(
      message: (json['message'] ?? '').toString(),
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'data': data.map((item) => item.toJson()).toList(),
      };

  @override
  List<Object?> get props => [message, data];
}
