// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../Resources/app_colors.dart';
// import '../../../Resources/app_fonts.dart';
// import '../custom_text_app.dart';

// class CustomCachedImage extends StatelessWidget {
//   final String? imageUrl;
//   final String? fallbackChar;
//   final double size;
//   final bool isCircle;
//   final bool isProfile;
//   final BoxFit fit;
//   final TextStyle? fallbackStyle;
//   final Color backgroundColor;

//   const CustomCachedImage({
//     super.key,
//     required this.imageUrl,
//     this.fallbackChar,
//     this.size = 48.0,
//     this.isCircle = true,
//     this.isProfile = false,
//     this.fit = BoxFit.cover,
//     this.fallbackStyle,
//     this.backgroundColor = AppColors.colorPrimary,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

//     Widget fallbackWidget = isProfile
//         ? Center(
//             child: AppCustomtext(
//               text: fallbackChar?.substring(0, 1).toUpperCase() ?? '',
//               maxLines: fallbackChar?.isEmpty == true ? 0 : 1,
//               textStyle: AppTextStyles.getTextStyleSpecial(
//                 fontSize: 22,
//                 color: AppColors.colorsBackGround,
//               ),
//             ),
//           )
//         : const Center(
//             child: Icon(Icons.broken_image, color: Colors.white),
//           );

//     Widget imageWidget = CachedNetworkImage(
//       imageUrl: imageUrl ?? '',
//       width: size.w,
//       height: size.h,
//       fit: fit,
//       placeholder: (context, url) => const Center(
//         child: CircularProgressIndicator(strokeWidth: 2),
//       ),
//       errorWidget: (context, url, error) => fallbackWidget,
//     );

//     if (isCircle) {
//       return Container(
//         decoration: isProfile
//             ? BoxDecoration(
//                 border: Border.all(color: backgroundColor, width: 3.w),
//                 shape: BoxShape.circle)
//             : null,
//         child: CircleAvatar(
//           radius: (size / 2).r,
//           backgroundColor: backgroundColor,
//           child: ClipOval(
//             child: hasImage ? imageWidget : fallbackWidget,
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.circular(8).r,
//         ),
//         clipBehavior: Clip.hardEdge,
//         child: hasImage ? imageWidget : fallbackWidget,
//       );
//     }
//   }
// }
