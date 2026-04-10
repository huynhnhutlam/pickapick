import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/booked_court.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/sub_court.dart';
import '../../domain/repositories/court_repository.dart';

/// Supabase-backed implementation of [CourtRepository].
class SupabaseCourtRepository implements CourtRepository {
  SupabaseCourtRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Court>> getCourts() =>
      _fetchFacilities(order: 'rating', ascending: false);

  @override
  Future<Court> getCourtDetails(String id) async {
    try {
      final json =
          await _client.from('facilities').select().eq('id', id).single();
      return _toCourt(json);
    } catch (e, s) {
      developer.log(
        'Failed to fetch court details for $id',
        name: 'CourtRepository',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<List<SubCourt>> getSubCourts(String facilityId) async {
    try {
      final response = await _client
          .from('courts')
          .select()
          .eq('facility_id', facilityId)
          .eq('is_active', true)
          .order('court_number');
      return (response as List)
          .map((json) => SubCourt.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, s) {
      developer.log(
        'Failed to fetch sub-courts for facility $facilityId',
        name: 'CourtRepository',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  Future<List<Court>> getFeaturedCourts() =>
      _fetchFacilities(minRating: 4.5, limit: 6);

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _client
        .from('bookings')
        .update({'status': 'cancelled'}).eq('id', bookingId);
  }

  @override
  Future<void> syncBookingStatuses() async {
    try {
      await _client.rpc('update_booking_statuses');
    } catch (e, s) {
      developer.log(
        'Failed to sync booking statuses',
        name: 'CourtRepository',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> addBooking({
    required String userId,
    required BookedCourt booking,
    required String facilityId,
    required String courtId,
    required List<Equipment> equipment,
    required String? voucherCode,
    required double discountAmount,
    required String paymentMethod,
  }) async {
    try {
      final parts = booking.slot.split(' - ');
      final startTime = '${parts[0]}:00';
      final endTime = '${parts[1]}:00';

      final startH = int.parse(parts[0].substring(0, 2));
      final endH = int.parse(parts[1].substring(0, 2));
      final duration = endH - startH;

      final equipmentDetails = equipment
          .map(
            (e) => {
              'id': e.id,
              'name': e.name,
              'price_per_unit': e.pricePerUnit,
              'quantity': e.quantity,
            },
          )
          .toList();

      await _client.from('bookings').insert({
        'user_id': userId,
        'facility_id': facilityId,
        'court_id': courtId,
        'booking_date': booking.date.toIso8601String().split('T').first,
        'start_time': startTime,
        'end_time': endTime,
        'duration_hours': duration,
        'total_price': booking.price,
        'status': 'confirmed',
        'payment_status': 'paid',
        'equipment_details': equipmentDetails,
        'voucher_code': voucherCode,
        'discount_amount': discountAmount,
        'payment_method': paymentMethod,
      });
    } catch (e, s) {
      developer.log(
        'Failed to add booking',
        name: 'CourtRepository',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<List<BookedCourt>> getBookings(String userId) async {
    try {
      await syncBookingStatuses();

      final response = await _client
          .from('bookings')
          .select('*, facilities:facility_id(*), courts:court_id(*)')
          .eq('user_id', userId)
          .order('booking_date', ascending: false);

      return (response as List)
          .map((json) => BookedCourt.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e, s) {
      developer.log(
        'Failed to fetch bookings',
        name: 'CourtRepository',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  @override
  Future<List<Equipment>> getRentalServices() async {
    try {
      final response = await _client
          .from('rental_services')
          .select()
          .eq('is_active', true)
          .order('name');
      return (response as List)
          .map((json) => Equipment.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, s) {
      developer.log(
        'Failed to fetch rental services',
        name: 'CourtRepository',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  Future<List<Court>> _fetchFacilities({
    String order = 'rating',
    bool ascending = false,
    double? minRating,
    int? limit,
  }) async {
    try {
      var query = _client.from('facilities').select().eq('is_active', true);
      if (minRating != null) {
        query = query.gte('rating', minRating);
      }
      final response =
          await query.order(order, ascending: ascending).limit(limit ?? 100);
      return (response as List)
          .map((json) => _toCourt(json as Map<String, dynamic>))
          .toList();
    } catch (e, s) {
      developer.log(
        'Failed to fetch facilities',
        name: 'CourtRepository',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<List<String>> getBookedSlots(String courtId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      final response = await _client.rpc(
        'get_booked_slots',
        params: {
          'p_court_id': courtId,
          'p_date': dateStr,
        },
      );
      final List<String> allBookedSlots = [];
      for (final row in (response as List)) {
        final startTimeStr = row['start_time'] as String;
        final duration = (row['duration_hours'] as num?)?.toInt() ?? 1;
        final startHour = int.parse(startTimeStr.substring(0, 2));

        for (int i = 0; i < duration; i++) {
          allBookedSlots
              .add('${(startHour + i).toString().padLeft(2, '0')}:00');
        }
      }
      return allBookedSlots;
    } catch (e, s) {
      developer.log(
        'Failed to fetch booked slots',
        name: 'CourtRepository',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  static Court _toCourt(Map<String, dynamic> json) {
    final images = (json['images'] as List?)?.cast<String>() ?? [];
    final amenities = (json['amenities'] as List?)?.cast<String>() ?? [];
    final address = [
      json['address'],
      if (json['district'] != null && (json['district'] as String).isNotEmpty)
        json['district'],
      json['city'],
    ].join(', ');
    return Court(
      id: json['id'] as String,
      name: json['name'] as String,
      address: address,
      images: images.isNotEmpty
          ? images
          : ['https://picsum.photos/seed/${json['id']}/800/600'],
      pricePerHour: (json['price_per_session'] as num?)?.toDouble() ?? 150000.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['total_reviews'] as int?) ?? 0,
      description: json['description'] as String? ?? '',
      amenities: amenities,
      rules: const ['Giày thể thao bắt buộc', 'Không hút thuốc'],
      openingHours:
          '${json['open_time'] ?? '06:00'} - ${json['close_time'] ?? '22:00'}',
    );
  }
}
