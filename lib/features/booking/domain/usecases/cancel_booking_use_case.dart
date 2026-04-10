import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/court_repository.dart';

class CancelBookingUseCase {
  final CourtRepository _repository;

  CancelBookingUseCase(this._repository);

  Future<Either<Failure, void>> execute(String bookingId) async {
    return _repository.cancelBooking(bookingId);
  }
}
