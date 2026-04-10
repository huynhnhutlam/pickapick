// ─────────────────────────────────────────────────────────────────────────────
// Booking Status
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// Represents the status of a court booking.
///
/// [dbValue] is the raw string stored in Supabase.
/// [label] is the Vietnamese display label shown in the UI.
enum BookingStatus {
  upcoming(dbValue: 'confirmed', label: 'Sắp tới'),
  completed(dbValue: 'completed', label: 'Đã chơi'),
  cancelled(dbValue: 'cancelled', label: 'Đã hủy'),
  pending(dbValue: 'pending', label: 'Chờ xử lý');

  final String dbValue;
  final String label;

  const BookingStatus({required this.dbValue, required this.label});

  /// Parses a raw DB string into a [BookingStatus].
  /// Defaults to [BookingStatus.upcoming] for unknown values.
  factory BookingStatus.fromDb(String? value) => switch (value) {
        'completed' => BookingStatus.completed,
        'cancelled' => BookingStatus.cancelled,
        'pending' => BookingStatus.pending,
        _ => BookingStatus.upcoming,
      };

  /// UI color associated with this status.
  Color get color => switch (this) {
        BookingStatus.upcoming => const Color(0xFFBFFF00),
        BookingStatus.completed => Colors.greenAccent,
        BookingStatus.cancelled => Colors.redAccent,
        BookingStatus.pending => Colors.orange,
      };

  /// Badge background color (color with low opacity).
  Color get badgeColor => color.withValues(alpha: 0.1);

  /// Badge border color.
  Color get badgeBorderColor => color.withValues(alpha: 0.3);
}
