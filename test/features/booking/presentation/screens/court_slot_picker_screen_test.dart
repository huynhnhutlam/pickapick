import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/domain/entities/court.dart';
import 'package:pickle_pick/features/booking/domain/entities/sub_court.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/features/booking/presentation/screens/court_slot_picker_screen.dart';

import '../../../../shared/mocks.dart';
import '../../../../test_helper.dart';
import '../robots/booking_robot.dart';

void main() {
  late MockCourtRepository mockCourtRepository;
  late MockStackRouter mockRouter;
  const courtId = 'facility-1';
  const subCourtId = 'sub-1';

  setUpAll(() {
    registerFallbackValue(
      BookingSummaryRoute(
        facilityId: '',
        courtId: '',
        courtName: '',
        courtAddress: '',
        courtImage: '',
        selectedDate: DateTime.now(),
        selectedSlot: '',
        price: 0,
      ),
    );
  });

  setUp(() {
    mockCourtRepository = MockCourtRepository();
    mockRouter = MockStackRouter();

    when(() => mockRouter.push(any())).thenAnswer((_) async => null);
  });

  const testCourt = Court(
    id: courtId,
    name: 'Pickleball Central',
    address: '123 Main St',
    images: ['https://example.com/court1.png'],
    pricePerHour: 150000,
    rating: 4.8,
    reviewCount: 25,
    description: 'The best court in town',
    amenities: ['Wifi', 'Parking'],
    rules: ['Wear proper shoes'],
    openingHours: '06:00 - 22:00',
  );

  final testSubCourts = [
    const SubCourt(
      id: subCourtId,
      facilityId: courtId,
      name: 'Court A',
      courtNumber: 1,
      surfaceType: 'Hard',
      pricePerHour: 150000,
      peakPricePerHour: 200000,
      isActive: true,
      images: [],
      maxPlayers: 4,
    ),
    const SubCourt(
      id: 'sub-2',
      facilityId: courtId,
      name: 'Court B',
      courtNumber: 2,
      surfaceType: 'Hard',
      pricePerHour: 150000,
      peakPricePerHour: 200000,
      isActive: true,
      images: [],
      maxPlayers: 4,
    ),
  ];

  final allDaySlots = [
    '06:00 - 07:00',
    '07:00 - 08:00',
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
    '19:00 - 20:00',
    '20:00 - 21:00',
    '21:00 - 22:00',
  ];

  Future<void> pumpSlotPickerScreen(
    WidgetTester tester, {
    StackRouter? router,
  }) async {
    await tester.pumpTestApp(
      const SlotPickerScreen(courtId: courtId),
      overrides: [
        courtRepositoryProvider.overrideWithValue(mockCourtRepository),
      ],
      router: router,
    );
    await tester.pumpAndSettle();
  }

  group('SlotPickerScreen', () {
    testWidgets('should display sub-courts and available slots',
        (tester) async {
      final robot = BookingRobot(tester);

      when(() => mockCourtRepository.getCourtDetails(courtId))
          .thenAnswer((_) async => right(testCourt));
      when(() => mockCourtRepository.getSubCourts(courtId))
          .thenAnswer((_) async => right(testSubCourts));
      when(() => mockCourtRepository.getAvailableSlots(any(), any()))
          .thenAnswer((_) async => right(allDaySlots));
      when(() => mockCourtRepository.getBookedSlots(any(), any()))
          .thenAnswer((_) async => right([]));

      await pumpSlotPickerScreen(tester);

      robot.expectSlotPickerVisible();
      robot.expectSubCourtVisible('sub-1');
      robot.expectSubCourtVisible('sub-2');

      // Check for some slots
      robot.expectSlotVisible('06:00 - 07:00');
    });

    testWidgets(
        'should show validation error when non-continuous slots are selected',
        (tester) async {
      final robot = BookingRobot(tester);

      when(() => mockCourtRepository.getCourtDetails(courtId))
          .thenAnswer((_) async => right(testCourt));
      when(() => mockCourtRepository.getSubCourts(courtId))
          .thenAnswer((_) async => right(testSubCourts));
      // Use a date far in the future to avoid "past slot" issues

      when(() => mockCourtRepository.getAvailableSlots(any(), any()))
          .thenAnswer((_) async => right(allDaySlots));
      when(() => mockCourtRepository.getBookedSlots(any(), any()))
          .thenAnswer((_) async => right([]));

      await pumpSlotPickerScreen(tester);

      // Select date far in future
      await robot.tapDate(5);

      // Select 06:00 - 07:00 and 08:00 - 09:00 (non-continuous)
      await robot.tapSlot('06:00 - 07:00');
      await robot.tapSlot('08:00 - 09:00');

      await robot.tapContinueToSummary();

      robot.expectTextContaining(AppStrings.valContinuousTime);
    });

    testWidgets(
        'should navigate to BookingSummaryRoute when valid slots are selected',
        (tester) async {
      final robot = BookingRobot(tester);

      when(() => mockCourtRepository.getCourtDetails(courtId))
          .thenAnswer((_) async => right(testCourt));
      when(() => mockCourtRepository.getSubCourts(courtId))
          .thenAnswer((_) async => right(testSubCourts));

      when(() => mockCourtRepository.getAvailableSlots(any(), any()))
          .thenAnswer((_) async => right(allDaySlots));
      when(() => mockCourtRepository.getBookedSlots(any(), any()))
          .thenAnswer((_) async => right([]));

      await pumpSlotPickerScreen(tester, router: mockRouter);

      // Select date far in future to be safe
      await robot.tapDate(5);

      // Select 06:00 - 07:00 and 07:00 - 08:00 (continuous)
      await robot.tapSlot('06:00 - 07:00');
      await robot.tapSlot('07:00 - 08:00');

      await robot.tapContinueToSummary();

      verify(() => mockRouter.push(any(that: isA<BookingSummaryRoute>())))
          .called(1);
      verifyNoMoreInteractions(mockRouter);
    });
  });
}
