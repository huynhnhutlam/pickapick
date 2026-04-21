import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
      locale: locale,
      theme: theme,
      home: content,
    ),
  );
}

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
