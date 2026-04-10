import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/booked_court.dart';
import '../../domain/entities/equipment.dart';
import 'court_providers.dart';

part 'booking_providers.g.dart';

@riverpod
class Booking extends _$Booking {
  RealtimeChannel? _channel;

  @override
  FutureOr<List<BookedCourt>> build() async {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    if (user == null) return [];

    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    _setupRealtime(user);
    return _fetchBookings(user);
  }

  void _setupRealtime(User user) {
    final client = Supabase.instance.client;
    _channel = client
        .channel('public:bookings')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) => ref.invalidateSelf(),
        )
        .subscribe();
  }

  Future<List<BookedCourt>> _fetchBookings(User user) async {
    final repository = ref.read(courtRepositoryProvider);
    try {
      return await repository.getBookings(user.id);
    } catch (e, s) {
      developer.log('Fetch bookings failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> addBooking({
    required BookedCourt newBooking,
    required String facilityId,
    required String courtId,
    required List<Equipment> equipment,
    required String? voucherCode,
    required double discountAmount,
    required String paymentMethod,
  }) async {
    final userFuture = ref.read(authNotifierProvider.future);
    final repository = ref.read(courtRepositoryProvider);
    try {
      final user = await userFuture;

      if (user == null) {
        throw Exception('Vui lòng đăng nhập để đặt sân');
      }
      await repository.addBooking(
        userId: user.id,
        booking: newBooking,
        facilityId: facilityId,
        courtId: courtId,
        equipment: equipment,
        voucherCode: voucherCode,
        discountAmount: discountAmount,
        paymentMethod: paymentMethod,
      );

      ref.invalidateSelf();
    } catch (e, s) {
      developer.log('Add booking failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final repository = ref.read(courtRepositoryProvider);
    try {
      await repository.cancelBooking(bookingId);
      ref.invalidateSelf();
    } catch (e, s) {
      developer.log('Cancel booking failed', error: e, stackTrace: s);
      rethrow;
    }
  }
}

@riverpod
class EquipmentSelection extends _$EquipmentSelection {
  @override
  FutureOr<List<Equipment>> build() async {
    final data = await ref.watch(rentalServicesProvider.future);

    return data
        .map(
          (e) => e.copyWith(quantity: 0),
        )
        .toList();
  }

  void increment(String id) {
    state.whenData((list) {
      state = AsyncData([
        for (final item in list)
          if (item.id == id)
            item.copyWith(quantity: item.quantity + 1)
          else
            item,
      ]);
    });
  }

  void decrement(String id) {
    state.whenData((list) {
      state = AsyncData([
        for (final item in list)
          if (item.id == id && item.quantity > 0)
            item.copyWith(quantity: item.quantity - 1)
          else
            item,
      ]);
    });
  }

  List<Equipment> get selectedEquipments =>
      state.valueOrNull?.where((e) => e.quantity > 0).toList() ?? [];

  double get totalPrice =>
      state.valueOrNull?.fold(
        0.0,
        (sum, item) => sum! + (item.pricePerUnit * item.quantity),
      ) ??
      0.0;
}
