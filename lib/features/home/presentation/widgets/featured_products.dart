import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';
import 'package:pickle_pick/shared/widgets/item_cards.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FeaturedProducts extends ConsumerWidget {
  const FeaturedProducts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredProducts = ref.watch(featuredProductsProvider);

    return Column(
      children: [
        SectionHeader(
          key: WidgetKeys.featuredProductsSeeAll,
          title: context.l10n.featuredProductsSection,
          actionLabel: context.l10n.btnShopNow,
          onAction: () => context.router.push(const ShopRoute()),
        ),
        featuredProducts.when(
          data: (products) => Skeletonizer(
            enabled: false,
            child: SizedBox(
              height: AppSizes.featuredProductHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: products.length,
                itemBuilder: (context, index) =>
                    AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: ProductCard(
                        key: WidgetKeys.featuredProductItem(products[index].id),
                        product: products[index],
                        onTap: () => context.router.push(
                          ProductDetailsRoute(product: products[index]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          loading: () => Skeletonizer(
            enabled: true,
            child: SizedBox(
              height: AppSizes.featuredProductHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 3,
                itemBuilder: (context, index) => const Card(
                  child: SizedBox(width: 150),
                ),
              ),
            ),
          ),
          error: (e, s) => Center(
            child: Text(context.l10n.errorLoading(e.toString())),
          ),
        ),
      ],
    );
  }
}
