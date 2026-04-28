import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/domain/entities/court.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';

@RoutePage()
class CourtDetailScreen extends ConsumerWidget {
  final String courtId;

  const CourtDetailScreen({super.key, required this.courtId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courtAsync = ref.watch(courtDetailsProvider(courtId));

    return Scaffold(
      key: WidgetKeys.courtDetailScaffold,
      body: courtAsync.when(
        data: (court) => _CourtDetailBody(court: court),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(
          child: Text(context.l10n.errorLoading(e.toString())),
        ),
      ),
      bottomNavigationBar: courtAsync.hasValue
          ? _BottomBookingBar(court: courtAsync.value!)
          : null,
    );
  }
}

class _CourtDetailBody extends StatelessWidget {
  final Court court;

  const _CourtDetailBody({required this.court});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        // App Bar with Image Gallery
        SliverAppBar(
          expandedHeight: AppSizes.courtDetailImageHeight,
          pinned: true,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final top = constraints.biggest.height;
              final isCollapsed = top <=
                  kToolbarHeight +
                      MediaQuery.of(context).padding.top +
                      AppSizes.p40;

              return FlexibleSpaceBar(
                centerTitle: true,
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isCollapsed ? 1.0 : 0.0,
                  child: Text(
                    court.name,
                    style: const TextStyle(
                      fontSize: AppSizes.titleLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                background: _ImageGallery(images: court.images),
              );
            },
          ),
          leading: Padding(
            padding: const EdgeInsets.all(AppSizes.p8),
            child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.router.maybePop(),
              ),
            ),
          ),
        ),

        // Court Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: AppSizes.p16,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: AppSizes.p4),
                              Expanded(
                                child: Text(
                                  court.address,
                                  style: const TextStyle(color: Colors.white54),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.p16),
                    _RatingBadge(rating: court.rating),
                  ],
                ),
                const SizedBox(height: AppSizes.p32),
                _SectionTitle(title: context.l10n.sectionDescription),
                const SizedBox(height: AppSizes.p12),
                Text(
                  court.description,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: AppSizes.p32),
                _SectionTitle(title: context.l10n.sectionAmenities),
                const SizedBox(height: AppSizes.p16),
                _AmenitiesGrid(amenities: court.amenities),
                const SizedBox(height: AppSizes.p32),
                _SectionTitle(title: context.l10n.sectionRules),
                const SizedBox(height: AppSizes.p16),
                _RulesList(rules: court.rules),
                const SizedBox(height: AppSizes.p32),
                _SectionTitle(title: context.l10n.sectionLocation),
                const SizedBox(height: AppSizes.p16),
                _MapPlaceholder(),
                const SizedBox(height: AppSizes.p32),
                _SectionTitle(
                  title: context.l10n.reviewsCount(court.reviewCount),
                ),
                const SizedBox(height: AppSizes.p16),
                _ReviewsList(courtId: court.id),
                const SizedBox(height: AppSizes.bottomNavSpacing),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageGallery extends StatefulWidget {
  final List<String> images;
  const _ImageGallery({required this.images});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.images.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: widget.images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[900]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            );
          },
        ),
        Positioned(
          bottom: AppSizes.p20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => Container(
                width: AppSizes.p8,
                height: AppSizes.p8,
                margin: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p12,
        vertical: AppSizes.p8,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.r12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: Colors.amber,
            size: AppSizes.iconMedium,
          ),
          const SizedBox(width: AppSizes.p4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: AppSizes.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: AppSizes.titleLarge,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _AmenitiesGrid extends StatelessWidget {
  final List<String> amenities;
  const _AmenitiesGrid({required this.amenities});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: amenities.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        mainAxisSpacing: AppSizes.p12,
        crossAxisSpacing: AppSizes.p12,
      ),
      itemBuilder: (context, index) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.r8),
              ),
              child: Icon(
                _getAmenityIcon(amenities[index]),
                size: AppSizes.p16,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: AppSizes.p10),
            Expanded(
              child: Text(
                amenities[index],
                style: const TextStyle(
                  fontSize: AppSizes.bodyMedium,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getAmenityIcon(String name) {
    name = name.toLowerCase();
    if (name.contains('wifi')) return Icons.wifi;
    if (name.contains('đỗ xe') || name.contains('parking')) {
      return Icons.local_parking;
    }
    if (name.contains('nước') || name.contains('water')) {
      return Icons.local_drink;
    }
    if (name.contains('tắm') || name.contains('shower')) return Icons.shower;
    if (name.contains('vợt') || name.contains('racket')) {
      return Icons.sports_tennis;
    }
    if (name.contains('thực phẩm') || name.contains('food')) {
      return Icons.restaurant;
    }
    return Icons.check_circle_outline;
  }
}

class _RulesList extends StatelessWidget {
  final List<String> rules;
  const _RulesList({required this.rules});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rules
          .map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.p8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: AppSizes.p4),
                    child: Icon(
                      Icons.info_outline,
                      size: AppSizes.iconSmall,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: AppSizes.p8),
                  Expanded(
                    child: Text(
                      rule,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: AppSizes.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.mapHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(AppSizes.r20),
        image: const DecorationImage(
          image: CachedNetworkImageProvider(
            'https://api.mapbox.com/styles/v1/mapbox/dark-v10/static/106.6297,10.8231,13/800x400?access_token=YOUR_MAPBOX_TOKEN_PLACEHOLDER',
          ),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.redAccent,
              size: AppSizes.p40,
            ),
            const SizedBox(height: AppSizes.p12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16,
                vertical: AppSizes.p8,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(AppSizes.r30),
              ),
              child: Text(
                context.l10n.mapUpdating,
                style: const TextStyle(
                  fontSize: AppSizes.labelSmall,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final String courtId;
  const _ReviewsList({required this.courtId});

  @override
  Widget build(BuildContext context) {
    // Mock reviews for now
    final reviews = [
      {
        'user': 'Anh Tuấn',
        'rating': 5,
        'comment': 'Sân rất đẹp, ánh sáng tốt.',
        'date': '2 ngày trước',
      },
      {
        'user': 'Hoàng Nam',
        'rating': 4,
        'comment': 'Giá hơi cao nhưng chất lượng tuyệt vời.',
        'date': '1 tuần trước',
      },
    ];

    return Column(
      children: reviews
          .map(
            (review) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.p16),
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(AppSizes.r16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review['user'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        review['date'] as String,
                        style: const TextStyle(
                          fontSize: AppSizes.labelSmall,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: AppSizes.iconSmall,
                        color: index < (review['rating'] as int)
                            ? Colors.amber
                            : Colors.white12,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p8),
                  Text(
                    review['comment'] as String,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: AppSizes.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BottomBookingBar extends StatelessWidget {
  final Court court;
  const _BottomBookingBar({required this.court});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.p24,
        AppSizes.p16,
        AppSizes.p24,
        AppSizes.p32,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.r30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.startingFrom,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: AppSizes.labelSmall,
                ),
              ),
              Text(
                court.pricePerHour.toVND(),
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: AppSizes.h4,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSizes.p24),
          Expanded(
            child: NeonButton(
              key: WidgetKeys.bookNowButton,
              label: context.l10n.btnContinue,
              onPressed: () => context.router.push(
                SlotPickerRoute(
                  courtId: court.id,
                  courtName: court.name,
                  courtAddress: court.address,
                  courtImage:
                      court.images.isNotEmpty ? court.images.first : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
