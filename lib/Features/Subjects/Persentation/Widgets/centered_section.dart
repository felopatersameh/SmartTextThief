import 'package:flutter/material.dart';

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
