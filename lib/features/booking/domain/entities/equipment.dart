// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment.freezed.dart';
part 'equipment.g.dart';

@freezed
class Equipment with _$Equipment {
  const factory Equipment({
    required String id,
    required String name,
    @JsonKey(name: 'price_per_unit') required double pricePerUnit,
    @Default(0) int quantity,
  }) = _Equipment;

  factory Equipment.fromJson(Map<String, dynamic> json) =>
      _$EquipmentFromJson(json);

  const Equipment._(); // Constructor private để thêm method tùy chỉnh nếu cần
  double get totalPrice => pricePerUnit * quantity;
}
