// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class ResponsiveLayout {
//   // Screen breakpoints
//   static const double mobileBreakpoint = 768;
//   static const double tabletBreakpoint = 1024;
//   static const double desktopBreakpoint = 1200;

//   // Check screen size
//   static bool isMobile(BuildContext context) => 1.sw <= mobileBreakpoint;
//   static bool isTablet(BuildContext context) =>
//       1.sw > mobileBreakpoint && 1.sw <= tabletBreakpoint;
//   static bool isDesktop(BuildContext context) => 1.sw > tabletBreakpoint;

//   // Responsive padding
//   static EdgeInsets getScreenPadding(BuildContext context) {
//     if (isMobile(context)) {
//       return EdgeInsets.all(16.w);
//     } else if (isTablet(context)) {
//       return EdgeInsets.all(24.w);
//     } else {
//       return EdgeInsets.all(32.w);
//     }
//   }

//   // Responsive font sizes with precise sizing
//   static double getTitleFontSize(BuildContext context) {
//     if (isMobile(context)) {
//       return 28.sp;
//     } else if (isTablet(context)) {
//       return 36.sp;
//     } else {
//       return 44.sp;
//     }
//   }

//   static double getSubtitleFontSize(BuildContext context) {
//     if (isMobile(context)) {
//       return 16.sp;
//     } else if (isTablet(context)) {
//       return 20.sp;
//     } else {
//       return 24.sp;
//     }
//   }

//   static double getBodyFontSize(BuildContext context) {
//     if (isMobile(context)) {
//       return 14.sp;
//     } else if (isTablet(context)) {
//       return 16.sp;
//     } else {
//       return 18.sp;
//     }
//   }

//   static double getSmallFontSize(BuildContext context) {
//     if (isMobile(context)) {
//       return 12.sp;
//     } else if (isTablet(context)) {
//       return 13.sp;
//     } else {
//       return 14.sp;
//     }
//   }

//   // Responsive spacing with precise increments
//   static double getSectionSpacing(BuildContext context) {
//     if (isMobile(context)) {
//       return 24.h;
//     } else if (isTablet(context)) {
//       return 32.h;
//     } else {
//       return 40.h;
//     }
//   }

//   static double getSmallSpacing(BuildContext context) {
//     if (isMobile(context)) {
//       return 10.h;
//     } else if (isTablet(context)) {
//       return 16.h;
//     } else {
//       return 24.h;
//     }
//   }

//   static double getMediumSpacing(BuildContext context) {
//     if (isMobile(context)) {
//       return 18.h;
//     } else if (isTablet(context)) {
//       return 24.h;
//     } else {
//       return 28.h;
//     }
//   }

//   static double getLargeSpacing(BuildContext context) {
//     if (isMobile(context)) {
//       return 28.h;
//     } else if (isTablet(context)) {
//       return 36.h;
//     } else {
//       return 44.h;
//     }
//   }

//   // Responsive container constraints
//   static BoxConstraints getContentConstraints(BuildContext context) {
//     if (isMobile(context)) {
//       return BoxConstraints(maxWidth: 1.sw);
//     } else if (isTablet(context)) {
//       return BoxConstraints(maxWidth: 800.w);
//     } else {
//       return BoxConstraints(maxWidth: 1200.w);
//     }
//   }

//   // Responsive grid columns
//   static int getGridColumns(BuildContext context) {
//     if (isMobile(context)) {
//       return 1;
//     } else if (isTablet(context)) {
//       return 2;
//     } else {
//       return 3;
//     }
//   }

//   // Responsive card width with precise sizing
//   static double getCardWidth(BuildContext context) {
//     if (isMobile(context)) {
//       return 1.sw - 32.w;
//     } else if (isTablet(context)) {
//       return 280.w;
//     } else {
//       return 320.w;
//     }
//   }

//   static double getCardViewsProtfolioWidth(BuildContext context) {
//     if (isMobile(context)) {
//       return 1.sw - 32.w;
//     } else {
//       return 1.sw - 500.w;
//     }
//   }

//   // Responsive navigation width
//   static double getSideNavWidth(BuildContext context) {
//     if (isMobile(context)) {
//       return 0;
//     } else if (isTablet(context)) {
//       return 90.w;
//     } else {
//       return 120.w;
//     }
//   }

//   // Responsive icon sizes with precise sizing
//   static double getIconSize(BuildContext context) {
//     if (isMobile(context)) {
//       return 20.sp;
//     } else if (isTablet(context)) {
//       return 22.sp;
//     } else {
//       return 24.sp;
//     }
//   }

//   static double getLargeIconSize(BuildContext context) {
//     if (isMobile(context)) {
//       return 28.sp;
//     } else if (isTablet(context)) {
//       return 32.sp;
//     } else {
//       return 36.sp;
//     }
//   }

//   // Responsive avatar size with precise sizing
//   static double getAvatarSize(BuildContext context) {
//     if (isMobile(context)) {
//       return 130.r;
//     } else if (isTablet(context)) {
//       return 140.r;
//     } else {
//       return 150.r;
//     }
//   }

//   // Responsive button padding with precise sizing
//   static EdgeInsets getButtonPadding(BuildContext context) {
//     if (isMobile(context)) {
//       return EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h);
//     } else if (isTablet(context)) {
//       return EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h);
//     } else {
//       return EdgeInsets.symmetric(horizontal: 26.w, vertical: 16.h);
//     }
//   }

//   static EdgeInsets getSmallButtonPadding(BuildContext context) {
//     if (isMobile(context)) {
//       return EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h);
//     } else if (isTablet(context)) {
//       return EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h);
//     } else {
//       return EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h);
//     }
//   }

//   // Responsive border radius with precise sizing
//   static double getBorderRadius(BuildContext context) {
//     if (isMobile(context)) {
//       return 10.r;
//     } else if (isTablet(context)) {
//       return 12.r;
//     } else {
//       return 14.r;
//     }
//   }

//   static double getSmallBorderRadius(BuildContext context) {
//     if (isMobile(context)) {
//       return 6.r;
//     } else if (isTablet(context)) {
//       return 8.r;
//     } else {
//       return 10.r;
//     }
//   }

//   // Responsive margins with precise sizing
//   static EdgeInsets getCardMargin(BuildContext context) {
//     if (isMobile(context)) {
//       return EdgeInsets.all(8.w);
//     } else if (isTablet(context)) {
//       return EdgeInsets.all(12.w);
//     } else {
//       return EdgeInsets.all(16.w);
//     }
//   }

//   // Responsive container padding with precise sizing
//   static EdgeInsets getContainerPadding(BuildContext context) {
//     if (isMobile(context)) {
//       return EdgeInsets.all(18.w);
//     } else if (isTablet(context)) {
//       return EdgeInsets.all(26.w);
//     } else {
//       return EdgeInsets.all(34.w);
//     }
//   }

//   static EdgeInsets getSmallContainerPadding(BuildContext context) {
//     if (isMobile(context)) {
//       return EdgeInsets.all(14.w);
//     } else if (isTablet(context)) {
//       return EdgeInsets.all(18.w);
//     } else {
//       return EdgeInsets.all(22.w);
//     }
//   }
// }
