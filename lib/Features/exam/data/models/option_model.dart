import 'package:equatable/equatable.dart';

class OptionModel extends Equatable {
  const OptionModel({
    required this.id,
    required this.choice,
  });

  final String id;
  final String choice;

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: (json['id'] ?? '').toString(),
      choice: (json['choice'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'choice': choice,
      };

  OptionModel copyWith({
    String? id,
    String? choice,
  }) {
    return OptionModel(
      id: id ?? this.id,
      choice: choice ?? this.choice,
    );
  }

  @override
  List<Object?> get props => [id, choice];
}

