import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/court_repository.dart';

class GetBookedSlotsUseCase {
  final CourtRepository _repository;

  GetBookedSlotsUseCase(this._repository);

  Future<Either<Failure, List<String>>> execute(
    String courtId,
    DateTime date,
  ) async {
    return _repository.getBookedSlots(courtId, date);
  }
}
