import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_pick/app.dart';

void main() {
  testWidgets('Pickleball App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PickleballApp()));

    // Verify that we are on some initial screen
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
