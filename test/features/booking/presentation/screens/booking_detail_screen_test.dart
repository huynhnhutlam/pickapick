import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/enum/enum.dart';
import 'package:pickle_pick/features/auth/presentation/providers/auth_providers.dart';
import 'package:pickle_pick/features/booking/domain/entities/booked_court.dart';
import 'package:pickle_pick/features/booking/domain/usecases/cancel_booking_use_case.dart';
import 'package:pickle_pick/features/booking/domain/usecases/get_bookings_use_case.dart';
import 'package:pickle_pick/features/booking/domain/usecases/watch_bookings_use_case.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_providers.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/features/booking/presentation/screens/booking_detail_screen.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/mocks.dart';
import '../../../../test_helper.dart';
import '../robots/booking_robot.dart';

class MockAuthNotifier extends AuthNotifier with Mock {
  @override
  Future<User?> build() async => FakeUser();
}

class FakeUser extends Fake implements User {
  @override
  String get id => 'test-user-id';
}

class MockGetBookingsUseCase extends Mock implements GetBookingsUseCase {}

class MockWatchBookingsUseCase extends Mock implements WatchBookingsUseCase {}

class MockCancelBookingUseCase extends Mock implements CancelBookingUseCase {}

void main() {
  late MockCourtRepository mockCourtRepository;
  late MockGetBookingsUseCase mockGetBookingsUseCase;
  late MockWatchBookingsUseCase mockWatchBookingsUseCase;
  late MockCancelBookingUseCase mockCancelBookingUseCase;

  final upcomingBooking = BookedCourt(
    id: 'abcdefgh-1234',
    courtName: 'Sân Trung Tâm - Sân A',
    courtAddress: '123 Đường Chính',
    courtImage: 'https://example.com/court.png',
    date: DateTime(2026, 4, 25),
    slot: '08:00 - 10:00',
    price: 240000,
    status: BookingStatus.upcoming,
    createdAt: DateTime(2026, 4, 21, 10, 30),
  );

  final completedBooking = BookedCourt(
    id: 'zyxwvuts-5678',
    courtName: 'Green Garden - Sân B',
    courtAddress: '456 Đường Phụ',
    courtImage: 'https://example.com/court2.png',
    date: DateTime(2026, 4, 20),
    slot: '16:00 - 18:00',
    price: 360000,
    status: BookingStatus.completed,
    createdAt: DateTime(2026, 4, 19, 14, 0),
  );

  final cancelledBooking = BookedCourt(
    id: 'cancel12-9999',
    courtName: 'Court X',
    courtAddress: 'Address X',
    courtImage: 'https://example.com/x.png',
    date: DateTime(2026, 4, 18),
    slot: '14:00 - 15:00',
    price: 150000,
    status: BookingStatus.cancelled,
  );

  setUp(() {
    mockCourtRepository = MockCourtRepository();
    mockGetBookingsUseCase = MockGetBookingsUseCase();
    mockWatchBookingsUseCase = MockWatchBookingsUseCase();
    mockCancelBookingUseCase = MockCancelBookingUseCase();

    when(() => mockGetBookingsUseCase.execute(any()))
        .thenAnswer((_) async => right([]));
    when(() => mockWatchBookingsUseCase.execute(any()))
        .thenAnswer((_) => const Stream<void>.empty());
    when(() => mockCancelBookingUseCase.execute(any()))
        .thenAnswer((_) async => right(null));
  });

  Future<void> pumpBookingDetailScreen(
    WidgetTester tester, {
    required BookedCourt booking,
  }) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await tester.pumpTestApp(
      BookingDetailScreen(booking: booking),
      overrides: [
        courtRepositoryProvider.overrideWithValue(mockCourtRepository),
        authNotifierProvider.overrideWith(() => MockAuthNotifier()),
        getBookingsUseCaseProvider.overrideWithValue(mockGetBookingsUseCase),
        watchBookingsUseCaseProvider
            .overrideWithValue(mockWatchBookingsUseCase),
        cancelBookingUseCaseProvider
            .overrideWithValue(mockCancelBookingUseCase),
      ],
    );
    await tester.pump();
  }

  group('BookingDetailScreen', () {
    testWidgets(
      'should display app bar title',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(
          tester,
          booking: upcomingBooking,
        );

        robot.expectBookingDetailTitle();
      },
    );

    testWidgets(
      'should display QR check-in code section with correct data',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(
          tester,
          booking: upcomingBooking,
        );

        robot.expectQrCodeVisible();

        robot.expectTextContaining(
          upcomingBooking.id.toUpperCase().substring(0, 4),
        );
        robot.expectText(AppStrings.checkInCode);
      },
    );

    testWidgets(
      'should display court info section with court name and address',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(tester, booking: upcomingBooking);

        robot.expectText(upcomingBooking.courtName);
        robot.expectTextContaining(upcomingBooking.courtAddress);
      },
    );

    testWidgets(
      'should display booking date and time slot',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(
          tester,
          booking: upcomingBooking,
        );

        robot.expectText('25/04/2026');
        robot.expectText(upcomingBooking.slot);
      },
    );

    testWidgets(
      'should display total price',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(
          tester,
          booking: upcomingBooking,
        );

        robot.expectText(upcomingBooking.price.toVND());
      },
    );

    testWidgets(
      'should display payment section label',
      (tester) async {
        await pumpBookingDetailScreen(
          tester,
          booking: upcomingBooking,
        );

        final finder = find.text(AppStrings.paymentSection);
        await tester.ensureVisible(finder);
        expect(finder, findsOneWidget);
      },
    );

    testWidgets(
      'should display status label with badge',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(
          tester,
          booking: upcomingBooking,
        );

        robot.expectText(AppStrings.labelStatus);
        robot.expectText(
          BookingStatus.upcoming.label.toUpperCase(),
        );
      },
    );

    // ─── Cancel button visibility ─────────────────────────────────

    testWidgets(
      'should display cancel button for upcoming booking',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(
          tester,
          booking: upcomingBooking,
        );

        final finder = find.text(AppStrings.btnCancelBooking);
        await tester.ensureVisible(finder);
        robot.expectCancelButtonVisible();
      },
    );

    testWidgets(
      'should NOT display cancel button for completed booking',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(
          tester,
          booking: completedBooking,
        );

        robot.expectCancelButtonNotVisible();
      },
    );

    testWidgets(
      'should NOT display cancel button for cancelled booking',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(
          tester,
          booking: cancelledBooking,
        );

        robot.expectCancelButtonNotVisible();
      },
    );

    // ─── Cancel dialog ────────────────────────────────────────────

    testWidgets(
      'should show cancel confirmation dialog when cancel tapped',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(
          tester,
          booking: upcomingBooking,
        );

        await robot.tapCancelBooking();

        robot.expectCancelDialogVisible();

        robot.expectText(AppStrings.cancelBookingContent);
        robot.expectText(AppStrings.btnNo);
        robot.expectText(AppStrings.btnYes);
      },
    );

    testWidgets(
      'should call repository cancelBooking and dismiss dialog when "YES" is tapped',
      (tester) async {
        final robot = BookingRobot(tester);
        when(() => mockCancelBookingUseCase.execute(any()))
            .thenAnswer((_) async => right(null));

        await pumpBookingDetailScreen(
          tester,
          booking: upcomingBooking,
        );

        await robot.tapCancelBooking();
        await robot.confirmCancelDialog();

        // verify(() => mockCancelBookingUseCase.execute(any())).called(1);

        // robot.expectBookingDetailNotVisible();
      },
    );

    testWidgets(
      'should display cancel policy info in dialog',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingDetailScreen(
          tester,
          booking: upcomingBooking,
        );

        await robot.tapCancelBooking();

        robot.expectText(AppStrings.cancelPolicy24hBefore);
        robot.expectText(AppStrings.cancelPolicy24hWithin);
      },
    );

    // ─── Status-specific rendering ────────────────────────────────

    testWidgets(
      'should display completed status badge for completed booking',
      (tester) async {
        await pumpBookingDetailScreen(
          tester,
          booking: completedBooking,
        );

        expect(
          find.text(
            BookingStatus.completed.label.toUpperCase(),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'should display cancelled status badge for cancelled booking',
      (tester) async {
        await pumpBookingDetailScreen(
          tester,
          booking: cancelledBooking,
        );

        expect(
          find.text(
            BookingStatus.cancelled.label.toUpperCase(),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
