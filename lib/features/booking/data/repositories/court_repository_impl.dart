import 'dart:async';
import 'dart:developer' as developer;
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/booked_court.dart';
import '../../domain/entities/court.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/sub_court.dart';
import '../../domain/repositories/court_repository.dart';

import '../models/booked_court_model.dart';
import '../models/court_model.dart';
import '../models/equipment_model.dart';
import '../models/sub_court_model.dart';

/// Supabase-backed implementation of [CourtRepository].
class SupabaseCourtRepository implements CourtRepository {
  SupabaseCourtRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Either<Failure, List<Court>>> getCourts() async {
    return _handleRequest(() async {
      final response = await _client
          .from('facilities')
          .select()
          .eq('is_active', true)
          .order('rating', ascending: false);

      return (response as List)
          .map(
            (json) =>
                CourtModel.fromJson(json as Map<String, dynamic>).toEntity(),
          )
          .toList();
    });
  }

  @override
  Future<Either<Failure, Court>> getCourtDetails(String id) async {
    return _handleRequest(() async {
      final json =
          await _client.from('facilities').select().eq('id', id).single();
      return CourtModel.fromJson(json).toEntity();
    });
  }

  @override
  Future<Either<Failure, List<SubCourt>>> getSubCourts(
    String facilityId,
  ) async {
    return _handleRequest(() async {
      final response = await _client
          .from('courts')
          .select()
          .eq('facility_id', facilityId)
          .eq('is_active', true)
          .order('court_number');

      return (response as List)
          .map(
            (json) =>
                SubCourtModel.fromJson(json as Map<String, dynamic>).toEntity(),
          )
          .toList();
    });
  }

  @override
  Future<Either<Failure, List<Equipment>>> getRentalServices() async {
    return _handleRequest(() async {
      final response = await _client
          .from('rental_services')
          .select()
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map(
            (json) => EquipmentModel.fromJson(json as Map<String, dynamic>)
                .toEntity(),
          )
          .toList();
    });
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    return _handleRequest(() async {
      await _client
          .from('bookings')
          .update({'status': 'cancelled'}).eq('id', bookingId);
    });
  }

  @override
  Future<Either<Failure, void>> syncBookingStatuses() async {
    return _handleRequest(() async {
      await _client.rpc('update_booking_statuses');
    });
  }

  @override
  Future<Either<Failure, List<BookedCourt>>> getBookings(String userId) async {
    return _handleRequest(() async {
      await _client.rpc('update_booking_statuses');

      final response = await _client
          .from('bookings')
          .select('*, facilities:facility_id(*), courts:court_id(*)')
          .eq('user_id', userId)
          .order('booking_date', ascending: false);

      return (response as List)
          .map(
            (json) =>
                BookedCourtModel.fromSupabase(json as Map<String, dynamic>),
          )
          .toList();
    });
  }

  @override
  Future<Either<Failure, void>> addBooking({
    required String userId,
    required BookedCourt booking,
    required String facilityId,
    required String courtId,
    required List<Equipment> equipment,
    required String? voucherCode,
    required double discountAmount,
    required String paymentMethod,
  }) async {
    return _handleRequest(() async {
      final equipmentDetails =
          equipment.map((e) => EquipmentModel.fromEntity(e).toJson()).toList();

      final bookingJson = BookedCourtModel.toJson(
        booking,
        userId: userId,
        facilityId: facilityId,
        courtId: courtId,
        equipmentDetails: equipmentDetails,
        voucherCode: voucherCode,
        discountAmount: discountAmount,
        paymentMethod: paymentMethod,
      );

      await _client.from('bookings').insert(bookingJson);
    });
  }

