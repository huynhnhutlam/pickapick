import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../providers/home_providers.dart';

class HomeBanner extends ConsumerStatefulWidget {
  const HomeBanner({super.key});

  @override
  ConsumerState<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends ConsumerState<HomeBanner> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(homeBannersProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
      child: SizedBox(
        height: 200,
        child: bannersAsync.when(
          data: (banners) {
            if (banners.isEmpty) return const SizedBox.shrink();

            return PageView.builder(
              key: WidgetKeys.homeBannerPageView,
              controller: _pageController,
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return Padding(
                  key: WidgetKeys.homeBannerItem(index),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.r24),
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: banner.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[900]),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
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
                          bottom: AppSizes.p20,
                          left: AppSizes.p20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.h5,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p4),
                              Text(
                                banner.subtitle,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: AppSizes.labelSmall,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p12),
                              SizedBox(
                                height: 38,
                                child: NeonButton(
                                  key: WidgetKeys.bannerActionButton(index),
                                  label: banner.actionTitle ??
                                      context.l10n.bannerAction,
                                  onPressed: () {
                                    if (banner.actionUrl != null &&
                                        banner.actionUrl!.isNotEmpty) {
                                      // Thường handle URL hoặc route tương ứng
                                      context.router.push(const BookingRoute());
                                    } else {
                                      context.router.push(const BookingRoute());
                                    }
                                  },
                                  radius: AppSizes.r12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Skeletonizer(
            enabled: true,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 2,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.r24),
                    child: Container(
                      color: Colors.grey[800],
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                );
              },
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
