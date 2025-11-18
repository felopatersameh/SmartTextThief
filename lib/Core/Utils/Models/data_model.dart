class DataModel {
  final String name;
  final num _valueNum;
  final String _valueString;
  DataModel({
    required this.name,
    required num valueNum,
    String valueString = "none",
  }) : _valueString = valueString,
       _valueNum = valueNum;

  String get value => (_valueNum == -1) ? _valueString : _valueNum.toString();

}
