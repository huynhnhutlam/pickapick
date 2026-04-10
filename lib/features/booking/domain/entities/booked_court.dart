import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enum/enum.dart';

part 'booked_court.freezed.dart';
part 'booked_court.g.dart';

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
  }) = _BookedCourt;

  factory BookedCourt.fromJson(Map<String, dynamic> json) =>
      _$BookedCourtFromJson(json);

  factory BookedCourt.fromSupabase(Map<String, dynamic> json) {
    // Logic for domain-mapping from deep Supabase JSON
    final f = json['facilities'] as Map<String, dynamic>?;
    final c = json['courts'] as Map<String, dynamic>?;
    final images = (f?['images'] as List?)?.cast<String>() ?? [];
    final startTime = (json['start_time'] as String).substring(0, 5);
    final duration = (json['duration_hours'] as num?)?.toInt() ?? 1;

    final startH = int.parse(startTime.substring(0, 2));
    final endH = startH + duration;
    final endTime = '${endH.toString().padLeft(2, '0')}:00';

    final facilityName = f?['name'] as String? ?? 'Sân Pickleball';
    final courtName = c?['name'] as String?;
    final fullName =
        courtName != null ? '$facilityName - $courtName' : facilityName;

    return BookedCourt(
      id: json['id'] as String,
      courtName: fullName,
      courtAddress: f?['address'] as String? ?? '',
      courtImage: images.isNotEmpty
          ? images.first
          : 'https://picsum.photos/seed/${json['id']}/400/300',
      date: DateTime.parse(json['booking_date'] as String),
      slot: '$startTime - $endTime',
      price: (json['total_price'] as num).toDouble(),
      status: BookingStatus.fromDb(json['status'] as String?),
    );
  }
}
