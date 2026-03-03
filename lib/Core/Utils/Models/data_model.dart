class DataModel {
  final String name;
  final String value;
  const DataModel({
    required this.name,
    required this.value,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      name: json['title'],
      value: json['value'],
    );
  }
}
