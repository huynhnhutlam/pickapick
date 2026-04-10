import 'package:flutter/material.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';

class BookingDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const BookingDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.iconLarge, color: Colors.white38),
        const SizedBox(width: AppSizes.p12),
        Text(label, style: const TextStyle(color: Colors.white54)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
