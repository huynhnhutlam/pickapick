import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_banner.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<AppBanner>>> getBanners();
}
