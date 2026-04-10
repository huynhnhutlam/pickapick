import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/court.dart';
import '../../domain/repositories/court_repository.dart';

class GetCourtsUseCase {
  final CourtRepository _repository;

  GetCourtsUseCase(this._repository);

  Future<Either<Failure, List<Court>>> execute() async {
    return _repository.getCourts();
  }
}
