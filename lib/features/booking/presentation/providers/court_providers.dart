import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/court_repository_impl.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/sub_court.dart';

part 'court_providers.g.dart';

@riverpod
SupabaseCourtRepository courtRepository(Ref ref) {
  return SupabaseCourtRepository(Supabase.instance.client);
}

@riverpod
Future<List<Court>> featuredCourts(Ref ref) {
  return ref.watch(courtRepositoryProvider).getFeaturedCourts();
}

@riverpod
Future<List<Court>> allCourts(Ref ref) {
  return ref.watch(courtRepositoryProvider).getCourts();
}

@riverpod
Future<List<String>> bookedSlots(
  Ref ref, {
  required String courtId,
  required DateTime date,
}) {
  return ref.watch(courtRepositoryProvider).getBookedSlots(courtId, date);
}

@riverpod
Future<Court> courtDetails(Ref ref, String id) {
  return ref.watch(courtRepositoryProvider).getCourtDetails(id);
}

@riverpod
Future<List<SubCourt>> subCourts(Ref ref, String id) {
  return ref.watch(courtRepositoryProvider).getSubCourts(id);
}

@riverpod
Future<List<Equipment>> rentalServices(Ref ref) {
  return ref.watch(courtRepositoryProvider).getRentalServices();
}
