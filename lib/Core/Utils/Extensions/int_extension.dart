// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:percent_indicator/linear_percent_indicator.dart';

// import '../../Resources/app_colors.dart';
// import '../../Resources/app_fonts.dart';
// import '../Widget/custom_text_app.dart';

// extension IntegerExtension on double {
//   Widget get linearProgres => LinearPercentIndicator(
//         padding: EdgeInsets.zero,
//         animationDuration: 1300,
//         lineHeight: 6,
//         barRadius: Radius.circular(5).r,
//         percent: this / 100,
//         animation: true,
//         backgroundColor: Color(0xff2C4653),
//         progressColor: Colors.white,
//       );
//   Widget get circularPercent => CircularPercentIndicator(
//         radius: 30.r,
//         lineWidth: 2.w,
//         percent: ((this) / 100),
//         center: AppCustomtext(
//           text: (this).toString().split(".0").first,
//           textStyle: AppTextStyles.h7Bold,
//         ),
//         progressColor: AppColors.colorPrimary,
//         animation: true,
//         reverse: true,
//         animationDuration: 1300,
//         backgroundColor: Color(0xff2C4653),
//       );
// }
