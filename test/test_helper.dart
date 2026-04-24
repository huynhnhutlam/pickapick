import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_pick/l10n/app_localizations.dart';

Widget buildTestApp({
  required Widget child,
  List<Override> overrides = const [],
  Locale? locale,
  ThemeData? theme,
  StackRouter? router,
}) {
  Widget content = child;

  if (router != null) {
    content = StackRouterScope(
      controller: router,
      stateHash: 0,
      child: child,
    );
  }

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale ?? const Locale('en'),
      theme: theme,
      home: content,
    ),
  );
}

class FakePageRouteInfo extends Fake implements PageRouteInfo {}

extension WidgetTesterX on WidgetTester {
  Future<void> pumpTestApp(
    Widget widget, {
    List<Override> overrides = const [],
    Locale? locale,
    ThemeData? theme,
    StackRouter? router,
    bool settle = false,
  }) async {
    await pumpWidget(
      buildTestApp(
        child: widget,
        overrides: overrides,
        locale: locale,
        theme: theme,
        router: router,
      ),
    );

    if (settle) {
      await pumpAndSettle();
    }
  }
}
