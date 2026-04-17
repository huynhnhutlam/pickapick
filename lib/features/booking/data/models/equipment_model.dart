// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/equipment.dart';

part 'equipment_model.freezed.dart';
part 'equipment_model.g.dart';

@freezed
class EquipmentModel with _$EquipmentModel {
  const factory EquipmentModel({
    required String id,
    required String name,
    @JsonKey(name: 'price_per_unit') required double pricePerUnit,
    @Default(0) int quantity,
  }) = _EquipmentModel;

  factory EquipmentModel.fromJson(Map<String, dynamic> json) =>
      _$EquipmentModelFromJson(json);

  const EquipmentModel._();

  Equipment toEntity() => Equipment(
        id: id,
        name: name,
        pricePerUnit: pricePerUnit,
        quantity: quantity,
      );

  static EquipmentModel fromEntity(Equipment entity) => EquipmentModel(
        id: entity.id,
        name: entity.name,
        pricePerUnit: entity.pricePerUnit,
        quantity: entity.quantity,
      );
}
