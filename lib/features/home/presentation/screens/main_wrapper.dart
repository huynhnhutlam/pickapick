import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
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
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: context.l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today),
              label: context.l10n.bookings,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_bag),
              label: context.l10n.shop,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: context.l10n.profileTab,
            ),
          ],
        );
      },
    );
  }
}
