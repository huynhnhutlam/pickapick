import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/error/failures.dart';
import 'package:pickle_pick/features/booking/domain/entities/court.dart';
import 'package:pickle_pick/features/booking/domain/entities/equipment.dart';
import 'package:pickle_pick/features/booking/domain/entities/sub_court.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';

import '../../../../shared/mocks.dart';

void main() {
  late MockCourtRepository mockRepository;

  setUp(() {
    mockRepository = MockCourtRepository();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        courtRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  const testCourt = Court(
    id: 'court-1',
    name: 'Court 1',
    address: 'Address 1',
    images: [],
    pricePerHour: 100000,
    rating: 5.0,
    reviewCount: 10,
    description: 'Desc',
    amenities: [],
    rules: [],
    openingHours: '',
  );

  group('court_providers tests', () {
    test('allCourts returns list of courts on success', () async {
      final container = makeContainer();
      when(() => mockRepository.getCourts())
          .thenAnswer((_) async => right([testCourt]));

      final result = await container.read(allCourtsProvider.future);

      expect(result, equals([testCourt]));
      verify(() => mockRepository.getCourts()).called(1);
    });

    test('allCourts throws failure on error', () async {
      final container = makeContainer();
      when(() => mockRepository.getCourts())
          .thenAnswer((_) async => left(const ServerFailure('DB Error')));

      expect(
        () => container.read(allCourtsProvider.future),
        throwsA(isA<ServerFailure>()),
      );
      verify(() => mockRepository.getCourts()).called(1);
    });

    test('courtDetails returns a court on success', () async {
      final container = makeContainer();
      when(() => mockRepository.getCourtDetails('court-1'))
          .thenAnswer((_) async => right(testCourt));

      final result =
          await container.read(courtDetailsProvider('court-1').future);

      expect(result, equals(testCourt));
      verify(() => mockRepository.getCourtDetails('court-1')).called(1);
    });

    test('courtDetails throws failure on error', () async {
      final container = makeContainer();
      when(() => mockRepository.getCourtDetails('court-error'))
          .thenAnswer((_) async => left(const ServerFailure('Not found')));

      expect(
        () => container.read(courtDetailsProvider('court-error').future),
        throwsA(isA<ServerFailure>()),
      );
      verify(() => mockRepository.getCourtDetails('court-error')).called(1);
    });

    test('subCourts returns list of sub-courts on success', () async {
      final container = makeContainer();
      const subCourt = SubCourt(
        id: 'sub-1',
        facilityId: 'court-1',
        name: 'Sân A',
        courtNumber: 1,
        surfaceType: 'Hard',
        pricePerHour: 100000,
        peakPricePerHour: 150000,
        isActive: true,
        images: [],
        maxPlayers: 4,
      );

      when(() => mockRepository.getSubCourts('court-1'))
          .thenAnswer((_) async => right([subCourt]));

      final result = await container.read(subCourtsProvider('court-1').future);

      expect(result, equals([subCourt]));
      verify(() => mockRepository.getSubCourts('court-1')).called(1);
    });

    test('rentalServices returns list of equipment on success', () async {
      final container = makeContainer();
      const equipment = Equipment(
        id: 'eq-1',
        name: 'Vợt',
        pricePerUnit: 50000,
        quantity: 10,
      );

      when(() => mockRepository.getRentalServices())
          .thenAnswer((_) async => right([equipment]));

      final result = await container.read(rentalServicesProvider.future);

      expect(result, equals([equipment]));
      verify(() => mockRepository.getRentalServices()).called(1);
    });

    test('bookedSlots returns list of booked slots on success', () async {
      final container = makeContainer();
      final date = DateTime(2026, 4, 15);
      when(() => mockRepository.getBookedSlots('court-1', date))
          .thenAnswer((_) async => right(['08:00 - 09:00']));

      final result = await container.read(
        bookedSlotsProvider(courtId: 'court-1', date: date).future,
      );

      expect(result, equals(['08:00 - 09:00']));
      verify(() => mockRepository.getBookedSlots('court-1', date)).called(1);
    });

    test('availableSlots returns list of available slots on success', () async {
      final container = makeContainer();
      final date = DateTime(2026, 4, 15);
      when(() => mockRepository.getAvailableSlots('court-1', date))
          .thenAnswer((_) async => right(['10:00 - 11:00']));

      final result = await container.read(
        availableSlotsProvider(courtId: 'court-1', date: date).future,
      );

      expect(result, equals(['10:00 - 11:00']));
      verify(() => mockRepository.getAvailableSlots('court-1', date)).called(1);
    });
  });
}
