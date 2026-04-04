// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_court.freezed.dart';
part 'sub_court.g.dart';

@freezed
class SubCourt with _$SubCourt {
  const factory SubCourt({
    required String id,
    @JsonKey(name: 'facility_id') required String facilityId,
    required String name,
    @JsonKey(name: 'court_number') required int courtNumber,
    @JsonKey(name: 'surface_type') required String surfaceType,
    @JsonKey(name: 'price_per_hour') required double pricePerHour,
    @JsonKey(name: 'peak_price_per_hour') required double peakPricePerHour,
    required List<String> images,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'max_players') required int maxPlayers,
  }) = _SubCourt;

  factory SubCourt.fromJson(Map<String, dynamic> json) =>
      _$SubCourtFromJson(json);
}
