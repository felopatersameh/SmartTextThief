import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  String get shortMonthYear {
    final formatter = DateFormat('MMM yyyy',);
    return formatter.format(this);
  }


  String get fullDateTime {
    final formatter = DateFormat('d MMM yyyy (hh:mm a)',);
    return formatter.format(this);
  }
} 
