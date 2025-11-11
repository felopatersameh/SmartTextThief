import 'dart:async';

import 'package:flutter/material.dart'; // import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'class_setting.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SettingsCubit extends Cubit<SettingsState> with WidgetsBindingObserver {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _subscription;
  SettingsCubit() : super(SettingsState()) {
    WidgetsBinding.instance.addObserver(this);
    _updateThemeMode();
    _updateLanguage();
    _monitorConnection();
  }
  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription.cancel();
    return super.close();
  }

  @override
  void didChangePlatformBrightness() {
    _updateThemeMode();
  }

  void _updateThemeMode() {
    // final brightness = ui.PlatformDispatcher.instance.platformBrightness;
    // final systemThemeMode = // brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    // emit(state.copyWith(themeMode: systemThemeMode));
  }
  void _updateLanguage() {
    // final locale = ui.PlatformDispatcher.instance.locale;
    // if (locale.languageCode == 'ar') {
    //   emit(state.copyWith(locale: Locale('ar')));
    // } else {
    //  emit(state.copyWith(locale: Locale('en')));
    // }
  }
  void toggleTheme() {
    emit(
      state.copyWith(
        themeMode: state.themeMode == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light,
      ),
    );
  }

  void _monitorConnection() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result.isEmpty || result.contains(ConnectivityResult.none)) {
        emit(state.copyWith(internet: false));
      } else {
        emit(state.copyWith(internet: true));
      }
    });
  }

  bool getConnectivity() => state.internet;

  void changeLanguage(Locale locale) {
    emit(state.copyWith(locale: locale));
  }
}
