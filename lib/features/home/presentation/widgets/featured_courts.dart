import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';
import 'package:pickle_pick/shared/widgets/item_cards.dart';
import 'package:skeletonizer/skeletonizer.dart';

class FeaturedCourts extends ConsumerWidget {
  const FeaturedCourts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredCourts = ref.watch(featuredCourtsProvider);

    return Column(
      children: [
        SectionHeader(
          key: WidgetKeys.featuredCourtsSeeAll,
          title: context.l10n.featuredCourtsSection,
          actionLabel: context.l10n.seeAll,
          onAction: () => context.router.push(const BookingRoute()),
        ),
        featuredCourts.when(
          data: (courts) => Skeletonizer(
            enabled: false,
            child: SizedBox(
              height: AppSizes.featuredCourtHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: courts.length,
                itemBuilder: (context, index) =>
                    AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: CourtCard(
                        key: WidgetKeys.featuredCourtItem(courts[index].id),
                        court: courts[index],
                        onTap: () => context.router.push(
                          CourtDetailRoute(courtId: courts[index].id),
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
              height: AppSizes.featuredCourtHeight,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 3,
                itemBuilder: (context, index) => const Card(
                  child: SizedBox(width: 250),
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
