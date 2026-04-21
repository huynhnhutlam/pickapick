import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/enum/enum.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';
import 'package:pickle_pick/core/router/app_router.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
      child: AnimationLimiter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: QuickActionType.values
                .map(
                  (action) => _QuickAction(
                    key: WidgetKeys.quickActionItem(action.name),
                    action: action,
                    onTap: () {
                      switch (action) {
                        case QuickActionType.nearby:
                        case QuickActionType.hotHours:
                          context.router.push(const BookingRoute());
                          break;
                        case QuickActionType.vouchers:
                          context.router.push(const ShopRoute());
                          break;
                        case QuickActionType.vip:
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tính năng đang phát triển'),
                            ),
                          );
                          break;
                      }
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final QuickActionType action;
  final VoidCallback onTap;

  const _QuickAction({
    required super.key,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          child: Container(
            height: AppSizes.quickActionBoxSize,
            width: AppSizes.quickActionBoxSize,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.r16),
              border: Border.all(color: action.color.withValues(alpha: 0.3)),
            ),
            child: Icon(
              action.icon,
              color: action.color,
              size: AppSizes.iconHuge,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p8),
        Text(
          action.label,
          style: TextStyle(
            fontSize: AppSizes.labelSmall,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
