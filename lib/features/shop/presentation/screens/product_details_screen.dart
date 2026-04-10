import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';

import '../../domain/entities/product.dart';
import '../providers/cart_providers.dart';

@RoutePage()
class ProductDetailsScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSale = product.salePrice != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: AppSizes.productDetailImageHeight,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'product_${product.id}',
                    child: Image.network(
                      product.images[0],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.shopping_bag,
                          size: AppSizes.iconCategory,
                          color: Colors.white12,
                        ),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge & Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.p12,
                          vertical: AppSizes.p4 + 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.r20),
                          border: Border.all(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          product.category,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.labelSmall,
                          ),
                        ),
                      ),
                      if (isSale)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p12,
                            vertical: AppSizes.p4 + 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSizes.r20),
                          ),
                          child: const Text(
                            'TIẾT KIỆM 20%',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: AppSizes.labelSmall,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: AppSizes.h2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),

                  // Pricing
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        (product.salePrice ?? product.price).toVND(),
                        style: TextStyle(
                          fontSize: AppSizes.h1_5,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      if (isSale) ...[
                        const SizedBox(width: AppSizes.p12),
                        Text(
                          product.price.toVND(),
                          style: const TextStyle(
                            fontSize: AppSizes.titleLarge,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSizes.p32),

                  // Description
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(
                      fontSize: AppSizes.titleLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.6,
                      fontSize: AppSizes.bodyMedium,
                    ),
                  ),

                  const SizedBox(height: AppSizes.p32),

                  // Specs
                  const Text(
                    'Thông số kỹ thuật',
                    style: TextStyle(
                      fontSize: AppSizes.titleLarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  _buildSpecRow('Chất liệu', 'Carbon Fiber Pro'),
                  _buildSpecRow('Trọng lượng', '220g - 240g'),
                  _buildSpecRow('Kích thước', '16.5" x 7.5"'),
                  _buildSpecRow('Bảo hành', '12 tháng'),

                  const SizedBox(height: AppSizes.productDetailImageHeight / 3),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        height: AppSizes.productBottomSheetHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.p24,
          vertical: AppSizes.p20,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppSizes.quickActionBoxSize,
              height: AppSizes.quickActionBoxSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSizes.r16),
              ),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            const SizedBox(width: AppSizes.p16),
            Expanded(
              child: NeonButton(
                label: 'THÊM VÀO GIỎ',
                color: theme.primaryColor,
                onPressed: () {
                  ref.read(cartProvider.notifier).add(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã thêm ${product.title} vào giỏ hàng',
                      ),
                      action: SnackBarAction(
                        label: 'XEM GIỎ',
                        onPressed: () => context.router.push(const CartRoute()),
                      ),
                    ),
                  );
                },
                radius: AppSizes.r16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.p12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white38),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
}
