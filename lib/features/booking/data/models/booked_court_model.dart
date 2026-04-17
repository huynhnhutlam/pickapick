import '../../../../core/enum/enum.dart';
import '../../domain/entities/booked_court.dart';

class BookedCourtModel {
  static BookedCourt fromSupabase(Map<String, dynamic> json) {
    // Logic for mapping from deep Supabase JSON (moved from Entity)
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

    final createdAtRaw = json['created_at'] as String?;

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
      createdAt: createdAtRaw != null ? DateTime.parse(createdAtRaw) : null,
    );
  }

  static Map<String, dynamic> toJson(
    BookedCourt entity, {
    required String userId,
    required String facilityId,
    required String courtId,
    required List<Map<String, dynamic>> equipmentDetails,
    required String? voucherCode,
    required double discountAmount,
    required String paymentMethod,
  }) {
    final parts = entity.slot.split(' - ');
    final startTime = '${parts[0]}:00';
    final endTime = '${parts[1]}:00';

    final startH = int.parse(parts[0].substring(0, 2));
    final endH = int.parse(parts[1].substring(0, 2));
    final duration = endH - startH;

    return {
      'user_id': userId,
      'facility_id': facilityId,
      'court_id': courtId,
      'booking_date': entity.date.toIso8601String().split('T').first,
      'start_time': startTime,
      'end_time': endTime,
      'duration_hours': duration,
      'total_price': entity.price,
      'status': 'confirmed',
      'payment_status': 'paid',
      'equipment_details': equipmentDetails,
      'voucher_code': voucherCode,
      'discount_amount': discountAmount,
      'payment_method': paymentMethod,
    };
  }
}
