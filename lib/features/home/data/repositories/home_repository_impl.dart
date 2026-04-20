import 'dart:developer' as developer;

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/app_banner.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Either<Failure, List<AppBanner>>> getBanners() async {
    try {
      final response = await _client
          .from('banners')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final banners = (response as List)
          .map((json) => AppBanner.fromJson(json as Map<String, dynamic>))
          .toList();

      return right(banners);
    } catch (e, s) {
      developer.log(
        'Failed to fetch banners',
        name: 'HomeRepositoryImpl',
        error: e,
        stackTrace: s,
      );
      return left(ServerFailure(e.toString()));
    }
  }
}
