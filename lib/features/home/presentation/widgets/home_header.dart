import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/auth/presentation/providers/auth_providers.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour < 18) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final greeting = _getGreeting();

    return Padding(
      padding: const EdgeInsets.all(AppSizes.p20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileAsync.when(
                  data: (profile) {
                    final name =
                        profile?['full_name'] ?? AppStrings.defaultUserName;
                    return Text(
                      '$greeting, $name!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: AppSizes.h2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                  loading: () => Skeletonizer(
                    enabled: true,
                    child: Text(
                      '$greeting, User Name!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: AppSizes.h2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  error: (_, __) => Text(
                    '$greeting!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: AppSizes.h2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          ),
          profileAsync.when(
            data: (profile) {
              final avatarUrl = profile?['avatar_url'];
              return InkWell(
                onTap: () => context.router.push(const ProfileRoute()),
                borderRadius: BorderRadius.circular(AppSizes.iconLarge),
                child: CircleAvatar(
                  radius: AppSizes.iconLarge,
                  backgroundColor: theme.cardTheme.color,
                  backgroundImage: avatarUrl != null
                      ? CachedNetworkImageProvider(avatarUrl)
                      : const CachedNetworkImageProvider(
                          'https://picsum.photos/id/1027/150/150',
                        ),
                ),
              );
            },
            loading: () => Skeletonizer(
              enabled: true,
              child: CircleAvatar(
                radius: AppSizes.iconLarge,
                backgroundColor: theme.cardTheme.color,
              ),
            ),
            error: (_, __) => InkWell(
              onTap: () => context.router.push(const ProfileRoute()),
              child: const CircleAvatar(
                radius: AppSizes.iconLarge,
                backgroundImage: CachedNetworkImageProvider(
                  'https://picsum.photos/id/1027/150/150',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
