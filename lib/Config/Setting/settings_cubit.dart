import 'package:flutter/material.dart'; // import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'class_setting.dart';

class SettingsCubit extends Cubit<SettingsState> with WidgetsBindingObserver {
  SettingsCubit() : super(SettingsState()) {
    WidgetsBinding.instance.addObserver(this);
    _updateThemeMode();
    _updateLanguage();
  }
  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  @override
  void didChangePlatformBrightness() {
    _updateThemeMode();
  }

  void _updateThemeMode() {
    // final brightness = ui.PlatformDispatcher.instance.platformBrightness; // final systemThemeMode = // brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light; // emit(state.copyWith(themeMode: systemThemeMode));
  }
  void _updateLanguage() {
    // final locale = ui.PlatformDispatcher.instance.locale; // if (locale.languageCode == 'ar') { //   emit(state.copyWith(locale: Locale('ar'))); // } else { //   emit(state.copyWith(locale: Locale('en'))); // }
  }
  void toggleTheme() {
    emit(state.copyWith(
      themeMode:
          state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    ));
  }

  void changeLanguage(Locale locale) {
    emit(state.copyWith(locale: locale));
  }
}
