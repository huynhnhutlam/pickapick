import 'package:flutter/material.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Payment Status
// ─────────────────────────────────────────────────────────────────────────────

/// Represents the payment status of any transaction.
enum PaymentStatus {
  unpaid(dbValue: 'unpaid', label: 'Chưa thanh toán'),
  paid(dbValue: 'paid', label: 'Đã thanh toán');

  final String dbValue;
  final String label;

  const PaymentStatus({required this.dbValue, required this.label});

  factory PaymentStatus.fromDb(String? value) =>
      value == 'paid' ? PaymentStatus.paid : PaymentStatus.unpaid;

  Color get color =>
      this == PaymentStatus.paid ? Colors.greenAccent : Colors.orange;
}
