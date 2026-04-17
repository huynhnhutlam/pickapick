import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payment Method
// ─────────────────────────────────────────────────────────────────────────────

/// Payment methods available during booking or checkout.
enum PaymentMethod {
  picklePay(
    label: 'Ví PicklePay',
    icon: Icons.account_balance_wallet_rounded,
    color: Colors.blue,
  ),
  momo(
    label: 'Ví MoMo',
    icon: Icons.account_balance_wallet,
    color: Colors.pinkAccent,
  ),
  vnPay(
    label: 'VNPay',
    icon: Icons.qr_code_scanner,
    color: Colors.blueAccent,
  );

  final String label;
  final IconData icon;
  final Color color;

  const PaymentMethod({
    required this.label,
    required this.icon,
    required this.color,
  });
}
