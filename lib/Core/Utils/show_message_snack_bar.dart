import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';

enum MessageType {
  success(backgroundColor: Colors.green, icon: Icons.check_circle),
  error(backgroundColor: Colors.red, icon: Icons.error),
  pending(backgroundColor: Colors.blueGrey, icon: Icons.hourglass_bottom),
  rejected(backgroundColor: Colors.deepOrange, icon: Icons.cancel),
  warning(backgroundColor: Colors.amber, icon: Icons.warning),
  info(backgroundColor: Colors.blue, icon: Icons.info),
  loading(backgroundColor: Colors.black87, icon: Icons.hourglass_top);

  final Color backgroundColor;
  final IconData icon;

  const MessageType({required this.backgroundColor, required this.icon});
}

Future<void> showMessageSnackBar(
  BuildContext context, {
  required String title,  
  required MessageType type,
  Future<void> Function()? onLoading,
}) async {
  final messenger = ScaffoldMessenger.of(context);

  if (type == MessageType.loading && onLoading != null) {
    final snackBar = SnackBar(
      content: Row(
        children: [
           SizedBox(
            height: 20.h,
            width: 20.w,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
           SizedBox(width: 12.w),
          Expanded(child: Text(title)),
        ],
      ),
      backgroundColor: type.backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(10).r,
      duration: const Duration(hours: 1),
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);

    try {
      await onLoading(); 
    } finally {
      messenger.hideCurrentSnackBar();
    }

    return;
  }

  // حالات غير loading
  final snackBar = SnackBar(  
    content: Row(
      children: [
        Icon(type.icon, color: Colors.white),
         SizedBox(width: 12.w),
        Expanded(child: Text(title)),
      ],
    ),
    backgroundColor: type.backgroundColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(10).r,
    duration: const Duration(seconds: 3),
  );

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
