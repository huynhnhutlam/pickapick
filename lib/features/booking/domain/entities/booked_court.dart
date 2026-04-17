import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enum/enum.dart';

part 'booked_court.freezed.dart';

@freezed
class BookedCourt with _$BookedCourt {
  const factory BookedCourt({
    required String id,
    required String courtName,
    required String courtAddress,
    required String courtImage,
    required DateTime date,
    required String slot,
    required double price,
    @Default(BookingStatus.upcoming) BookingStatus status,
    DateTime? createdAt,
  }) = _BookedCourt;
}
