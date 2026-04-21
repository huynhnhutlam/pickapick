import 'package:flutter/material.dart';

class WidgetKeys {
  // Home Screen
  static const homeScreenScaffold = ValueKey<String>('home_screen_scaffold');
  static const homeHeader = ValueKey<String>('home_header');
  static const homeSearchBar = ValueKey<String>('home_search_bar');
  static const homeBanner = ValueKey<String>('home_banner');
  static const quickActionsSection = ValueKey<String>('quick_actions_section');
  static const featuredCourts = ValueKey<String>('featured_courts');
  static const featuredCourtsSeeAll =
      ValueKey<String>('featured_courts_see_all');

  static const featuredProducts = ValueKey<String>('featured_products');
  static const featuredProductsSeeAll =
      ValueKey<String>('featured_products_see_all');

  static const homeScrollView = ValueKey<String>('home_scroll_view');

  // Home Banner
  static const homeBannerPageView = ValueKey<String>('home_banner_page_view');

  // Dynamic keys
  static ValueKey<String> homeBannerItem(int index) =>
      ValueKey<String>('home_banner_item_$index');

  static ValueKey<String> quickActionItem(String actionName) =>
      ValueKey<String>('quick_action_$actionName');

  static ValueKey<String> featuredCourtItem(String id) =>
      ValueKey<String>('featured_court_item_$id');

  static ValueKey<String> featuredProductItem(String id) =>
      ValueKey<String>('featured_product_item_$id');

  static ValueKey<String> bannerActionButton(int index) =>
      ValueKey<String>('banner_action_button_$index');
}
