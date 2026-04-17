// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/court.dart';

part 'court_model.freezed.dart';
part 'court_model.g.dart';

@freezed
class CourtModel with _$CourtModel {
  const factory CourtModel({
    required String id,
    required String name,
    required String address,
    @Default([]) List<String> images,
    @JsonKey(name: 'price_per_session', fromJson: _toDouble)
    @Default(0.0)
    double pricePerHour,
    @JsonKey(fromJson: _toDouble) @Default(0.0) double rating,
    @JsonKey(name: 'total_reviews') @Default(0) int reviewCount,
    @Default('') String description,
    @Default([]) List<String> amenities,
    @Default([]) List<String> rules,
    @JsonKey(name: 'open_time') String? openTime,
    @JsonKey(name: 'close_time') String? closeTime,
  }) = _CourtModel;

  factory CourtModel.fromJson(Map<String, dynamic> json) =>
      _$CourtModelFromJson(json);

  const CourtModel._();

  Court toEntity() => Court(
        id: id,
        name: name,
        address: address,
        images: images,
        pricePerHour: pricePerHour,
        rating: rating,
        reviewCount: reviewCount,
        description: description,
        amenities: amenities,
        rules: rules,
        openingHours: (openTime != null && closeTime != null)
            ? '$openTime - $closeTime'
            : '06:00 - 22:00',
      );
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

@freezed
class CourtSlotModel with _$CourtSlotModel {
  const factory CourtSlotModel({
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    @JsonKey(name: 'is_available') required bool isAvailable,
    @JsonKey(name: 'price_override') double? priceOverride,
  }) = _CourtSlotModel;

  factory CourtSlotModel.fromJson(Map<String, dynamic> json) =>
      _$CourtSlotModelFromJson(json);

  const CourtSlotModel._();

  CourtSlot toEntity() => CourtSlot(
        startTime: startTime,
        endTime: endTime,
        isAvailable: isAvailable,
        priceOverride: priceOverride,
      );
}
