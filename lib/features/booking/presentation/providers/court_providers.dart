import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/court_repository_impl.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/sub_court.dart';
import '../../domain/repositories/court_repository.dart';
import '../../domain/usecases/get_available_slots_use_case.dart';
import '../../domain/usecases/get_booked_slots_use_case.dart';
import '../../domain/usecases/get_court_details_use_case.dart';
import '../../domain/usecases/get_courts_use_case.dart';
import '../../domain/usecases/get_rental_services_use_case.dart';
import '../../domain/usecases/get_sub_courts_use_case.dart';

part 'court_providers.g.dart';

@riverpod
CourtRepository courtRepository(Ref ref) {
  return SupabaseCourtRepository(Supabase.instance.client);
}

@riverpod
GetCourtsUseCase getCourtsUseCase(Ref ref) {
  return GetCourtsUseCase(ref.watch(courtRepositoryProvider));
}

@riverpod
GetCourtDetailsUseCase getCourtDetailsUseCase(Ref ref) {
  return GetCourtDetailsUseCase(ref.watch(courtRepositoryProvider));
}

@riverpod
GetSubCourtsUseCase getSubCourtsUseCase(Ref ref) {
  return GetSubCourtsUseCase(ref.watch(courtRepositoryProvider));
}

@riverpod
GetRentalServicesUseCase getRentalServicesUseCase(Ref ref) {
  return GetRentalServicesUseCase(ref.watch(courtRepositoryProvider));
}

@riverpod
GetBookedSlotsUseCase getBookedSlotsUseCase(Ref ref) {
  return GetBookedSlotsUseCase(ref.watch(courtRepositoryProvider));
}

@riverpod
GetAvailableSlotsUseCase getAvailableSlotsUseCase(Ref ref) {
  return GetAvailableSlotsUseCase(ref.watch(courtRepositoryProvider));
}

@riverpod
Future<List<Court>> allCourts(Ref ref) async {
  final result = await ref.watch(getCourtsUseCaseProvider).execute();
  return result.fold(
    (failure) => throw failure,
    (courts) => courts,
  );
}

@riverpod
Future<List<Court>> featuredCourts(Ref ref) async {
  final courts = await ref.watch(allCourtsProvider.future);
  return courts.take(5).toList();
}

@riverpod
Future<Court> courtDetails(Ref ref, String id) async {
  final result = await ref.watch(getCourtDetailsUseCaseProvider).execute(id);
  return result.fold(
    (failure) => throw failure,
    (court) => court,
  );
}

@riverpod
Future<List<SubCourt>> subCourts(Ref ref, String id) async {
  final result = await ref.watch(getSubCourtsUseCaseProvider).execute(id);
  return result.fold(
    (failure) => throw failure,
    (subCourts) => subCourts,
  );
}

@riverpod
Future<List<Equipment>> rentalServices(Ref ref) async {
  final result = await ref.watch(getRentalServicesUseCaseProvider).execute();
  return result.fold(
    (failure) => throw failure,
    (services) => services,
  );
}

@riverpod
Future<List<String>> bookedSlots(
  Ref ref, {
  required String courtId,
  required DateTime date,
}) async {
  final result =
      await ref.watch(getBookedSlotsUseCaseProvider).execute(courtId, date);
  return result.fold(
    (failure) => throw failure,
    (slots) => slots,
  );
}

@riverpod
Future<List<String>> availableSlots(
  Ref ref, {
  required String courtId,
  required DateTime date,
}) async {
  final result =
      await ref.watch(getAvailableSlotsUseCaseProvider).execute(courtId, date);
  return result.fold(
    (failure) => throw failure,
    (slots) => slots,
  );
}
