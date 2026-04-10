import 'package:flutter/material.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';

class BookingPriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;

  const BookingPriceRow({
    super.key,
    required this.label,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.p8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(
            amount.toVND(),
            style: TextStyle(
              color: color,
              fontWeight: color != null ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
}
