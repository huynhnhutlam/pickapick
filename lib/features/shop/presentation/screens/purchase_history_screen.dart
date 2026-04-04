import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';

import '../../../../core/enum/enum.dart';
import '../../domain/entities/shop_order.dart';
import '../providers/order_providers.dart';

@RoutePage()
class PurchaseHistoryScreen extends ConsumerWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử mua hàng'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: AppSizes.iconHero,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  const Text(
                    'Bạn chưa có đơn hàng nào',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: AppSizes.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  ElevatedButton(
                    onPressed: () => context.router.back(),
                    child: const Text('Mua sắm ngay'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: orders.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.p16),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(order: order);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Đã có lỗi xảy ra: $error'),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ShopOrder order;
  const _OrderCard({required this.order});

  Color _getStatusColor(OrderStatus status) => status.color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.r16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.orderNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p10,
                  vertical: AppSizes.p4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  order.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: AppSizes.labelSmall,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.p8),
          Text(
            'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
            style: const TextStyle(
              fontSize: AppSizes.labelSmall,
              color: Colors.white54,
            ),
          ),
          const Divider(height: AppSizes.p24, color: Colors.white10),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.p12),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.orderItemSize,
                    height: AppSizes.orderItemSize,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                    child: item.productImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppSizes.r8),
                            child: Image.network(
                              item.productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                size: AppSizes.iconLarge,
                                color: Colors.white24,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.sports_tennis,
                            color: Colors.white54,
                          ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: AppSizes.bodySmall),
                        ),
                        const SizedBox(height: AppSizes.p4),
                        Text(
                          'SL: ${item.quantity}',
                          style: const TextStyle(
                            fontSize: AppSizes.labelMedium,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Text(
                    item.unitPrice.toVND(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: AppSizes.p16, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(color: Colors.white54),
              ),
              Text(
                order.totalAmount.toVND(),
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.bodyLarge,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
