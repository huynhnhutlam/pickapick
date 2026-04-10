import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/enum/enum.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/usecases/confirm_booking_use_case.dart';
import 'booking_providers.dart';
import 'court_providers.dart';

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

    final user = await ref.read(authNotifierProvider.future);
    if (user == null) {
      state = state.copyWith(isProcessing: false);
      throw Exception('Vui lòng đăng nhập để đặt sân');
    }

    final useCase = ref.read(confirmBookingUseCaseProvider);
    final equipments = await ref.read(equipmentSelectionProvider.future);

    // Tính toán giá trực tiếp để tránh CircularDependencyError
    // do totalBookingPriceProvider đang watch bookingSummaryProvider
    final equipmentPrice = ref.read(equipmentTotalPriceProvider);
    final finalPrice = (basePrice + equipmentPrice - state.discountAmount)
        .clamp(0.0, double.infinity);

    final params = ConfirmBookingParams(
      userId: user.id,
      facilityId: facilityId,
      courtId: courtId,
      courtName: courtName,
      courtAddress: courtAddress,
      courtImage: courtImage,
      selectedDate: selectedDate,
      selectedSlot: selectedSlot,
      totalPrice: finalPrice,
      equipment: equipments,
      voucherCode: state.isVoucherApplied ? state.voucherCode : null,
      discountAmount: state.discountAmount,
      paymentMethod: state.selectedPaymentMethod.name,
    );

    final result = await useCase.execute(params);

    state = state.copyWith(isProcessing: false);

    result.fold(
      (failure) => throw failure,
      (_) {
        // Invalidate existing bookings to refresh lists
        ref.invalidate(bookingProvider);

        // Normalize date to ensure we invalidate the correct provider key
        final normalizedDate =
            DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

        ref.invalidate(
          bookedSlotsProvider(
            courtId: courtId,
            date: normalizedDate,
          ),
        );
      },
    );
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
