import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/repositories/court_repository.dart';

class GetRentalServicesUseCase {
  final CourtRepository _repository;

  GetRentalServicesUseCase(this._repository);

  Future<Either<Failure, List<Equipment>>> execute() async {
    return _repository.getRentalServices();
  }
}
