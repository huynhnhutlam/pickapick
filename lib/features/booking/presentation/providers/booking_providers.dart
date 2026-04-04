import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/enum/enum.dart';

class BookedCourt {
  final String id;
  final String courtName;
  final String courtAddress;
  final String courtImage;
  final DateTime date;
  final String slot;
  final double price;
  final BookingStatus status;

  BookedCourt({
    required this.id,
    required this.courtName,
    required this.courtAddress,
    required this.courtImage,
    required this.date,
    required this.slot,
    required this.price,
    this.status = BookingStatus.upcoming,
  });

  factory BookedCourt.fromJson(Map<String, dynamic> json) {
    // Assuming a join with facilities: facilities!inner(...)
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

class BookingNotifier extends StateNotifier<AsyncValue<List<BookedCourt>>> {
  RealtimeChannel? _channel;

  BookingNotifier(this._client, this._user) : super(const AsyncLoading()) {
    _fetchBookings();
    if (_user != null) {
      _setupRealtime();
    }
  }

  final SupabaseClient _client;
  final User? _user;

  void _setupRealtime() {
    if (_user == null) return;

    _channel = _client
        .channel('public:bookings')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _user.id,
          ),
          callback: (payload) {
            _fetchBookings();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    if (_user == null) {
      state = const AsyncData([]);
      return;
    }
    try {
      // Automatically update status of bookings that have already passed
      await _client.rpc('update_booking_statuses');

      final response = await _client
          .from('bookings')
          .select('*, facilities:facility_id(*), courts:court_id(*)')
          .eq('user_id', _user.id)
          .order('booking_date', ascending: false);

      final bookings = (response as List)
          .map((json) => BookedCourt.fromJson(json as Map<String, dynamic>))
          .toList();
      if (mounted) state = AsyncData(bookings);
    } catch (e, s) {
      if (mounted) state = AsyncError(e, s);
      developer.log('Fetch bookings failed', error: e, stackTrace: s);
    }
  }

  Future<void> addBooking(
    BookedCourt newBooking,
    String facilityId,
    String courtId,
  ) async {
    if (_user == null) return;

    try {
      // Parse slot range "HH:mm - HH:mm"
      final parts = newBooking.slot.split(' - ');
      final startTime = '${parts[0]}:00';
      final endTime = '${parts[1]}:00';

      final startH = int.parse(parts[0].substring(0, 2));
      final endH = int.parse(parts[1].substring(0, 2));
      final duration = endH - startH;

      await _client.from('bookings').insert({
        'user_id': _user.id,
        'facility_id': facilityId,
        'court_id': courtId,
        'booking_date': newBooking.date.toIso8601String().split('T').first,
        'start_time': startTime,
        'end_time': endTime,
        'duration_hours': duration,
        'total_price': newBooking.price,
        'status': 'confirmed',
        'payment_status': 'unpaid',
      });
      await _fetchBookings();
    } catch (e, s) {
      developer.log('Add booking failed', error: e, stackTrace: s);
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _client
          .from('bookings')
          .update({'status': 'cancelled'}).eq('id', bookingId);
      await _fetchBookings();
    } catch (e, s) {
      developer.log('Cancel booking failed', error: e, stackTrace: s);
      rethrow;
    }
  }
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, AsyncValue<List<BookedCourt>>>(
        (ref) {
  final user = ref.watch(authNotifierProvider).valueOrNull;
  return BookingNotifier(Supabase.instance.client, user);
});
