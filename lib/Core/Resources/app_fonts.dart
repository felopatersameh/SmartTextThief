import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';


class AppTextStyles {
  static TextStyle _getTextStyle(double fontSize, FontWeight fontWeight) {
    return GoogleFonts.cairo(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
    ).copyWith(
      overflow: TextOverflow.ellipsis,
      color: Colors.white,
    );
  } //* Headings

  static final h1Bold = _getTextStyle(48, FontWeight.bold);
  static final h2Bold = _getTextStyle(40, FontWeight.bold);
  static final h3Bold = _getTextStyle(32, FontWeight.bold);
  static final h4Bold = _getTextStyle(26, FontWeight.bold);

  static final h5Bold = _getTextStyle(20, FontWeight.bold);
  static final h6Bold = _getTextStyle(18, FontWeight.bold);
  static final h7Bold = _getTextStyle(14, FontWeight.bold);
  static final h1SemiBold = _getTextStyle(48, FontWeight.w600);
  static final h2SemiBold = _getTextStyle(40, FontWeight.w600);
  static final h3SemiBold = _getTextStyle(32, FontWeight.w600);
  static final h4SemiBold = _getTextStyle(24, FontWeight.w600);
  static final h5SemiBold = _getTextStyle(20, FontWeight.w600);
  static final h6SemiBold = _getTextStyle(18, FontWeight.w600);
  static final h1Medium = _getTextStyle(48, FontWeight.w500);
  static final h2Medium = _getTextStyle(40, FontWeight.w500);
  static final h3Medium = _getTextStyle(32, FontWeight.w500);
  static final h4Medium = _getTextStyle(24, FontWeight.w500);
  static final h5Medium = _getTextStyle(20, FontWeight.w500);
  static final h6Medium = _getTextStyle(18, FontWeight.w500);
  static final h7Medium = _getTextStyle(14, FontWeight.w500);

  //* Body Text Styles
  static final bodyXtraLargeBold = _getTextStyle(18, FontWeight.bold);
  static final bodyLargeBold = _getTextStyle(16, FontWeight.bold);
  static final bodyMediumBold = _getTextStyle(14, FontWeight.bold);
  static final bodySmallBold = _getTextStyle(12, FontWeight.bold);
  static final bodyXtraSmallBold = _getTextStyle(10, FontWeight.bold);
  static final bodyXtraLargeSemiBold = _getTextStyle(18, FontWeight.w600);
  static final bodyLargeSemiBold = _getTextStyle(16, FontWeight.w600);
  static final bodyMediumSemiBold = _getTextStyle(14, FontWeight.w600);
  static final bodySmallSemiBold = _getTextStyle(12, FontWeight.w600);
  static final bodyXtraSmallSemiBold = _getTextStyle(10, FontWeight.w600);
  static final bodyXtraLargeMedium = _getTextStyle(18, FontWeight.w500);
  static final bodyLargeMedium = _getTextStyle(16, FontWeight.w500);
  static final bodyMediumMedium = _getTextStyle(14, FontWeight.normal);
  static final bodySmallMedium = _getTextStyle(12, FontWeight.w500);
  static final bodyXtraSmallMedium = _getTextStyle(9, FontWeight.bold);

  static TextStyle getTextStyleSpecial({Color? color, double? fontSize}) {
    return GoogleFonts.changa(
      fontSize: (fontSize ?? 50).sp,
      fontWeight: FontWeight.bold,
    ).copyWith(
      overflow: TextOverflow.ellipsis,
      color: color,
    );
  }
}
