import '../repositories/court_repository.dart';

class WatchBookingsUseCase {
  final CourtRepository _repository;

  WatchBookingsUseCase(this._repository);

  Stream<void> execute(String userId) {
    return _repository.watchBookings(userId);
  }
}
