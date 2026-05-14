import 'dart:ui';

import 'package:flutter/cupertino.dart';

class LanguageProvider extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  LanguageProvider() {
    _initLocale();
  }

  void _initLocale() {
    final deviceLocale = PlatformDispatcher.instance.locale;
    const supported = ['ca', 'es', 'en'];

    if (supported.contains(deviceLocale.languageCode)) {
      _locale = Locale(deviceLocale.languageCode);
    } else {
      _locale = const Locale('en');
    }
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}