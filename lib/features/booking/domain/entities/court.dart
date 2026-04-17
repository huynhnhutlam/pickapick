import 'package:freezed_annotation/freezed_annotation.dart';

part 'court.freezed.dart';

@freezed
class Court with _$Court {
  const factory Court({
    required String id,
    required String name,
    required String address,
    required List<String> images,
    required double pricePerHour,
    required double rating,
    required int reviewCount,
    required String description,
    required List<String> amenities,
    required List<String> rules,
    required String openingHours,
  }) = _Court;
}

@freezed
class CourtSlot with _$CourtSlot {
  const factory CourtSlot({
    required DateTime startTime,
    required DateTime endTime,
    required bool isAvailable,
    double? priceOverride,
  }) = _CourtSlot;
}
