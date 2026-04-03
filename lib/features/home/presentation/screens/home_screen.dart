import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/data/repositories/court_repository_impl.dart';
import 'package:pickle_pick/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';
import 'package:pickle_pick/shared/widgets/item_cards.dart';

@RoutePage()
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final featuredCourts = ref.watch(featuredCourtsProvider);
    final featuredProducts = ref.watch(featuredProductsProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Profile & Greeting
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chào buổi sáng, Lam!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'TP. Hà Nội',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/id/1027/150/150',
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar Placeholder
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.white70),
                      const SizedBox(width: 12),
                      Text(
                        'Tìm sân hoặc sản phẩm...',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Hero Banner - Using the generated image
              Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        Image.network(
                          'https://picsum.photos/id/292/800/450',
                          fit: BoxFit.cover,
                          width: double.infinity,
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
                          bottom: 24,
                          left: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GIẢM 20% ĐẶT SÂN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Áp dụng cho khung giờ vàng 14:00 - 16:00',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 44,
                                width: 150,
                                child: NeonButton(
                                  label: 'ĐẶT NGAY',
                                  onPressed: () =>
                                      context.router.push(const BookingRoute()),
                                  radius: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Quick Actions
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _QuickAction(
                      icon: Icons.location_on,
                      label: 'Sân gần bạn',
                      color: Color(0xFFBFFF00),
                    ),
                    _QuickAction(
                      icon: Icons.bolt,
                      label: 'Giờ hot',
                      color: Colors.orangeAccent,
                    ),
                    _QuickAction(
                      icon: Icons.confirmation_num,
                      label: 'Vouchers',
                      color: Colors.pinkAccent,
                    ),
                    _QuickAction(
                      icon: Icons.stars,
                      label: 'Hạng VIP',
                      color: Colors.cyanAccent,
                    ),
                  ],
                ),
              ),

              // Featured Courts
              SectionHeader(
                title: 'Sân Pickleball nổi bật',
                actionLabel: 'Xem tất cả',
                onAction: () {},
              ),
              featuredCourts.when(
                data: (courts) => SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: courts.length,
                    itemBuilder: (context, index) => CourtCard(
                      court: courts[index],
                      onTap: () => context.router.push(
                        SlotPickerRoute(courtId: courts[index].id),
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Lỗi: $e')),
              ),

              // Featured Products
              SectionHeader(
                title: 'Dụng cụ mới nhất',
                actionLabel: 'Shop ngay',
                onAction: () {},
              ),
              featuredProducts.when(
                data: (products) => SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    itemBuilder: (context, index) => ProductCard(
                      product: products[index],
                      onTap: () => context.router.push(
                        ProductDetailsRoute(product: products[index]),
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Lỗi: $e')),
              ),

              const SizedBox(height: 100), // Spacing for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
