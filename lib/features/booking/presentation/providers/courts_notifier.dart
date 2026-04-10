import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/court.dart';
import 'court_providers.dart';

final courtsProvider = FutureProvider<List<Court>>((ref) async {
  final result = await ref.watch(getCourtsUseCaseProvider).execute();
  return result.fold(
    (failure) => throw failure,
    (courts) => courts,
  );
});
