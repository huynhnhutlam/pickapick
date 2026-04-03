import '../entities/court.dart';

abstract class CourtRepository {
  Future<List<Court>> getCourts();
  Future<Court> getCourtDetails(String id);
  Future<void> cancelBooking(String bookingId);
  Future<void> syncBookingStatuses();
}
