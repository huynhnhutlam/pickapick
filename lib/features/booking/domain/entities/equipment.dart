import 'package:freezed_annotation/freezed_annotation.dart';

part 'equipment.freezed.dart';

@freezed
class Equipment with _$Equipment {
  const factory Equipment({
    required String id,
    required String name,
    required double pricePerUnit,
    @Default(0) int quantity,
  }) = _Equipment;

  const Equipment._();
  double get totalPrice => pricePerUnit * quantity;
}
