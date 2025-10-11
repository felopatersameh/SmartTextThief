import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Resources/app_colors.dart';

extension ContextExtension on BuildContext {
  Future<void> buildCustomBottomSheet({
    Widget? widget,
    WidgetBuilder? widgetBuilder,
    bool increaseHeight = false,
  }) =>
      showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        enableDrag: true,
        constraints:
            BoxConstraints(maxHeight: increaseHeight ? 0.8.sh : 0.5.sh),
        useSafeArea: true,
        backgroundColor: AppColors.colorsBackGround,
        context: this,
        builder: widgetBuilder ?? (context) => widget ?? Column(),
      );
}
