import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booked_court.dart';
import '../../domain/repositories/court_repository.dart';

class GetBookingsUseCase {
  final CourtRepository _repository;

  GetBookingsUseCase(this._repository);

  Future<Either<Failure, List<BookedCourt>>> execute(String userId) async {
    return _repository.getBookings(userId);
  }
}
