import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/core/services/firebase_services/analytics_services.dart';
import 'package:pickle_pick/features/booking/domain/entities/court.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/features/booking/presentation/screens/court_list_screen.dart';

import '../../../../shared/mocks.dart';
import '../../../../test_helper.dart';
import '../robots/booking_robot.dart';

void main() {
  late MockCourtRepository mockCourtRepository;
  late MockAnalyticsService mockAnalyticsService;
  late MockStackRouter mockRouter;

  setUpAll(() {
    registerFallbackValue(const BookingRoute());
    registerFallbackValue(CourtDetailRoute(courtId: ''));
    registerFallbackValue(
      SlotPickerRoute(
        courtId: '',
        courtName: '',
        courtAddress: '',
      ),
    );
  });

  setUp(() {
    mockCourtRepository = MockCourtRepository();
    mockAnalyticsService = MockAnalyticsService();
    mockRouter = MockStackRouter();

    when(
      () => mockAnalyticsService.logDetailCourt(
        courtId: any(named: 'courtId'),
        courtName: any(named: 'courtName'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockRouter.push(any())).thenAnswer((_) async => null);
  });

  Future<void> pumpBookingScreen(
    WidgetTester tester, {
    StackRouter? router,
  }) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());

    await tester.pumpTestApp(
      const BookingScreen(),
      overrides: [
        courtRepositoryProvider.overrideWithValue(mockCourtRepository),
        analyticsProvider.overrideWithValue(mockAnalyticsService),
      ],
      router: router,
    );
    await tester.pumpAndSettle();
  }

  final testCourts = [
    const Court(
      id: 'court-1',
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
    ),
    const Court(
      id: 'court-2',
      name: 'Green Garden Court',
      address: '456 Side St',
      images: ['https://example.com/court2.png'],
      pricePerHour: 120000,
      rating: 4.2,
      reviewCount: 15,
      description: 'Lush green surroundings',
      amenities: ['Water', 'Shower'],
      rules: ['No smoking'],
      openingHours: '07:00 - 21:00',
    ),
  ];

  group('BookingScreen (Court List)', () {
    testWidgets('should display list of courts when data is loaded',
        (tester) async {
      final robot = BookingRobot(tester);

      when(() => mockCourtRepository.getCourts())
          .thenAnswer((_) async => right(testCourts));

      await pumpBookingScreen(tester);

      robot.expectBookingScreenVisible();
      robot.expectCourtListVisible();
      robot.expectCourtItemVisible('court-1');
      robot.expectCourtItemVisible('court-2');

      expect(find.text('Pickleball Central'), findsOneWidget);
      expect(find.text('Green Garden Court'), findsOneWidget);
    });

    testWidgets('should display empty message when no courts found',
        (tester) async {
      when(() => mockCourtRepository.getCourts())
          .thenAnswer((_) async => right([]));

      await pumpBookingScreen(tester);

      expect(find.text(AppStrings.noCourtFound), findsOneWidget);
    });

    testWidgets('should filter courts when searching', (tester) async {
      final robot = BookingRobot(tester);

      when(() => mockCourtRepository.getCourts())
          .thenAnswer((_) async => right(testCourts));

      await pumpBookingScreen(tester);

      await robot.tapSearchIcon();
      await robot.enterSearchQuery('central');

      expect(find.text('Pickleball Central'), findsOneWidget);
      expect(find.text('Green Garden Court'), findsNothing);
    });

    testWidgets('should navigate to CourtDetailRoute when court item is tapped',
        (tester) async {
      final robot = BookingRobot(tester);

      when(() => mockCourtRepository.getCourts())
          .thenAnswer((_) async => right(testCourts));

      await pumpBookingScreen(tester, router: mockRouter);

      await robot.tapCourtItem('court-1');

      verify(() => mockRouter.push(any(that: isA<CourtDetailRoute>())))
          .called(1);
    });

    testWidgets(
        'should navigate to SlotPickerRoute when order button is tapped',
        (tester) async {
      final robot = BookingRobot(tester);

      when(() => mockCourtRepository.getCourts())
          .thenAnswer((_) async => right(testCourts));

      await pumpBookingScreen(tester, router: mockRouter);

      await robot.tapCourtOrderButton('court-1');

      verify(() => mockRouter.push(any(that: isA<SlotPickerRoute>())))
          .called(1);
    });
  });
}
