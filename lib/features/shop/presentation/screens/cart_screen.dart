import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';

import '../providers/cart_providers.dart';
import '../providers/order_providers.dart';

@RoutePage()
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => cartNotifier.clear(),
          ),
        ],
      ),
      body: cartItems.when(
        data: (data) => data.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.white12,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Giỏ hàng trống',
                      style: TextStyle(fontSize: 18, color: Colors.white38),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 200,
                      child: NeonButton(
                        label: 'MUA SẮM NGAY',
                        color: theme.primaryColor,
                        onPressed: () => context.router.popUntilRoot(),
                        radius: 30,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: data.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        final price =
                            item.product.salePrice ?? item.product.price;

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.product.images.isNotEmpty
                                      ? item.product.images[0]
                                      : 'https://picsum.photos/100', // Safefallback
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 80,
                                    width: 80,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      price.toVND(),
                                      style:
                                          TextStyle(color: theme.primaryColor),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        cartNotifier.updateQuantity(
                                      item.id,
                                      item.quantity + 1,
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        cartNotifier.updateQuantity(
                                      item.id,
                                      item.quantity - 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Summary Footer
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng cộng',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white54,
                              ),
                            ),
                            Text(
                              cartNotifier.totalAmount.toVND(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Text('Thanh toán:',
                                style: TextStyle(color: Colors.white38),),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6,),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.3),),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.wallet,
                                      size: 16, color: Colors.blue,),
                                  SizedBox(width: 6),
                                  Text('PicklePay',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,),),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        NeonButton(
                          label: 'THANH TOÁN',
                          color: theme.primaryColor,
                          onPressed: () async {
                            if (cartNotifier.totalAmount == 0) return;

                            // Show processing dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          color: theme.primaryColor,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Đang xử lý thanh toán...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                            await Future.delayed(const Duration(seconds: 2));

                            if (context.mounted) {
                              Navigator.of(context).pop(); // pop processing

                              try {
                                await ref
                                    .read(orderProvider.notifier)
                                    .createOrder(
                                      data,
                                      cartNotifier.totalAmount,
                                    );
                                // Also tell cart notifier to refresh so it properly reflects empty state
                                await cartNotifier.fetchCart();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tạo đơn hàng thất bại'),
                                    ),
                                  );
                                }
                                return;
                              }

                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: theme.cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          size: 80,
                                          color: Colors.greenAccent,
                                        ),
                                        const SizedBox(height: 24),
                                        const Text(
                                          'Thanh toán thành công!',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'Đơn hàng của bạn đã được ghi nhận.',
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyle(color: Colors.white54),
                                        ),
                                        const SizedBox(height: 32),
                                        SizedBox(
                                          width: double.infinity,
                                          child: NeonButton(
                                            label: 'TIẾP TỤC MUA SẮM',
                                            color: theme.primaryColor,
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              context.router.popUntilRoot();
                                            },
                                            radius: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          radius: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}
