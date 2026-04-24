import 'package:flutter/material.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';

enum QuickActionType {
  nearby(
    icon: Icons.location_on,
    color: Color(0xFFBFFF00),
  ),
  hotHours(
    icon: Icons.bolt,
    color: Colors.orangeAccent,
  ),
  vouchers(
    icon: Icons.confirmation_num,
    color: Colors.pinkAccent,
  ),
  vip(
    icon: Icons.stars,
    color: Colors.cyanAccent,
  );

  final IconData icon;
  final Color color;

  const QuickActionType({
    required this.icon,
    required this.color,
  });

  String getLabel(BuildContext context) {
    return switch (this) {
      QuickActionType.nearby => context.l10n.actionNearby,
      QuickActionType.hotHours => context.l10n.actionHotHours,
      QuickActionType.vouchers => context.l10n.actionVouchers,
      QuickActionType.vip => context.l10n.actionVip,
    };
  }
}
