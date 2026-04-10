// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/sub_court.dart';

part 'sub_court_model.freezed.dart';
part 'sub_court_model.g.dart';

@freezed
class SubCourtModel with _$SubCourtModel {
  const factory SubCourtModel({
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
  }) = _SubCourtModel;

  factory SubCourtModel.fromJson(Map<String, dynamic> json) =>
      _$SubCourtModelFromJson(json);

  const SubCourtModel._();

  SubCourt toEntity() => SubCourt(
        id: id,
        facilityId: facilityId,
        name: name,
        courtNumber: courtNumber,
        surfaceType: surfaceType,
        pricePerHour: pricePerHour,
        peakPricePerHour: peakPricePerHour,
        images: images,
        isActive: isActive,
        maxPlayers: maxPlayers,
      );
}
