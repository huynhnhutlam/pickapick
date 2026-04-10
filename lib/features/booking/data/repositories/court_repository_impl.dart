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
