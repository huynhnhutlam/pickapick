import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/court.dart';
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

  Future<List<String>> getBookedSlots(String facilityId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      final response = await _client
          .from('bookings')
          .select('start_time, duration_hours')
          .eq('facility_id', facilityId)
          .eq('booking_date', dateStr)
          .neq('status', 'cancelled');

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

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final courtRepositoryProvider = Provider<SupabaseCourtRepository>(
  (ref) => SupabaseCourtRepository(Supabase.instance.client),
);

final featuredCourtsProvider = FutureProvider<List<Court>>(
  (ref) => ref.watch(courtRepositoryProvider).getFeaturedCourts(),
);

final allCourtsProvider = FutureProvider<List<Court>>(
  (ref) => ref.watch(courtRepositoryProvider).getCourts(),
);

final bookedSlotsProvider =
    FutureProvider.family<List<String>, ({String facilityId, DateTime date})>(
  (ref, args) => ref
      .watch(courtRepositoryProvider)
      .getBookedSlots(args.facilityId, args.date),
);

final courtDetailsProvider = FutureProvider.family<Court, String>(
  (ref, id) => ref.watch(courtRepositoryProvider).getCourtDetails(id),
);
