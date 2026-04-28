import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static const _boxName = 'settings';
  static const _key = 'locale';

  @override
  Locale build() {
    if (!Hive.isBoxOpen(_boxName)) {
      return const Locale('vi'); // Fallback for tests
    }
    final box = Hive.box(_boxName);
    final languageCode = box.get(_key, defaultValue: 'vi') as String;
    return Locale(languageCode);
  }

  void setLocale(Locale locale) {
    if (Hive.isBoxOpen(_boxName)) {
      final box = Hive.box(_boxName);
      box.put(_key, locale.languageCode);
    }
    state = locale;
  }
}
