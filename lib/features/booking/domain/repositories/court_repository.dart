import '../entities/court.dart';
import '../entities/sub_court.dart';

abstract class CourtRepository {
  Future<List<Court>> getCourts();
  Future<Court> getCourtDetails(String id);
  Future<List<SubCourt>> getSubCourts(String facilityId);
  Future<void> cancelBooking(String bookingId);
  Future<void> syncBookingStatuses();
}
