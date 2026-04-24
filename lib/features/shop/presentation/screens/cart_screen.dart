import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
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
        title: Text(context.l10n.cartTitle),
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
                      size: AppSizes.iconHero,
                      color: Colors.white12,
                    ),
                    const SizedBox(height: AppSizes.p20),
                    Text(
                      context.l10n.cartEmpty,
                      style: const TextStyle(
                        fontSize: AppSizes.titleLarge,
                        color: Colors.white38,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p32),
                    SizedBox(
                      width: 200,
                      child: NeonButton(
                        label: context.l10n.btnShopNow,
                        color: theme.primaryColor,
                        onPressed: () => context.router.popUntilRoot(),
                        radius: AppSizes.r30,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSizes.p20),
                      itemCount: data.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSizes.p16),
                      itemBuilder: (context, index) {
                        final item = data[index];
                        final price =
                            item.product.salePrice ?? item.product.price;

                        return Container(
                          padding: const EdgeInsets.all(AppSizes.p12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(AppSizes.r16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.r12),
                                child: Image.network(
                                  item.product.images.isNotEmpty
                                      ? item.product.images[0]
                                      : 'https://picsum.photos/100',
                                  height: AppSizes.cartItemSize,
                                  width: AppSizes.cartItemSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: AppSizes.cartItemSize,
                                    width: AppSizes.cartItemSize,
                                    color: Colors.grey[800],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSizes.p16),
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
                                    const SizedBox(height: AppSizes.p4),
                                    Text(
                                      price.toVND(),
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      size: AppSizes.iconLarge,
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
                                      size: AppSizes.iconLarge,
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

                  // ─── Summary Footer ──────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSizes.r30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.labelTotal,
                              style: const TextStyle(
                                fontSize: AppSizes.bodyLarge,
                                color: Colors.white54,
                              ),
                            ),
                            Text(
                              cartNotifier.totalAmount.toVND(),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: AppSizes.h3,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.p24),
                        Row(
                          children: [
                            Text(
                              context.l10n.labelPayment,
                              style: const TextStyle(color: Colors.white38),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.p12,
                                vertical: AppSizes.p4 + 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(AppSizes.r12),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.wallet,
                                    size: AppSizes.bodyLarge,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: AppSizes.p4 + 2),
                                  Text(
                                    'PicklePay',
                                    style: TextStyle(
                                      fontSize: AppSizes.labelSmall,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.p20),
                        NeonButton(
                          label: context.l10n.btnCheckout,
                          color: theme.primaryColor,
                          onPressed: () async {
                            if (cartNotifier.totalAmount == 0) return;

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(AppSizes.p24),
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.r16,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          color: theme.primaryColor,
                                        ),
                                        const SizedBox(height: AppSizes.p16),
                                        Text(
                                          context.l10n.processingPayment,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                            await Future.delayed(
                              const Duration(seconds: 2),
                            );

                            if (context.mounted) {
                              Navigator.of(context).pop();

                              try {
                                await ref
                                    .read(orderProvider.notifier)
                                    .createOrder(
                                      data,
                                      cartNotifier.totalAmount,
                                    );
                                await cartNotifier.fetchCart();
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(context.l10n.msgOrderFailed),
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
                                      borderRadius: BorderRadius.circular(
                                        AppSizes.r24,
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          size: AppSizes.iconHero,
                                          color: Colors.greenAccent,
                                        ),
                                        const SizedBox(height: AppSizes.p24),
                                        Text(
                                          context.l10n.paymentSuccess,
                                          style: const TextStyle(
                                            fontSize: AppSizes.h5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: AppSizes.p12),
                                        Text(
                                          context.l10n.orderConfirmed,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                        const SizedBox(height: AppSizes.p32),
                                        SizedBox(
                                          width: double.infinity,
                                          child: NeonButton(
                                            label: context.l10n.btnContinueShopping,
                                            color: theme.primaryColor,
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              context.router.popUntilRoot();
                                            },
                                            radius: AppSizes.r12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          radius: AppSizes.r16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(context.l10n.errorGeneric)),
      ),
    );
  }
}
