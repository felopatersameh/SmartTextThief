import 'package:equatable/equatable.dart';

class ScoreModel extends Equatable {
  const ScoreModel({
    required this.total,
    required this.degree,
  });

  final int total;
  final int degree;

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      total: _toInt(json['total']),
      degree: _toInt(json['degree']),
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'degree': degree,
      };

  ScoreModel copyWith({
    int? total,
    int? degree,
  }) {
    return ScoreModel(
      total: total ?? this.total,
      degree: degree ?? this.degree,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [total, degree];
}