  @override
  Future<Either<Failure, List<String>>> getBookedSlots(
    String courtId,
    DateTime date,
  ) async {
    return _handleRequest(() async {
      final dateStr = date.toIso8601String().split('T').first;

      final response = await _client
          .from('bookings')
          .select('start_time, end_time')
          .eq('court_id', courtId)
          .eq('booking_date', dateStr)
          .neq('status', 'cancelled');

      return (response as List).map((json) {
        final start = (json['start_time'] as String).substring(0, 5);
        final end = (json['end_time'] as String).substring(0, 5);
        return '$start - $end';
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableSlots(
    String courtId,
    DateTime date,
  ) async {
    return _handleRequest(() async {
      // Handle both DOW (0-6) and ISODOW (1-7) gracefully
      final dartWeekday = date.weekday;

      developer.log(
        'Fetching available slots for court: $courtId on date: $date (weekday: $dartWeekday)',
        name: 'CourtRepositoryImpl',
      );

      final response = await _client
          .from('courts')
          .select('*, facilities(open_time, close_time), court_schedules(*)')
          .eq('id', courtId)
          .single();

      developer.log(
        'API Response for courts: $response',
        name: 'CourtRepositoryImpl',
      );

      final facility = response['facilities'] as Map<String, dynamic>?;
      final schedules = response['court_schedules'] as List?;

      String openTimeStr = facility?['open_time']?.toString() ?? '06:00:00';
      String closeTimeStr = facility?['close_time']?.toString() ?? '22:00:00';

      // Fallback: try to get slot_duration_minutes from courts or facilities before defaulting to 60
      final defaultDurationRaw = response['slot_duration_minutes'] ??
          facility?['slot_duration_minutes'];
      int duration = 60;
      if (defaultDurationRaw != null) {
        duration = defaultDurationRaw is int
            ? defaultDurationRaw
            : (int.tryParse(defaultDurationRaw.toString()) ?? 60);
      }

      // Find the specific schedule for this day safely
      Map<String, dynamic>? scheduleForDay;
      try {
        if (schedules != null) {
          for (final item in schedules) {
            final converted = item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map);

            final dbDay = converted['day_of_week'] is int
                ? converted['day_of_week']
                : int.tryParse(converted['day_of_week']?.toString() ?? '');

            // Accommodate missing is_active flag or true/1
            final isActive = converted['is_active'] == null ||
                converted['is_active'] == true ||
                converted['is_active'] == 1;

            // Match if dbDay is 1-7 matching date.weekday or 0-6 matching date.weekday%7
            if (dbDay != null &&
                (dbDay == dartWeekday ||
                    dbDay == dartWeekday % 7 ||
                    (dartWeekday == 7 && dbDay == 0)) &&
                isActive) {
              scheduleForDay = converted;
              break;
            }
          }
        }
      } catch (e) {
        developer.log(
          'Error parsing schedules: $e',
          name: 'CourtRepositoryImpl',
        );
      }

      if (scheduleForDay != null && scheduleForDay.isNotEmpty) {
        developer.log(
          'Found specific schedule: $scheduleForDay',
          name: 'CourtRepositoryImpl',
        );
        // Handle various possible column names for times
        openTimeStr = scheduleForDay['open_time']?.toString() ??
            scheduleForDay['start_time']?.toString() ??
            openTimeStr;
        closeTimeStr = scheduleForDay['close_time']?.toString() ??
            scheduleForDay['end_time']?.toString() ??
            closeTimeStr;

        final durationRaw = scheduleForDay['slot_duration_minutes'] ??
            scheduleForDay['session_duration'];

        if (durationRaw != null) {
          duration = durationRaw is int
              ? durationRaw
              : (int.tryParse(durationRaw.toString()) ?? 60);
        }
      }

      developer.log(
        'Using openTime: $openTimeStr, closeTime: $closeTimeStr, duration: $duration',
        name: 'CourtRepositoryImpl',
      );

      // Generate slots
      final slots = <String>[];
      final start = _parseTime(openTimeStr);
      final end = _parseTime(closeTimeStr);

      var current = start;
      while (current.isBefore(end)) {
        final next = current.add(Duration(minutes: duration));
        if (next.isAfter(end)) {
          // If the last slot exceeds closing time, we can either truncate it to closing time or just skip it.
          // Let's truncate to closing time:
          slots.add('${_formatTime(current)} - ${_formatTime(end)}');
        } else {
          slots.add('${_formatTime(current)} - ${_formatTime(next)}');
        }
        current = next;
      }

      developer.log('Generated slots: $slots', name: 'CourtRepositoryImpl');
      return slots;
    });
  }

  DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(2000, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Stream<void> watchBookings(String userId) {
    final controller = StreamController<void>();
    RealtimeChannel? channel;

    controller.onListen = () {
      channel = _client
          .channel('public:bookings:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'bookings',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              if (!controller.isClosed) {
                controller.add(null);
              }
            },
          )
          .subscribe();
    };

    controller.onCancel = () {
      channel?.unsubscribe();
      if (!controller.isClosed) {
        controller.close();
      }
    };

    return controller.stream;
  }

  /// Helper method to catch exceptions and return [Either].
  Future<Either<Failure, T>> _handleRequest<T>(
    Future<T> Function() request,
  ) async {
    try {
      final result = await request();
      return Right(result);
    } on PostgrestException catch (e) {
      developer.log('Supabase DB Error', error: e);
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      developer.log('Unknown Error', error: e);
      return Left(ServerFailure(e.toString()));
    } catch (e, stack) {
      developer.log('Critical Error', error: e, stackTrace: stack);
      return const Left(ServerFailure('Đã có lỗi không mong muốn xảy ra'));
    }
  }
}
