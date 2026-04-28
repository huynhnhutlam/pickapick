import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/core/enum/enum.dart';
import 'package:pickle_pick/features/auth/presentation/providers/auth_providers.dart';
import 'package:pickle_pick/features/booking/domain/entities/booked_court.dart';
import 'package:pickle_pick/features/booking/domain/entities/equipment.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_providers.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_summary_riverpod.dart';
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

  setUpAll(() {
    registerFallbackValue(
      BookedCourt(
        id: '',
        courtName: '',
        courtAddress: '',
        courtImage: '',
        date: DateTime(2026),
        slot: '',
        price: 0,
        status: BookingStatus.upcoming,
      ),
    );
    registerFallbackValue(const Equipment(id: '', name: '', pricePerUnit: 0));
  });

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

  group('BookingSummary tests', () {
    test('initial state is correct', () {
      final container = makeContainer();
      final state = container.read(bookingSummaryProvider);

      expect(state.voucherCode, isEmpty);
      expect(state.discountAmount, 0);
      expect(state.isVoucherApplied, isFalse);
      expect(state.selectedPaymentMethod, PaymentMethod.picklePay);
      expect(state.isProcessing, isFalse);
    });

    test('applyVoucher updates state correctly', () {
      final container = makeContainer();
      final notifier = container.read(bookingSummaryProvider.notifier);

      final success = notifier.applyVoucher('SALE10');

      expect(success, isTrue);
      final state = container.read(bookingSummaryProvider);
      expect(state.voucherCode, 'SALE10');
      expect(state.isVoucherApplied, isTrue);
      expect(state.discountAmount, 10000.0);
    });

    test('setPaymentMethod updates state', () {
      final container = makeContainer();
      final notifier = container.read(bookingSummaryProvider.notifier);

      notifier.setPaymentMethod(PaymentMethod.momo);

      final state = container.read(bookingSummaryProvider);
      expect(state.selectedPaymentMethod, PaymentMethod.momo);
    });

    test('confirmBooking success flow', () async {
      final container = makeContainer(user: testUser);
      container.listen(bookingProvider, (_, __) {});

      when(() => mockRepository.getBookings(any()))
          .thenAnswer((_) async => right([]));
      when(() => mockRepository.watchBookings(any()))
          .thenAnswer((_) => const Stream.empty());
      when(() => mockRepository.getRentalServices())
          .thenAnswer((_) async => right([]));
      when(() => mockRepository.getBookedSlots(any(), any()))
          .thenAnswer((_) async => right([]));
      when(
        () => mockRepository.addBooking(
          userId: any(named: 'userId'),
          booking: any(named: 'booking'),
          facilityId: any(named: 'facilityId'),
          courtId: any(named: 'courtId'),
          equipment: any(named: 'equipment'),
          voucherCode: any(named: 'voucherCode'),
          discountAmount: any(named: 'discountAmount'),
          paymentMethod: any(named: 'paymentMethod'),
        ),
      ).thenAnswer((_) async => right(null));

      final date = DateTime(2026, 4, 15);
      await container.read(bookingSummaryProvider.notifier).confirmBooking(
            facilityId: 'fac-1',
            courtId: 'court-1',
            courtName: 'Court 1',
            courtAddress: 'Addr 1',
            courtImage: 'img',
            selectedDate: date,
            selectedSlot: '08:00 - 09:00',
            basePrice: 50000,
          );

      verify(
        () => mockRepository.addBooking(
          userId: testUser.id,
          booking: any(named: 'booking'),
          facilityId: 'fac-1',
          courtId: 'court-1',
          equipment: any(named: 'equipment'),
          voucherCode: any(named: 'voucherCode'),
          discountAmount: any(named: 'discountAmount'),
          paymentMethod: PaymentMethod.picklePay.name,
        ),
      ).called(1);

      expect(container.read(bookingSummaryProvider).isProcessing, isFalse);
    });

    test('confirmBooking throws exception if user not logged in', () async {
      final container = makeContainer(user: null);

      await expectLater(
        () => container.read(bookingSummaryProvider.notifier).confirmBooking(
              facilityId: 'fac-1',
              courtId: 'court-1',
              courtName: 'C1',
              courtAddress: 'A1',
              courtImage: 'I1',
              selectedDate: DateTime.now(),
              selectedSlot: '08:00',
              basePrice: 100,
            ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Pricing providers tests', () {
    test('totalBookingPrice calculates correctly with discount', () async {
      final container = makeContainer();
      when(() => mockRepository.getRentalServices())
          .thenAnswer((_) async => right([]));

      container.read(bookingSummaryProvider.notifier).applyVoucher('VOUCHER');

      final totalPrice =
          container.read(totalBookingPriceProvider(basePrice: 50000));
      expect(totalPrice, 40000.0);
    });
  });
}
