import 'package:fpdart/fpdart.dart';
import 'package:pickle_pick/core/extension/string_extension.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booked_court.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/repositories/court_repository.dart';

class ConfirmBookingParams {
  final String userId;
  final String facilityId;
  final String courtId;
  final String courtName;
  final String courtAddress;
  final String courtImage;
  final DateTime selectedDate;
  final String selectedSlot;
  final double totalPrice;
  final List<Equipment> equipment;
  final String? voucherCode;
  final double discountAmount;
  final String paymentMethod;

  ConfirmBookingParams({
    required this.userId,
    required this.facilityId,
    required this.courtId,
    required this.courtName,
    required this.courtAddress,
    required this.courtImage,
    required this.selectedDate,
    required this.selectedSlot,
    required this.totalPrice,
    required this.equipment,
    required this.paymentMethod,
    this.voucherCode,
    this.discountAmount = 0,
  });
}

class ConfirmBookingUseCase {
  final CourtRepository _repository;

  ConfirmBookingUseCase(this._repository);

  Future<Either<Failure, void>> execute(ConfirmBookingParams params) async {
    final booking = BookedCourt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courtName: params.courtName,
      courtAddress: params.courtAddress,
      courtImage: params.courtImage,
      date: params.selectedDate,
      slot: params.selectedSlot,
      price: params.totalPrice,
    );

    // Check if slot is already booked (Prevention of duplicate bookings)
    final bookedSlotsResult =
        await _repository.getBookedSlots(params.courtId, params.selectedDate);

    final isAlreadyBooked = bookedSlotsResult.fold(
      (failure) => false, // If check fails, DB trigger will still catch it
      (slots) => slots.any((existingRange) {
        try {
          // Parse "07:00 - 08:00" -> start: 07:00, end: 08:00
          final existingParts = existingRange.split(' - ');
          final selectedParts = params.selectedSlot.split(' - ');

          if (existingParts.length != 2 || selectedParts.length != 2) {
            return false;
          }

          final eStart = existingParts[0].toMinutes();
          final eEnd = existingParts[1].toMinutes();
          final sStart = selectedParts[0].toMinutes();
          final sEnd = selectedParts[1].toMinutes();

          // Standard overlap formula: (start1 < end2) && (start2 < end1)
          return (sStart < eEnd) && (eStart < sEnd);
        } catch (e) {
          return false;
        }
      }),
    );

    if (isAlreadyBooked) {
      return const Left(
        ServerFailure(
          'Sân đã được đặt trong khoảng thời gian này. Vui lòng chọn giờ chơi khác.',
        ),
      );
    }

    return _repository.addBooking(
      userId: params.userId,
      booking: booking,
      facilityId: params.facilityId,
      courtId: params.courtId,
      equipment: params.equipment,
      voucherCode: params.voucherCode,
      discountAmount: params.discountAmount,
      paymentMethod: params.paymentMethod,
    );
  }
}
