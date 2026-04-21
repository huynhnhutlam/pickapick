import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_pick/core/enum/quick_action_type_enum.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';

class HomeRobot {
  HomeRobot(this.tester);

  final WidgetTester tester;

  void _expectVisible(Key key) {
    expect(find.byKey(key), findsOneWidget);
  }

  void _expectNotVisible(Key key) {
    expect(find.byKey(key), findsNothing);
  }

  Finder _bannerItemFinder(int index) {
    return find.byKey(WidgetKeys.homeBannerItem(index));
  }

  Finder _quickActionFinder(QuickActionType action) {
    return find.byKey(WidgetKeys.quickActionItem(action.name));
  }

  // Assertions
  void expectHomeHeaderVisible() => _expectVisible(WidgetKeys.homeHeader);
  void expectHomeHeaderNotVisible() => _expectNotVisible(WidgetKeys.homeHeader);

  void expectSearchBarVisible() => _expectVisible(WidgetKeys.homeSearchBar);
  void expectSearchBarNotVisible() =>
      _expectNotVisible(WidgetKeys.homeSearchBar);

  void expectBannerVisible() => _expectVisible(WidgetKeys.homeBanner);
  void expectBannerNotVisible() => _expectNotVisible(WidgetKeys.homeBanner);

  void expectQuickActionsVisible() =>
      _expectVisible(WidgetKeys.quickActionsSection);
  void expectQuickActionsNotVisible() =>
      _expectNotVisible(WidgetKeys.quickActionsSection);

  void expectFeaturedCourtsVisible() =>
      _expectVisible(WidgetKeys.featuredCourts);
  void expectFeaturedCourtsNotVisible() =>
      _expectNotVisible(WidgetKeys.featuredCourts);

  void expectFeaturedProductsVisible() =>
      _expectVisible(WidgetKeys.featuredProducts);
  void expectFeaturedProductsNotVisible() =>
      _expectNotVisible(WidgetKeys.featuredProducts);

  void expectBannerItemVisible(int index) {
    expect(_bannerItemFinder(index), findsOneWidget);
  }

  void expectBannerItemNotVisible(int index) {
    expect(_bannerItemFinder(index), findsNothing);
  }

  void expectFeaturedCourtVisible(String id) {
    expect(find.byKey(WidgetKeys.featuredCourtItem(id)), findsOneWidget);
  }

  void expectFeaturedProductVisible(String id) {
    expect(find.byKey(WidgetKeys.featuredProductItem(id)), findsOneWidget);
  }

  // Interactions
  Future<void> tapSearchBar() async {
    await tester.tap(find.byKey(WidgetKeys.homeSearchBar));
    await tester.pumpAndSettle();
  }

  Future<void> tapBannerAction(int index) async {
    final button = find.byKey(WidgetKeys.bannerActionButton(index));
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> tapQuickAction(QuickActionType action) async {
    await tester.tap(_quickActionFinder(action));
    await tester.pumpAndSettle();
  }

  Future<void> tapFeaturedCourtsSeeAll() async {
    final headerFinder = find.byKey(WidgetKeys.featuredCourtsSeeAll);
    final buttonFinder = find.descendant(
      of: headerFinder,
      matching: find.byType(TextButton),
    );
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapFeaturedProductsSeeAll() async {
    final headerFinder = find.byKey(WidgetKeys.featuredProductsSeeAll);
    final buttonFinder = find.descendant(
      of: headerFinder,
      matching: find.byType(TextButton),
    );
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
  }

  Future<void> tapFeaturedCourt(String id) async {
    final finder = find.byKey(WidgetKeys.featuredCourtItem(id));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapFeaturedProduct(String id) async {
    final finder = find.byKey(WidgetKeys.featuredProductItem(id));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> scrollHome(double offset) async {
    await tester.drag(
      find.byKey(WidgetKeys.homeScrollView),
      Offset(0, -offset),
    );
    await tester.pumpAndSettle();
  }
}
