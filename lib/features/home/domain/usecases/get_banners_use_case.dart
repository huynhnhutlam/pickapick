import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_banner.dart';
import '../repositories/home_repository.dart';

class GetBannersUseCase {
  final HomeRepository _repository;

  GetBannersUseCase(this._repository);

  Future<Either<Failure, List<AppBanner>>> execute() async {
    return await _repository.getBanners();
  }
}
