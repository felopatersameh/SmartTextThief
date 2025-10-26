import 'package:flutter/material.dart';

/// widget صغيره لإظهار loading أو error أو empty في منتصف الصفحة داخل sliver
class CenteredSection extends StatelessWidget {
  final Widget child;
  const CenteredSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      fillOverscroll: true, 
      hasScrollBody: false,
      child: Center(child: child),
    );
  }
}
