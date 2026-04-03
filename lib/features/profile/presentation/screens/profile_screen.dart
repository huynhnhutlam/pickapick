import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/auth/presentation/providers/auth_providers.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_providers.dart';

@RoutePage()
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookingsCount = ref.watch(bookingProvider).value?.length ?? 0;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child:
                            Icon(Icons.person, size: 40, color: Colors.black),
                      ),
                      const SizedBox(height: 12),
                      Consumer(
                        builder: (context, ref, child) {
                          final user = ref.watch(authNotifierProvider).value;
                          final fullName =
                              user?.userMetadata?['full_name'] as String? ??
                                  'Khách';
                          final email = user?.email ?? '';

                          return Column(
                            children: [
                              Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              if (email.isNotEmpty)
                                Text(
                                  email,
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hoạt động của tôi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    icon: Icons.calendar_month,
                    title: 'Lịch đặt sân',
                    subtitle: bookingsCount == 0
                        ? 'Chưa có lịch đặt'
                        : 'Bạn có $bookingsCount lịch đặt',
                    badge: bookingsCount == 0 ? null : bookingsCount.toString(),
                    onTap: () =>
                        context.router.push(const BookingHistoryRoute()),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'Đơn mua hàng',
                    subtitle: 'Theo dõi đơn hàng của bạn',
                    onTap: () =>
                        context.router.push(const PurchaseHistoryRoute()),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    icon: Icons.favorite_border,
                    title: 'Yêu thích',
                    subtitle: 'Sân và sản phẩm đã lưu',
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Tài khoản',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuCard(
                    context,
                    icon: Icons.person_outline,
                    title: 'Thông tin cá nhân',
                    subtitle: 'Cập nhật thông tin của bạn',
                    onTap: () => context.router.push(const EditProfileRoute()),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    icon: Icons.notifications_none,
                    title: 'Thông báo',
                    subtitle: 'Cài đặt thông báo',
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    context,
                    icon: Icons.help_outline,
                    title: 'Hỗ trợ',
                    subtitle: 'Liên hệ với chúng tôi',
                  ),
                  const SizedBox(height: 48),
                  // Logout button
                  (ref.watch(authNotifierProvider).value != null)
                      ? _buildLogoutButton(
                          'Đăng xuất',
                          onPressed: () async {
                            await ref
                                .read(authNotifierProvider.notifier)
                                .signOut();
                          },
                        )
                      : _buildLogoutButton(
                          'Đăng nhập',
                          onPressed: () {
                            if (context.mounted) {
                              context.router.push(const LoginRoute());
                            }
                          },
                        ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(String title, {Function? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => onPressed?.call(),
        child: Text(title),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: theme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
