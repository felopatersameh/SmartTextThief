import 'package:flutter/material.dart';

import '../../Resources/app_colors.dart';

class AppCustomtext extends StatelessWidget {
  const AppCustomtext(
      {super.key,
      required this.text,
      this.textStyle,
      this.maxLines,
      this.overflow,
      this.textAlign,
      this.specialText,
      this.onPressed});

  final String text;
  final String? specialText;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        specialText == null || specialText?.isEmpty == true
            ? _method()
            : Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _method(),
                    TextButton(
                        onPressed: onPressed,
                        child: Text(
                          specialText!,
                          style: textStyle?.copyWith(
                              color: AppColors.colorPrimary),
                          maxLines: maxLines ?? specialText?.length,
                          textAlign: textAlign,
                          overflow: overflow,
                        ))
                  ],
                ),
              )
      ],
    );
  }

  Text _method() {
    return Text(
      text,
      style: textStyle,
      maxLines: maxLines ?? text.length,
      textAlign: textAlign,
      overflow: overflow,
    );
  }
}
