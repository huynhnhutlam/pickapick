import '../entities/booked_court.dart';
import '../entities/court.dart';
import '../entities/equipment.dart';
import '../entities/sub_court.dart';

abstract class CourtRepository {
  Future<List<Court>> getCourts();
  Future<List<Equipment>> getRentalServices();
  Future<Court> getCourtDetails(String id);
  Future<List<SubCourt>> getSubCourts(String facilityId);
  Future<void> cancelBooking(String bookingId);
  Future<void> syncBookingStatuses();
  Future<List<BookedCourt>> getBookings(String userId);
  Future<void> addBooking({
    required String userId,
    required BookedCourt booking,
    required String facilityId,
    required String courtId,
    required List<Equipment> equipment,
    required String? voucherCode,
    required double discountAmount,
    required String paymentMethod,
  });
}
