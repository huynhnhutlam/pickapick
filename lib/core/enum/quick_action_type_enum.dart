import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

enum QuickActionType {
  nearby(
    icon: Icons.location_on,
    label: AppStrings.actionNearby,
    color: Color(0xFFBFFF00),
  ),
  hotHours(
    icon: Icons.bolt,
    label: AppStrings.actionHotHours,
    color: Colors.orangeAccent,
  ),
  vouchers(
    icon: Icons.confirmation_num,
    label: AppStrings.actionVouchers,
    color: Colors.pinkAccent,
  ),
  vip(
    icon: Icons.stars,
    label: AppStrings.actionVip,
    color: Colors.cyanAccent,
  );

  final IconData icon;
  final String label;
  final Color color;

  const QuickActionType({
    required this.icon,
    required this.label,
    required this.color,
  });
}
