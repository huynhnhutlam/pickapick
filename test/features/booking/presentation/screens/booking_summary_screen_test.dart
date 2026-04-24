import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:pickle_pick/core/enum/enum.dart';
import 'package:pickle_pick/features/booking/domain/entities/equipment.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/features/booking/presentation/screens/booking_summary_screen.dart';

import '../../../../shared/mocks.dart';
import '../../../../test_helper.dart';
import '../robots/booking_robot.dart';

void main() {
  late MockCourtRepository mockCourtRepository;

  final testDate = DateTime(2026, 4, 25);
  const testSlot = '08:00 - 10:00';
  const testPrice = 240000.0;

  final testEquipments = [
    const Equipment(
      id: 'eq-1',
      name: 'Vợt Pickleball',
      pricePerUnit: 50000,
      quantity: 0,
    ),
    const Equipment(
      id: 'eq-2',
      name: 'Bóng Pickleball',
      pricePerUnit: 20000,
      quantity: 0,
    ),
  ];

  setUp(() {
    mockCourtRepository = MockCourtRepository();

    when(() => mockCourtRepository.getRentalServices())
        .thenAnswer((_) async => right(testEquipments));
  });

  Future<void> pumpBookingSummaryScreen(
    WidgetTester tester, {
    List<Override> additionalOverrides = const [],
  }) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await tester.pumpTestApp(
      BookingSummaryScreen(
        facilityId: 'facility-1',
        courtId: 'court-1',
        courtName: 'Sân Trung Tâm - Sân A',
        courtAddress: '123 Đường Chính',
        courtImage: 'https://example.com/court.png',
        selectedDate: testDate,
        selectedSlot: testSlot,
        price: testPrice,
      ),
      overrides: [
        courtRepositoryProvider.overrideWithValue(mockCourtRepository),
        ...additionalOverrides,
      ],
    );
    await tester.pumpAndSettle();
  }

  group('BookingSummaryScreen', () {
    testWidgets(
      'should display scaffold and app bar title',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingSummaryScreen(tester);

        robot.expectBookingSummaryVisible();
        robot.expectText(AppStrings.bookingSummaryTitle);
      },
    );

    testWidgets(
      'should display court info card with name and address',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingSummaryScreen(tester);

        robot.expectText('Sân Trung Tâm - Sân A');
        robot.expectText('123 Đường Chính');
      },
    );

    testWidgets(
      'should display booking detail section with date and time',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingSummaryScreen(tester);

        robot.expectText(AppStrings.bookingDetailSection);
        robot.expectText('25/04/2026');
        robot.expectText(testSlot);
      },
    );

    testWidgets(
      'should display payment method section with all options',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingSummaryScreen(tester);

        robot.expectText(AppStrings.paymentMethodSection);

        for (final method in PaymentMethod.values) {
          final finder = find.text(method.label);
          await tester.ensureVisible(finder);
          expect(finder, findsOneWidget);
        }
      },
    );

    testWidgets(
      'should display confirm and pay button',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingSummaryScreen(tester);

        robot.expectConfirmBookingVisible();
      },
    );

    testWidgets(
      'should display payment info section with total',
      (tester) async {
        await pumpBookingSummaryScreen(tester);

        final paymentLabel = find.text(AppStrings.paymentInfoSection);
        await tester.ensureVisible(paymentLabel);
        expect(paymentLabel, findsOneWidget);

        final totalLabel = find.text(AppStrings.totalAmount);
        await tester.ensureVisible(totalLabel);
        expect(totalLabel, findsOneWidget);
      },
    );

    testWidgets(
      'should display equipment rental section when services loaded',
      (tester) async {
        final robot = BookingRobot(tester);

        await pumpBookingSummaryScreen(tester);

        final sectionFinder = find.text(
          AppStrings.equipmentRentalSection,
        );
        await tester.ensureVisible(sectionFinder);
        expect(sectionFinder, findsOneWidget);

        robot.expectText('Vợt Pickleball');
        robot.expectText('Bóng Pickleball');
      },
    );

    testWidgets(
      'should display voucher section with input and apply button',
      (tester) async {
        await pumpBookingSummaryScreen(tester);

        final sectionFinder = find.text(AppStrings.voucherSection);
        await tester.ensureVisible(sectionFinder);
        expect(sectionFinder, findsOneWidget);

        final applyButton = find.text(AppStrings.btnApplyVoucher);
        await tester.ensureVisible(applyButton);
        expect(applyButton, findsOneWidget);
      },
    );
  });
}
