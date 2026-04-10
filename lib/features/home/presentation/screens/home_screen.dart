import 'dart:developer' as developer;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';
import 'package:pickle_pick/shared/widgets/item_cards.dart';

import '../../../../core/enum/enum.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final featuredCourts = ref.watch(featuredCourtsProvider);
    final featuredProducts = ref.watch(featuredProductsProvider);
    developer.log('HomeScreen built', name: 'UI');
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Profile & Greeting
              Padding(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.homeGreeting,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: AppSizes.h2,
                          ),
                        ),
                        const SizedBox(height: AppSizes.p4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: AppSizes.iconSmall,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: AppSizes.p4),
                            Text(
                              AppStrings.homeLocationDefault,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: AppSizes.bodySmall,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: AppSizes.iconLarge,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/id/1027/150/150',
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar Placeholder
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p20,
                  vertical: AppSizes.p10,
                ),
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
                        AppStrings.homeSearchHint,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hero Banner - Using the generated image
              Padding(
                padding: const EdgeInsets.all(AppSizes.p20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.r24),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Image.network(
                          'https://picsum.photos/id/292/800/450',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [
                                Colors.black.withValues(alpha: 0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: AppSizes.p24,
                          left: AppSizes.p24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                AppStrings.bannerPromoTitle,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.h4,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p4),
                              const Text(
                                AppStrings.bannerPromoSubtitle,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: AppSizes.labelSmall,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p16),
                              SizedBox(
                                height: 44,
                                width: 150,
                                child: NeonButton(
                                  label: AppStrings.bannerAction,
                                  onPressed: () =>
                                      context.router.push(const BookingRoute()),
                                  radius: AppSizes.r12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: QuickActionType.values
                      .map((action) => _QuickAction(action: action))
                      .toList(),
                ),
              ),

              // Featured Courts
              SectionHeader(
                title: AppStrings.sectionFeaturedCourts,
                actionLabel: AppStrings.seeAll,
                onAction: () {},
              ),
              featuredCourts.when(
                data: (courts) => SizedBox(
                  height: AppSizes.featuredCourtHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: courts.length,
                    itemBuilder: (context, index) => CourtCard(
                      court: courts[index],
                      onTap: () => context.router.push(
                        CourtDetailRoute(courtId: courts[index].id),
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(
                  child: Text('${AppStrings.errorLoading}$e'),
                ),
              ),

              // Featured Products
              SectionHeader(
                title: AppStrings.sectionNewProducts,
                actionLabel: AppStrings.shopNow,
                onAction: () {},
              ),
              featuredProducts.when(
                data: (products) => SizedBox(
                  height: AppSizes.featuredProductHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) => ProductCard(
                      product: products[index],
                      onTap: () => context.router.push(
                        ProductDetailsRoute(product: products[index]),
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(
                  child: Text('${AppStrings.errorLoading}$e'),
                ),
              ),

              const SizedBox(height: AppSizes.bottomNavSpacing),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final QuickActionType action;

  const _QuickAction({required this.action});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
