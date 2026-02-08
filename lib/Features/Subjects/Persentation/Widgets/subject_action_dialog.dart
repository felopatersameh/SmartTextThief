import 'package:flutter/material.dart';
import 'package:smart_text_thief/Core/Resources/app_colors.dart';

Future<bool?> showSubjectActionDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  bool destructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.colorsBackGround2,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            confirmText,
            style: TextStyle(color: destructive ? Colors.red : Colors.green),
          ),
        ),
      ],
    ),
  );
}
