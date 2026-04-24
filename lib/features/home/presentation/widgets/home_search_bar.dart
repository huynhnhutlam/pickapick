import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
import 'package:pickle_pick/core/router/app_router.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p20,
        vertical: AppSizes.p10,
      ),
      child: InkWell(
        onTap: () => context.router.push(const BookingRoute()),
        borderRadius: BorderRadius.circular(AppSizes.r20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
          height: AppSizes.searchBarHeight,
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(AppSizes.r20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white70),
              const SizedBox(width: AppSizes.p12),
              Text(
                context.l10n.homeSearchHint,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
