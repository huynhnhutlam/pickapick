import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pickle_pick/core/router/app_router.dart';

@RoutePage()
class MainWrapperScreen extends StatelessWidget {
  const MainWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [
        HomeRoute(),
        BookingRoute(),
        ShopRoute(),
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.white.withValues(alpha: 0.6),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Đặt sân',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Shop',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tôi'),
          ],
        );
      },
    );
  }
}
