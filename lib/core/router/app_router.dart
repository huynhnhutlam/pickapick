import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Screens
import 'package:pickle_pick/features/auth/presentation/screens/login_screen.dart';
import 'package:pickle_pick/features/auth/presentation/screens/register_screen.dart';
import 'package:pickle_pick/features/booking/domain/entities/booked_court.dart';
import 'package:pickle_pick/features/booking/presentation/screens/booking_detail_screen.dart';
import 'package:pickle_pick/features/booking/presentation/screens/booking_history_screen.dart';
import 'package:pickle_pick/features/booking/presentation/screens/booking_summary_screen.dart';
import 'package:pickle_pick/features/booking/presentation/screens/court_detail_screen.dart';
import 'package:pickle_pick/features/booking/presentation/screens/court_list_screen.dart';
import 'package:pickle_pick/features/booking/presentation/screens/court_slot_picker_screen.dart';
import 'package:pickle_pick/features/home/presentation/screens/home_screen.dart';
import 'package:pickle_pick/features/home/presentation/screens/main_wrapper.dart';
import 'package:pickle_pick/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:pickle_pick/features/profile/presentation/screens/profile_screen.dart';
// Domain Entities
import 'package:pickle_pick/features/shop/domain/entities/product.dart';
import 'package:pickle_pick/features/shop/presentation/screens/cart_screen.dart';
import 'package:pickle_pick/features/shop/presentation/screens/product_details_screen.dart';
import 'package:pickle_pick/features/shop/presentation/screens/purchase_history_screen.dart';
import 'package:pickle_pick/features/shop/presentation/screens/shop_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_router.gr.dart';

/// Redirects unauthenticated users to the login screen.
class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      resolver.next();
    } else {
      resolver.redirect(
        LoginRoute(
          onResult: (success) {
            resolver.next(success);
          },
        ),
      );
    }
  }
}

@AutoRouterConfig(replaceInRouteName: 'Page|Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        // Auth routes (public)
        AutoRoute(path: '/login', page: LoginRoute.page),
        AutoRoute(path: '/register', page: RegisterRoute.page),
        // Protected routes
        AutoRoute(
          path: '/',
          page: MainWrapperRoute.page,
          initial: true,
          // guards: [AuthGuard()],
          children: [
            AutoRoute(path: 'home', page: HomeRoute.page),
            AutoRoute(path: 'booking', page: BookingRoute.page),
            AutoRoute(path: 'shop', page: ShopRoute.page),
            AutoRoute(path: 'profile', page: ProfileRoute.page),
          ],
        ),
        AutoRoute(
          path: '/court/:courtId',
          page: CourtDetailRoute.page,
        ),
        AutoRoute(
          path: '/court/:courtId/slots',
          page: SlotPickerRoute.page,
        ),
        AutoRoute(path: '/product-details', page: ProductDetailsRoute.page),
        AutoRoute(path: '/cart', page: CartRoute.page),
        AutoRoute(
          path: '/booking-summary',
          page: BookingSummaryRoute.page,
          guards: [AuthGuard()],
        ),
        AutoRoute(
          path: '/booking-history',
          page: BookingHistoryRoute.page,
          guards: [AuthGuard()],
        ),
        AutoRoute(
          path: '/booking-detail',
          page: BookingDetailRoute.page,
          guards: [AuthGuard()],
        ),
        AutoRoute(
          path: '/purchase-history',
          page: PurchaseHistoryRoute.page,
          guards: [AuthGuard()],
        ),
        AutoRoute(
          path: '/edit-profile',
          page: EditProfileRoute.page,
          guards: [AuthGuard()],
        ),
      ];
}

final appRouterProvider = Provider((ref) => AppRouter());
