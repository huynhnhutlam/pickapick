import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_pick/l10n/app_localizations.dart';

extension LocalizationTesterX on WidgetTester {
  AppLocalizations l10nOf(Finder finder) {
    final context = element(finder);
    return AppLocalizations.of(context)!;
  }
}
