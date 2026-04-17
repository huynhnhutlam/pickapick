import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../repositories/court_repository.dart';

class GetAvailableSlotsUseCase {
  final CourtRepository _repository;

  GetAvailableSlotsUseCase(this._repository);

  Future<Either<Failure, List<String>>> execute(
    String courtId,
    DateTime date,
  ) {
    return _repository.getAvailableSlots(courtId, date);
  }
}
