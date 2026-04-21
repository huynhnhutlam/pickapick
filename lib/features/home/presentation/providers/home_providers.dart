import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/home_repository_impl.dart';
import '../../domain/entities/app_banner.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_banners_use_case.dart';

part 'home_providers.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepositoryImpl(Supabase.instance.client);
}

@riverpod
GetBannersUseCase getBannersUseCase(GetBannersUseCaseRef ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return GetBannersUseCase(repository);
}

@riverpod
Future<List<AppBanner>> homeBanners(HomeBannersRef ref) async {
  final useCase = ref.watch(getBannersUseCaseProvider);
  final result = await useCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (banners) => banners,
  );
}
