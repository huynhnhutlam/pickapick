import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String userId,
    required String courtId,
    required String courtName,
    required DateTime bookingDate,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
    required BookingStatus status,
    required DateTime createdAt,
    String? note,
    String? voucherCode,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) =>
      _$BookingFromJson(json);
}
