import 'package:freezed_annotation/freezed_annotation.dart';

part 'court.freezed.dart';
part 'court.g.dart';

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

  factory Court.fromJson(Map<String, dynamic> json) => _$CourtFromJson(json);
}

@freezed
class CourtSlot with _$CourtSlot {
  const factory CourtSlot({
    required DateTime startTime,
    required DateTime endTime,
    required bool isAvailable,
    double? priceOverride,
  }) = _CourtSlot;

  factory CourtSlot.fromJson(Map<String, dynamic> json) =>
      _$CourtSlotFromJson(json);
}
