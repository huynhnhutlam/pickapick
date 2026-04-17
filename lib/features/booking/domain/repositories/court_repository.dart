import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/booked_court.dart';
import '../entities/court.dart';
import '../entities/equipment.dart';
import '../entities/sub_court.dart';

abstract class CourtRepository {
  Future<Either<Failure, List<Court>>> getCourts();
  Future<Either<Failure, List<Equipment>>> getRentalServices();
  Future<Either<Failure, Court>> getCourtDetails(String id);
  Future<Either<Failure, List<SubCourt>>> getSubCourts(String facilityId);
  Future<Either<Failure, void>> cancelBooking(String bookingId);
  Future<Either<Failure, void>> syncBookingStatuses();
  Future<Either<Failure, List<BookedCourt>>> getBookings(String userId);
  Future<Either<Failure, void>> addBooking({
    required String userId,
    required BookedCourt booking,
    required String facilityId,
    required String courtId,
    required List<Equipment> equipment,
    required String? voucherCode,
    required double discountAmount,
    required String paymentMethod,
  });
  Future<Either<Failure, List<String>>> getBookedSlots(
    String courtId,
    DateTime date,
  );
  Future<Either<Failure, List<String>>> getAvailableSlots(
    String courtId,
    DateTime date,
  );
  Stream<void> watchBookings(String userId);
}
