// ─────────────────────────────────────────────────────────────────────────────
// Order Status
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// Represents the fulfilment status of a shop order.
enum OrderStatus {
  pending(dbValue: 'pending', label: 'Chờ xác nhận'),
  processing(dbValue: 'processing', label: 'Đang chuẩn bị hàng'),
  shipped(dbValue: 'shipped', label: 'Đang giao'),
  delivered(dbValue: 'delivered', label: 'Đã hoàn thành'),
  completed(dbValue: 'completed', label: 'Đã hoàn thành'),
  cancelled(dbValue: 'cancelled', label: 'Đã hủy');

  final String dbValue;
  final String label;

  const OrderStatus({required this.dbValue, required this.label});

  factory OrderStatus.fromDb(String? value) => switch (value) {
        'processing' => OrderStatus.processing,
        'shipped' => OrderStatus.shipped,
        'delivered' => OrderStatus.delivered,
        'completed' => OrderStatus.completed,
        'cancelled' => OrderStatus.cancelled,
        _ => OrderStatus.pending,
      };

  Color get color => switch (this) {
        OrderStatus.pending => Colors.orange,
        OrderStatus.processing => Colors.blue,
        OrderStatus.shipped => Colors.purple,
        OrderStatus.delivered || OrderStatus.completed => Colors.green,
        OrderStatus.cancelled => Colors.red,
      };

  Color get badgeColor => color.withValues(alpha: 0.1);
  Color get badgeBorderColor => color.withValues(alpha: 0.5);
}
