import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/booked_court.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/usecases/cancel_booking_use_case.dart';
import '../../domain/usecases/confirm_booking_use_case.dart';
import '../../domain/usecases/get_bookings_use_case.dart';
import '../../domain/usecases/watch_bookings_use_case.dart';
import 'court_providers.dart';

part 'booking_providers.g.dart';

@riverpod
ConfirmBookingUseCase confirmBookingUseCase(ConfirmBookingUseCaseRef ref) {
  return ConfirmBookingUseCase(ref.watch(courtRepositoryProvider));
}

@riverpod
CancelBookingUseCase cancelBookingUseCase(CancelBookingUseCaseRef ref) {
  return CancelBookingUseCase(ref.watch(courtRepositoryProvider));
}

@riverpod
GetBookingsUseCase getBookingsUseCase(GetBookingsUseCaseRef ref) {
  return GetBookingsUseCase(ref.watch(courtRepositoryProvider));
}

@riverpod
WatchBookingsUseCase watchBookingsUseCase(WatchBookingsUseCaseRef ref) {
  return WatchBookingsUseCase(ref.watch(courtRepositoryProvider));
}

@riverpod
class Booking extends _$Booking {
  StreamSubscription? _subscription;

  @override
  FutureOr<List<BookedCourt>> build() async {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    if (user == null) return [];

    ref.onDispose(() {
      _subscription?.cancel();
    });

    _setupRealtime(user.id);

    final result = await ref.watch(getBookingsUseCaseProvider).execute(user.id);
    return result.fold(
      (failure) => throw failure,
      (bookings) => bookings,
    );
  }

  void _setupRealtime(String userId) {
    _subscription = ref
        .read(watchBookingsUseCaseProvider)
        .execute(userId)
        .listen((_) => ref.invalidateSelf());
  }

  Future<void> cancelBooking(String bookingId) async {
    final result =
        await ref.read(cancelBookingUseCaseProvider).execute(bookingId);
    result.fold(
      (failure) => throw failure,
      (_) => ref.invalidateSelf(),
    );
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
