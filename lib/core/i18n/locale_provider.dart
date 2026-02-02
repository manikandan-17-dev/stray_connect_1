import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stray_resuce_bih/core/storage/local_prefs.dart';

final localeProvider = StateNotifierProvider<LocaleController, Locale?>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null) {
    _init();
  }

  Future<void> _init() async {
    final code = await LocalPrefs.getString(LocalPrefs.keyLanguage) ?? 'en';
    state = Locale(code);
  }

  Future<void> setLocale(String code) async {
    await LocalPrefs.setString(LocalPrefs.keyLanguage, code);
    state = Locale(code);
  }
}
