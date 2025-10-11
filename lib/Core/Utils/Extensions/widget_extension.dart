import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension ContextExtension on Widget {
  Widget addBlocProvider<T extends BlocBase<Object>>(
      T Function(BuildContext context) create) {
    return BlocProvider<T>(
      create: create,
      child: this,
    );
  }
}
