// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:icons_plus/icons_plus.dart';

// import '../../Resources/app_colors.dart';

// enum MessageType { success, error, warning, info, loading }

// void showMessageScafold(
//   BuildContext context, {
//   String? message,
//   Color? backgroundColor,
//   Duration duration = const Duration(seconds: 2),
//   MessageType type = MessageType.success,
// }) {
//   Widget leadingIcon;
//   Color snackBarBackgroundColor = backgroundColor ?? AppColors.colorPrimary;

//   switch (type) {
//     case MessageType.success:
//       leadingIcon = Icon(Bootstrap.check_circle_fill, color: Colors.white);
//       snackBarBackgroundColor = backgroundColor ?? Colors.green.shade400;
//       break;
//     case MessageType.error:
//       leadingIcon = Icon(Bootstrap.x_octagon_fill, color: Colors.white);
//       snackBarBackgroundColor = backgroundColor ?? Colors.red.shade400;
//       break;
//     case MessageType.warning:
//       leadingIcon = Icon(
//         Bootstrap.exclamation_triangle_fill,
//         color: Colors.white,
//       );
//       snackBarBackgroundColor = backgroundColor ?? Colors.orange.shade400;
//       break;
//     case MessageType.info:
//       leadingIcon = Icon(Bootstrap.info_circle_fill, color: Colors.white);
//       snackBarBackgroundColor = backgroundColor ?? Colors.blue.shade400;
//       break;
//     case MessageType.loading:
//       leadingIcon = SizedBox(
//         width: 24.w,
//         height: 24.h,
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           strokeWidth: 2,
//         ),
//       );
//       snackBarBackgroundColor = backgroundColor ?? AppColors.colorPrimary;
//       break;
//   }

//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       dismissDirection: type != MessageType.loading
//           ? DismissDirection.horizontal
//           : DismissDirection.none,
//       content: Row(
//         children: [
//           leadingIcon,
//           12.horizontalSpace,
//           Expanded(
//             child: Text(
//               message ?? '',
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//       backgroundColor: snackBarBackgroundColor,
//       behavior: SnackBarBehavior.floating,
//       duration: type == MessageType.loading
//           ? const Duration(days: 1)
//           : duration, // Keep loading snackbar visible
//       margin: EdgeInsets.only(
//         bottom: .05.sh,
//         left: .05.sw,
//         right: .05.sw,
//         top: 0,
//       ),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//       // action:
//       //     type != MessageType.loading
//       //         ? SnackBarAction(
//       //           label: 'DISMISS',
//       //           textColor: Colors.white,
//       //           onPressed: () {
//       //             ScaffoldMessenger.of(context).removeCurrentSnackBar();
//       //           },
//       //         )
//       //         : null, // No dismiss button for loading
//     ),
//   );
// }
