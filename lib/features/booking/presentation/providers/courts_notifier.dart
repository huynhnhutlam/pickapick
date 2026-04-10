import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/court.dart';
import 'court_providers.dart';

final courtsProvider = FutureProvider<List<Court>>((ref) async {
  final repository = ref.watch(courtRepositoryProvider);
  return repository.getCourts();
});
