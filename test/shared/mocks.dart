import 'package:auto_route/auto_route.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pickle_pick/features/booking/domain/repositories/court_repository.dart';
import 'package:pickle_pick/features/home/domain/repositories/home_repository.dart';
import 'package:pickle_pick/features/home/domain/usecases/get_banners_use_case.dart';
import 'package:pickle_pick/features/shop/data/repositories/shop_repository_impl.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

class MockGetBannersUseCase extends Mock implements GetBannersUseCase {}

class MockCourtRepository extends Mock implements CourtRepository {}

class MockShopRepository extends Mock implements SupabaseShopRepository {}

class MockStackRouter extends Mock implements StackRouter {}
