import 'package:flutter/material.dart';
import 'package:smart_text_thief/Core/Services/Dialog/app_dialog_service.dart';

Future<bool?> showSubjectActionDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmText,
  bool destructive = false,
}) {
  return AppDialogService.showConfirmDialog(
    context,
    title: title,
    message: message,
    confirmText: confirmText,
    destructive: destructive,
  );
}
