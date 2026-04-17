import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/sub_court.dart';
import '../../domain/repositories/court_repository.dart';

class GetSubCourtsUseCase {
  final CourtRepository _repository;

  GetSubCourtsUseCase(this._repository);

  Future<Either<Failure, List<SubCourt>>> execute(String facilityId) async {
    return _repository.getSubCourts(facilityId);
  }
}
