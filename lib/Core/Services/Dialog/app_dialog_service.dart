import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Core/Resources/resources.dart';
import 'package:smart_text_thief/Core/Utils/Widget/custom_text_app.dart';

typedef AppInputValidator = String? Function(String value);

class AppDialogService {
  static RoundedRectangleBorder _dialogShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
      side: BorderSide(
        color: AppColors.colorPrimary.withValues(alpha: 0.3),
      ),
    );
  }

  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    String cancelText = AppStrings.cancel,
    bool destructive = false,
    bool barrierDismissible = true,
  }) {
    final confirmColor =
        destructive ? AppColors.dangerAccent : AppColors.colorPrimary;

    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.colorsBackGround2,
        shape: _dialogShape(),
        title: AppCustomText.generate(
          text: title,
          textStyle: AppTextStyles.h6Bold.copyWith(color: confirmColor),
        ),
        content: AppCustomText.generate(
          text: message,
          textStyle: AppTextStyles.bodyMediumMedium.copyWith(
            color: AppColors.textCoolGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: AppCustomText.generate(
              text: cancelText,
              textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: AppColors.textWhite,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: AppCustomText.generate(
              text: confirmText,
              textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: confirmColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String actionText = AppStrings.ok,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.colorsBackGround2,
        shape: _dialogShape(),
        title: AppCustomText.generate(
          text: title,
          textStyle: AppTextStyles.h6Bold.copyWith(color: AppColors.warning),
        ),
        content: AppCustomText.generate(
          text: message,
          textStyle: AppTextStyles.bodyMediumMedium.copyWith(
            color: AppColors.textCoolGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: AppCustomText.generate(
              text: actionText,
              textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: AppColors.colorPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    required String hintText,
    required String confirmText,
    String cancelText = AppStrings.cancel,
    String initialValue = '',
    bool obscureText = false,
    AppInputValidator? validator,
    Color? titleColor,
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final controller = TextEditingController(text: initialValue);
        bool hidden = obscureText;
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: AppColors.colorsBackGround2,
            shape: _dialogShape(),
            title: AppCustomText.generate(
              text: title,
              textStyle: AppTextStyles.h6Bold.copyWith(
                color: titleColor ?? AppColors.textWhite,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller,
                  obscureText: hidden,
                  keyboardType: TextInputType.visiblePassword,
                  style: AppTextStyles.bodyMediumMedium.copyWith(
                    color: AppColors.textWhite,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyles.bodyMediumMedium.copyWith(
                      color: AppColors.white54,
                    ),
                    errorText: errorText,
                    fillColor: AppColors.colorTextFieldBackGround,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: obscureText
                        ? IconButton(
                            onPressed: () => setState(() => hidden = !hidden),
                            icon: Icon(
                              hidden
                                  ? AppIcons.visibility
                                  : AppIcons.visibilityOff,
                              color: AppColors.white70,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: AppCustomText.generate(
                  text: cancelText,
                  textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final value = controller.text.trim();
                  final validationMessage = validator?.call(value);
                  if (validationMessage != null) {
                    setState(() => errorText = validationMessage);
                    return;
                  }
                  Navigator.of(dialogContext).pop(value);
                },
                child: AppCustomText.generate(
                  text: confirmText,
                  textStyle: AppTextStyles.bodyMediumSemiBold.copyWith(
                    color: AppColors.colorPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
