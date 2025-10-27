import 'package:flutter/material.dart';

@immutable
class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
    final bool internet;
  const SettingsState({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('en'),
    this.internet = true,
  });
  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? internet,
    
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
       internet: internet ?? this.internet,
    );
  }
}
