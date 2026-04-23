import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';

/// Robot pattern for booking feature widget tests.
///
/// Encapsulates UI interactions and assertions for the
/// booking flow screens: court list, court detail, slot picker,
/// booking summary, booking history, and booking detail.
class BookingRobot {
  BookingRobot(this.tester);

  final WidgetTester tester;

  // ─── Private helpers ────────────────────────────────────────────────────

  void _expectVisible(Key key) {
    expect(find.byKey(key), findsOneWidget);
  }

  void _expectNotVisible(Key key) {
    expect(find.byKey(key), findsNothing);
  }

  // ─── Court List Assertions ──────────────────────────────────────────────

  void expectBookingScreenVisible() =>
      _expectVisible(WidgetKeys.bookingScreenScaffold);

  void expectLoadingIndicatorVisible() =>
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

  void expectCourtListVisible() => _expectVisible(WidgetKeys.courtList);

  void expectCourtItemVisible(String id) =>
      _expectVisible(WidgetKeys.courtListItem(id));

  // ─── Court Detail Assertions ────────────────────────────────────────────

  void expectCourtDetailVisible() =>
      _expectVisible(WidgetKeys.courtDetailScaffold);

  void expectBookNowButtonVisible() => _expectVisible(WidgetKeys.bookNowButton);

  // ─── Slot Picker Assertions ─────────────────────────────────────────────

  void expectSlotPickerVisible() =>
      _expectVisible(WidgetKeys.slotPickerScaffold);

  void expectSlotVisible(String slot) =>
      _expectVisible(WidgetKeys.slotItem(slot));

  void expectContinueToSummaryVisible() =>
      _expectVisible(WidgetKeys.continueToSummaryButton);

  void expectSubCourtVisible(String id) =>
      _expectVisible(WidgetKeys.subCourtItem(id));

  void expectSubCourtNotVisible(String id) =>
      _expectNotVisible(WidgetKeys.subCourtItem(id));

  // ─── Booking Summary Assertions ─────────────────────────────────────────

  void expectBookingSummaryVisible() =>
      _expectVisible(WidgetKeys.bookingSummaryScaffold);

  void expectConfirmBookingVisible() =>
      _expectVisible(WidgetKeys.confirmBookingButton);

  // ─── Booking History Assertions ─────────────────────────────────────────

  void expectBookingHistoryVisible() =>
      _expectVisible(WidgetKeys.bookingHistoryScaffold);

  void expectEmptyBookingHistory() =>
      _expectVisible(WidgetKeys.emptyBookingState);

  void expectBookingHistoryItemVisible(String id) {
    expect(find.byKey(WidgetKeys.bookingHistoryItem(id)), findsOneWidget);
  }

  void expectBookingPriceVisible(String id, String price) {
    expect(find.byKey(WidgetKeys.bookingHistoryPrice(id)), findsOneWidget);
    expect(find.text(price), findsOneWidget);
  }

  void expectBookingStatusVisible(String id, String status) {
    expect(find.byKey(WidgetKeys.bookingHistoryStatus(id)), findsOneWidget);
    expect(find.text(status.toUpperCase()), findsOneWidget);
  }

  void expectBookingItemVisible(String name) {
    expect(find.text(name), findsOneWidget);
  }

  void expectBookingIdVisible(String prefix) {
    expect(find.textContaining(prefix), findsAtLeastNWidgets(1));
  }

  void expectRetryButtonVisible() {
    expect(find.text(AppStrings.btnRetry), findsOneWidget);
  }

  void expectBookingHistoryTitle() {
    expect(
      find.text(AppStrings.bookingHistoryTitle),
      findsOneWidget,
    );
  }

  // ─── Booking Detail Assertions ──────────────────────────────────────────

  void expectBookingDetailVisible() =>
      _expectVisible(WidgetKeys.bookingDetailScaffold);

  void expectBookingDetailNotVisible() =>
      expect(find.byKey(WidgetKeys.bookingDetailBody), findsNothing);

  void expectErrorTextVisible(String error) {
    expect(find.textContaining(error), findsOneWidget);
  }

  void expectCancelDialogVisible() {
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text(AppStrings.cancelBookingTitle),
      ),
      findsOneWidget,
    );
  }

  void expectQrCodeVisible() => _expectVisible(WidgetKeys.qrCodeImage);

  void expectBookingDetailTitle() {
    expect(
      find.text(AppStrings.bookingDetailTitle),
      findsOneWidget,
    );
  }

  void expectCancelButtonVisible() {
    _expectVisible(WidgetKeys.cancelBookingButton);
  }

  void expectCancelButtonNotVisible() {
    _expectNotVisible(WidgetKeys.cancelBookingButton);
  }

  // ─── Text Assertions ───────────────────────────────────────────────────

  void expectText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  void expectTextContaining(String text) {
    expect(find.textContaining(text), findsAtLeastNWidgets(1));
  }

  void expectNoText(String text) {
    expect(find.text(text), findsNothing);
  }

  // ─── Court List Interactions ────────────────────────────────────────────

  Future<void> tapSearchIcon() async {
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
  }

  Future<void> enterSearchQuery(String query) async {
    await tester.enterText(
      find.byKey(WidgetKeys.courtSearchField),
      query,
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapCourtItem(String id) async {
    final finder = find.byKey(WidgetKeys.courtListItem(id));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapCourtOrderButton(String id) async {
    final finder = find.byKey(WidgetKeys.courtOrderButton(id));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  // ─── Court Detail Interactions ──────────────────────────────────────────

  Future<void> tapBookNow() async {
    await tester.tap(find.byKey(WidgetKeys.bookNowButton));
    await tester.pumpAndSettle();
  }

  // ─── Slot Picker Interactions ───────────────────────────────────────────

  Future<void> tapSlot(String slot) async {
    final finder = find.byKey(WidgetKeys.slotItem(slot));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapSubCourt(String id) async {
    final finder = find.byKey(WidgetKeys.subCourtItem(id));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapRetry() async {
    await tester.tap(find.text(AppStrings.btnRetry));
    await tester.pumpAndSettle();
  }

  Future<void> tapDate(int index) async {
    final finder = find.byKey(WidgetKeys.dateItem(index));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapContinueToSummary() async {
    await tester.tap(find.byKey(WidgetKeys.continueToSummaryButton));
    await tester.pumpAndSettle();
  }

  // ─── Booking Summary Interactions ───────────────────────────────────────

  Future<void> tapConfirmBooking() async {
    await tester.tap(find.byKey(WidgetKeys.confirmBookingButton));
    await tester.pumpAndSettle();
  }

  // ─── Booking Detail Interactions ────────────────────────────────────────

  Future<void> tapCancelBooking() async {
    final finder = find.byKey(WidgetKeys.cancelBookingButton);
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    // Use pump() for manual timing or pumpAndSettle() for dialog animation
    await tester.pumpAndSettle();
  }

  Future<void> confirmCancelDialog() async {
    final finder = find.byKey(WidgetKeys.cancelConfirmYes);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> dismissCancelDialog() async {
    final finder = find.byKey(WidgetKeys.cancelConfirmNo);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapBookingHistoryItem(String id) async {
    final finder = find.byKey(WidgetKeys.bookingHistoryItem(id));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}
