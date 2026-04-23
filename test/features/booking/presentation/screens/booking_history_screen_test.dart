import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickle_pick/core/enum/enum.dart';
import 'package:pickle_pick/features/booking/domain/entities/booked_court.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_providers.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/features/booking/presentation/screens/booking_history_screen.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/mocks.dart';
import '../../../../test_helper.dart';
import '../robots/booking_robot.dart';

/// A fake [User] for testing that avoids depending on Supabase internals.
class FakeUser extends Fake implements User {
  @override
  String get id => 'user-123';

  @override
  String get email => 'test@example.com';
}

void main() {
  late MockCourtRepository mockCourtRepository;

  final testBookings = [
    BookedCourt(
      id: 'booking-abc12',
      courtName: 'Sân Trung Tâm - Sân A',
      courtAddress: '123 Đường Chính',
      courtImage: 'https://example.com/court.png',
      date: DateTime(2026, 4, 25),
      slot: '08:00 - 10:00',
      price: 240000,
      status: BookingStatus.upcoming,
      createdAt: DateTime(2026, 4, 21, 10, 30),
    ),
    BookedCourt(
      id: 'other-def34',
      courtName: 'Green Garden - Sân B',
      courtAddress: '456 Đường Phụ',
      courtImage: 'https://example.com/court2.png',
      date: DateTime(2026, 4, 20),
      slot: '16:00 - 18:00',
      price: 360000,
      status: BookingStatus.completed,
      createdAt: DateTime(2026, 4, 19, 14, 0),
    ),
  ];

  setUp(() {
    mockCourtRepository = MockCourtRepository();
  });

  Future<void> pumpBookingHistoryScreen(
    WidgetTester tester, {
    AsyncValue<List<BookedCourt>>? bookingState,
    bool settle = true,
  }) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await tester.pumpTestApp(
      const BookingHistoryScreen(),
      overrides: [
        courtRepositoryProvider.overrideWithValue(mockCourtRepository),
        // Override the booking provider with a pre-built state
        // to avoid Supabase dependency.
        bookingProvider.overrideWith(
          () => _FakeBookingNotifier(
            bookingState ?? AsyncData(testBookings),
          ),
        ),
      ],
    );
    if (settle) {
      await tester.pumpAndSettle();
    }
  }

  group('BookingHistoryScreen', () {
    testWidgets(
      'should display app bar with title',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingHistoryScreen(tester);

        robot.expectBookingHistoryTitle();
      },
    );

    testWidgets(
      'should display list of bookings when data is loaded',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingHistoryScreen(tester);

        robot.expectBookingHistoryItemVisible(testBookings[0].id);
        robot.expectBookingHistoryItemVisible(testBookings[1].id);

        robot.expectBookingItemVisible('Sân Trung Tâm - Sân A');
        robot.expectBookingItemVisible('Green Garden - Sân B');
      },
    );

    testWidgets(
      'should display booking price for each item',
      (tester) async {
        final robot = BookingRobot(tester);
        await pumpBookingHistoryScreen(tester);

        robot.expectBookingPriceVisible(testBookings[0].id, 240000.0.toVND());
        robot.expectBookingPriceVisible(testBookings[1].id, 360000.0.toVND());
      },
    );

    testWidgets(
      'should display status badges',
      (tester) async {
        final robot = BookingRobot(tester);
        await pumpBookingHistoryScreen(tester);

        robot.expectBookingStatusVisible(
          testBookings[0].id,
          BookingStatus.upcoming.label,
        );
        robot.expectBookingStatusVisible(
          testBookings[1].id,
          BookingStatus.completed.label,
        );
      },
    );

    testWidgets(
      'should display empty state when no bookings exist',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingHistoryScreen(
          tester,
          bookingState: const AsyncData([]),
        );

        robot.expectEmptyBookingHistory();
      },
    );

    testWidgets(
      'should display loading indicator while loading',
      (tester) async {
        final robot = BookingRobot(tester);
        await pumpBookingHistoryScreen(
          tester,
          bookingState: const AsyncValue<List<BookedCourt>>.loading(),
          settle: false,
        );

        // Don't settle—loading indicator should be on screen.
        await tester.pump(const Duration(milliseconds: 10));
        await tester.pump();

        robot.expectLoadingIndicatorVisible();
      },
    );

    testWidgets(
      'should display error message and retry button on error',
      (tester) async {
        final robot = BookingRobot(tester);
        await pumpBookingHistoryScreen(
          tester,
          bookingState: AsyncError('Network error', StackTrace.current),
        );

        robot.expectErrorTextVisible('Network error');
        robot.expectRetryButtonVisible();
      },
    );

    testWidgets(
      'should display booking ID prefix',
      (tester) async {
        final robot = BookingRobot(tester);
        await pumpBookingHistoryScreen(tester);

        // Booking ID 'booking-abc12' → '#PBBOOKI'
        robot.expectBookingIdVisible('#PB');
      },
    );
  });
}

/// A fake [Booking] notifier that returns a pre-built state
/// without depending on Supabase auth or real repository calls.
class _FakeBookingNotifier extends Booking {
  final AsyncValue<List<BookedCourt>> _initialState;

  _FakeBookingNotifier(this._initialState);

  @override
  FutureOr<List<BookedCourt>> build() {
    // Return async data from the initial state directly.
    return _initialState.when(
      data: (data) => data,
      loading: () => Completer<List<BookedCourt>>().future,
      error: (e, s) => throw e,
    );
  }
}
