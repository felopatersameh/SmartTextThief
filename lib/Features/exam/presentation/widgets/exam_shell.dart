import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_text_thief/Config/app_config.dart';

class ExamShell extends StatelessWidget {
  const ExamShell({
    super.key,
    required this.title,
    required this.child,
    this.bottomNavigationBar,
    this.appBarBottom,
    this.persistentFooterButtons,
    this.resizeToAvoidBottomInset = true,
    this.useScrollBody = false,
    this.padding,
  });

  final String title;
  final Widget child;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBarBottom;
  final List<Widget>? persistentFooterButtons;
  final bool resizeToAvoidBottomInset;
  final bool useScrollBody;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final contentPadding =
        padding ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h);

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: AppBar(
        title: Text(title),
        bottom: appBarBottom,
      ),
      body: useScrollBody
          ? CustomScrollView(
              physics: AppConfig.physicsCustomScrollView,
              slivers: [
                SliverPadding(
                  padding: contentPadding,
                  sliver: SliverToBoxAdapter(
                    child: child,
                  ),
                ),
              ],
            )
          : child,
      bottomNavigationBar: bottomNavigationBar,
      persistentFooterButtons: persistentFooterButtons,
      persistentFooterDecoration: const BoxDecoration(),
    );
  }
}
