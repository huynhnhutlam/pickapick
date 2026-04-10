import 'package:pickle_pick/features/booking/domain/entities/booked_court.dart';
import 'package:pickle_pick/features/booking/domain/entities/equipment.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_providers.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/enum/enum.dart';

part 'booking_summary_riverpod.g.dart';

class BookingSummaryState {
  final String voucherCode;
  final double discountAmount;
  final bool isVoucherApplied;
  final PaymentMethod selectedPaymentMethod;
  final bool isProcessing;

  const BookingSummaryState({
    this.voucherCode = '',
    this.discountAmount = 0,
    this.isVoucherApplied = false,
    this.selectedPaymentMethod = PaymentMethod.picklePay,
    this.isProcessing = false,
  });

  BookingSummaryState copyWith({
    String? voucherCode,
    double? discountAmount,
    bool? isVoucherApplied,
    PaymentMethod? selectedPaymentMethod,
    bool? isProcessing,
  }) {
    return BookingSummaryState(
      voucherCode: voucherCode ?? this.voucherCode,
      discountAmount: discountAmount ?? this.discountAmount,
      isVoucherApplied: isVoucherApplied ?? this.isVoucherApplied,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

@riverpod
class BookingSummary extends _$BookingSummary {
  @override
  BookingSummaryState build() {
    return const BookingSummaryState();
  }

  bool applyVoucher(String code) {
    final voucher = code.trim();

    final isValid = voucher.isNotEmpty; // thay bằng rule thật của bạn
    final discount = isValid ? 10000.0 : 0.0;

    state = state.copyWith(
      voucherCode: voucher,
      isVoucherApplied: isValid,
      discountAmount: discount,
    );

    return isValid;
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  Future<void> confirmBooking({
    required String facilityId,
    required String courtId,
    required String courtName,
    required String courtAddress,
    required String courtImage,
    required DateTime selectedDate,
    required String selectedSlot,
    required double basePrice,
  }) async {
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true);

    try {
      final selectedEquipmentsAsync = ref.read(equipmentSelectionProvider);
      final bookingNotifier = ref.read(bookingProvider.notifier);

      final equipments = selectedEquipmentsAsync.valueOrNull ?? <Equipment>[];
      final finalPrice =
          ref.read(totalBookingPriceProvider(basePrice: basePrice));

      final booking = BookedCourt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        courtName: courtName,
        courtAddress: courtAddress,
        courtImage: courtImage,
        date: selectedDate,
        slot: selectedSlot,
        price: finalPrice,
      );

      await bookingNotifier.addBooking(
        newBooking: booking,
        facilityId: facilityId,
        courtId: courtId,
        equipment: equipments,
        voucherCode: state.isVoucherApplied ? state.voucherCode : null,
        discountAmount: state.discountAmount,
        paymentMethod: state.selectedPaymentMethod.name,
      );

      ref.invalidate(
        bookedSlotsProvider(
          courtId: courtId,
          date: selectedDate,
        ),
      );
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}

@riverpod
double equipmentTotalPrice(EquipmentTotalPriceRef ref) {
  return ref.watch(
    equipmentSelectionProvider.select(
      (s) =>
          s.valueOrNull?.fold<double>(
            0,
            (sum, e) => sum + (e.pricePerUnit * e.quantity),
          ) ??
          0.0,
    ),
  );
}

@riverpod
double totalBookingPrice(
  TotalBookingPriceRef ref, {
  required double basePrice,
}) {
  final equipmentPrice = ref.watch(equipmentTotalPriceProvider);
  final discountAmount =
      ref.watch(bookingSummaryProvider.select((s) => s.discountAmount));

  return (basePrice + equipmentPrice - discountAmount)
      .clamp(0.0, double.infinity);
}
