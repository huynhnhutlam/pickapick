import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/enum/enum.dart';
import 'package:pickle_pick/core/error/failures.dart';
import 'package:pickle_pick/features/auth/presentation/providers/auth_providers.dart';
import 'package:pickle_pick/features/booking/domain/entities/booked_court.dart';
import 'package:pickle_pick/features/booking/domain/entities/equipment.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_providers.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/mocks.dart';

class FakeUser extends Fake implements User {
  @override
  String get id => 'user-123';
}

class FakeAuthNotifier extends AuthNotifier {
  final User? _user;
  FakeAuthNotifier(this._user);

  @override
  Future<User?> build() async {
    return _user;
  }
}

void main() {
  late MockCourtRepository mockRepository;

  final testUser = FakeUser();
  final testBookings = [
    BookedCourt(
      id: 'book-1',
      courtName: 'C1',
      courtAddress: 'A1',
      courtImage: '',
      date: DateTime(2026, 4, 25),
      slot: '06:00',
      price: 100000,
      status: BookingStatus.upcoming,
    ),
  ];

  setUp(() {
    mockRepository = MockCourtRepository();
  });

  ProviderContainer makeContainer({User? user}) {
    final container = ProviderContainer(
      overrides: [
        courtRepositoryProvider.overrideWithValue(mockRepository),
        authNotifierProvider.overrideWith(() => FakeAuthNotifier(user)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('BookingNotifier tests', () {
    test('returns empty if user is not authenticated', () async {
      final container = makeContainer(user: null);
      final sub = container.listen(bookingProvider, (_, __) {});

      final result = await container.read(bookingProvider.future);
      expect(result, isEmpty);
      sub.close();
    });

    test('fetches bookings on success and watches changes', () async {
      final container = makeContainer(user: testUser);
      final sub = container.listen(bookingProvider, (_, __) {});
      final streamController = StreamController<void>();

      when(() => mockRepository.getBookings(testUser.id))
          .thenAnswer((_) async => right(testBookings));
      when(() => mockRepository.watchBookings(testUser.id))
          .thenAnswer((_) => streamController.stream);

      final result = await container.read(bookingProvider.future);
      expect(result, equals(testBookings));
      verify(() => mockRepository.watchBookings(testUser.id)).called(1);

      await streamController.close();
      sub.close();
    });

    test('throws error if fetching bookings fails', () async {
      final container = makeContainer(user: testUser);
      final sub = container.listen(bookingProvider, (_, __) {});

      when(() => mockRepository.getBookings(testUser.id))
          .thenAnswer((_) async => left(const ServerFailure('DB Error')));
      when(() => mockRepository.watchBookings(testUser.id))
          .thenAnswer((_) => const Stream.empty());

      try {
        await container.read(bookingProvider.future);
        fail('Should have thrown an error');
      } catch (e) {
        expect(e, isA<ServerFailure>());
        expect((e as ServerFailure).message, 'DB Error');
      }
      sub.close();
    });

    test('cancelBooking resolves correctly', () async {
      final container = makeContainer(user: testUser);
      final sub = container.listen(bookingProvider, (_, __) {});

      when(() => mockRepository.getBookings(testUser.id))
          .thenAnswer((_) async => right(testBookings));
      when(() => mockRepository.cancelBooking('book-1'))
          .thenAnswer((_) async => right(null));
      when(() => mockRepository.watchBookings(testUser.id))
          .thenAnswer((_) => const Stream.empty());

      await container.read(bookingProvider.future);

      await container.read(bookingProvider.notifier).cancelBooking('book-1');
      verify(() => mockRepository.cancelBooking('book-1')).called(1);

      await container.read(bookingProvider.future);
      sub.close();
    });

    test('cancelBooking throws failure on error', () async {
      final container = makeContainer(user: testUser);
      final sub = container.listen(bookingProvider, (_, __) {});

      when(() => mockRepository.getBookings(testUser.id))
          .thenAnswer((_) async => right(testBookings));
      when(() => mockRepository.cancelBooking('book-1'))
          .thenAnswer((_) async => left(const ServerFailure('Fail')));
      when(() => mockRepository.watchBookings(testUser.id))
          .thenAnswer((_) => const Stream.empty());

      await container.read(bookingProvider.future);

      final notifier = container.read(bookingProvider.notifier);
      try {
        await notifier.cancelBooking('book-1');
        fail('Should have thrown');
      } catch (e) {
        expect(e, isA<ServerFailure>());
        expect((e as ServerFailure).message, 'Fail');
      }
      sub.close();
    });
  });

  group('EquipmentSelection tests', () {
    final testEquipment = <Equipment>[
      const Equipment(
        id: 'eq-1',
        name: 'Racket 1',
        pricePerUnit: 50000,
        quantity: 10,
      ),
      const Equipment(
        id: 'eq-2',
        name: 'Ball',
        pricePerUnit: 10000,
        quantity: 50,
      ),
    ];

    test('initializes with quantity 0 for all equipments', () async {
      final container = makeContainer(user: null);
      when(() => mockRepository.getRentalServices())
          .thenAnswer((_) async => right(testEquipment));

      final state = await container.read(equipmentSelectionProvider.future);
      expect(state.length, 2);
      expect(state.every((e) => e.quantity == 0), isTrue);
    });

    test('increment increases quantity', () async {
      final container = makeContainer(user: null);
      when(() => mockRepository.getRentalServices())
          .thenAnswer((_) async => right(testEquipment));

      await container.read(equipmentSelectionProvider.future);

      container.read(equipmentSelectionProvider.notifier).increment('eq-1');

      final stateValue = container.read(equipmentSelectionProvider).value!;
      final eq1 = stateValue.firstWhere((e) => e.id == 'eq-1');
      expect(eq1.quantity, 1);
    });

    test('decrement decreases quantity but not below 0', () async {
      final container = makeContainer(user: null);
      when(() => mockRepository.getRentalServices())
          .thenAnswer((_) async => right(testEquipment));

      await container.read(equipmentSelectionProvider.future);

      container.read(equipmentSelectionProvider.notifier).increment('eq-1');
      container.read(equipmentSelectionProvider.notifier).increment('eq-1');

      container.read(equipmentSelectionProvider.notifier).decrement('eq-1');
      container.read(equipmentSelectionProvider.notifier).decrement('eq-1');
      container.read(equipmentSelectionProvider.notifier).decrement('eq-1');

      final stateValue = container.read(equipmentSelectionProvider).value!;
      final eq1 = stateValue.firstWhere((e) => e.id == 'eq-1');
      expect(eq1.quantity, 0);
    });

    test('computes totalPrice correctly', () async {
      final container = makeContainer(user: null);
      when(() => mockRepository.getRentalServices())
          .thenAnswer((_) async => right(testEquipment));

      await container.read(equipmentSelectionProvider.future);

      container.read(equipmentSelectionProvider.notifier).increment('eq-1');
      container.read(equipmentSelectionProvider.notifier).increment('eq-2');
      container.read(equipmentSelectionProvider.notifier).increment('eq-2');

      final totalPrice =
          container.read(equipmentSelectionProvider.notifier).totalPrice;
      expect(totalPrice, 70000.0);
    });
  });
}
