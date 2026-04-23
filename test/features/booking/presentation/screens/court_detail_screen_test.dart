import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/error/failures.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/domain/entities/court.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/features/booking/presentation/screens/court_detail_screen.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';

import '../../../../shared/mocks.dart';
import '../../../../test_helper.dart';
import '../robots/booking_robot.dart';

void main() {
  late MockCourtRepository mockCourtRepository;
  late MockStackRouter mockRouter;
  const courtId = 'court-1';

  setUpAll(() {
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
    mockRouter = MockStackRouter();

    when(() => mockRouter.push(any())).thenAnswer((_) async => null);
  });

  Future<void> pumpCourtDetailScreen(
    WidgetTester tester, {
    StackRouter? router,
  }) async {
    await tester.pumpTestApp(
      const CourtDetailScreen(courtId: courtId),
      overrides: [
        courtRepositoryProvider.overrideWithValue(mockCourtRepository),
      ],
      router: router,
    );
    await tester.pumpAndSettle();
  }

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

  group('CourtDetailScreen', () {
    testWidgets('should display court details when data is loaded',
        (tester) async {
      final robot = BookingRobot(tester);

      when(() => mockCourtRepository.getCourtDetails(courtId))
          .thenAnswer((_) async => right(testCourt));

      await pumpCourtDetailScreen(tester);

      robot.expectCourtDetailVisible();
      expect(find.text('Pickleball Central'), findsAtLeastNWidgets(1));
      expect(find.text('123 Main St'), findsOneWidget);
      expect(find.text('The best court in town'), findsOneWidget);
      expect(find.text(testCourt.pricePerHour.toVND()), findsOneWidget);
    });

    testWidgets('should display error message when loading fails',
        (tester) async {
      when(() => mockCourtRepository.getCourtDetails(courtId))
          .thenAnswer((_) async => left(const ServerFailure('Database error')));

      await pumpCourtDetailScreen(tester);

      expect(find.textContaining('Database error'), findsOneWidget);
    });

    testWidgets(
        'should navigate to SlotPickerRoute when Book Now button is tapped',
        (tester) async {
      final robot = BookingRobot(tester);

      when(() => mockCourtRepository.getCourtDetails(courtId))
          .thenAnswer((_) async => right(testCourt));

      await pumpCourtDetailScreen(tester, router: mockRouter);

      await robot.tapBookNow();

      verify(() => mockRouter.push(any(that: isA<SlotPickerRoute>())))
          .called(1);
    });
  });
}
