import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_court.freezed.dart';

@freezed
class SubCourt with _$SubCourt {
  const factory SubCourt({
    required String id,
    required String facilityId,
    required String name,
    required int courtNumber,
    required String surfaceType,
    required double pricePerHour,
    required double peakPricePerHour,
    required List<String> images,
    required bool isActive,
    required int maxPlayers,
  }) = _SubCourt;
}
