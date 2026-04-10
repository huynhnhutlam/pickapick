import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/court.dart';
import '../../domain/repositories/court_repository.dart';

class GetCourtDetailsUseCase {
  final CourtRepository _repository;

  GetCourtDetailsUseCase(this._repository);

  Future<Either<Failure, Court>> execute(String id) async {
    return _repository.getCourtDetails(id);
  }
}
