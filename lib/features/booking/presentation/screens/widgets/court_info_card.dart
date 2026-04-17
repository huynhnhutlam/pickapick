import 'package:flutter/material.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';

class CourtInfoCard extends StatelessWidget {
  final String image;
  final String name;
  final String address;

  const CourtInfoCard({
    super.key,
    required this.image,
    required this.name,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.r20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            child: Image.network(
              image,
              width: AppSizes.cartItemSize,
              height: AppSizes.cartItemSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.image, color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: AppSizes.titleLarge,
                    fontWeight: FontWeight.bold,
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
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: AppSizes.labelMedium,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
