import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';

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
                    size: 80,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bạn chưa có đơn hàng nào',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.router.back(),
                    child: const Text('Mua sắm ngay'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getStatusColor(String status) {
      switch (status) {
        case 'pending':
          return Colors.orange;
        case 'processing':
          return Colors.blue;
        case 'shipped':
          return Colors.purple;
        case 'delivered':
        case 'completed':
          return Colors.green;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.white54;
      }
    }

    String getStatusText(String status) {
      switch (status) {
        case 'pending':
          return 'Chờ xác nhận';
        case 'processing':
          return 'Đang chuẩn bị hàng';
        case 'shipped':
          return 'Đang giao';
        case 'delivered':
        case 'completed':
          return 'Đã hoàn thành';
        case 'cancelled':
          return 'Đã hủy';
        default:
          return status;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(16),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: getStatusColor(order.status).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  getStatusText(order.status),
                  style: TextStyle(
                    color: getStatusColor(order.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const Divider(height: 24, color: Colors.white10),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: item.productImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                size: 20,
                                color: Colors.white24,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.sports_tennis,
                            color: Colors.white54,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SL: ${item.quantity}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.unitPrice.toVND(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 16, color: Colors.white10),
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
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
