import 'dart:developer' as developer;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';

import '../widgets/featured_courts.dart';
import '../widgets/featured_products.dart';
import '../widgets/home_banner.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/quick_actions_section.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    developer.log('HomeScreen built', name: 'UI');

    return const Scaffold(
      key: WidgetKeys.homeScreenScaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          key: WidgetKeys.homeScrollView,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(key: WidgetKeys.homeHeader),
              HomeSearchBar(key: WidgetKeys.homeSearchBar),
              HomeBanner(key: WidgetKeys.homeBanner),
              QuickActionsSection(key: WidgetKeys.quickActionsSection),
              FeaturedCourts(key: WidgetKeys.featuredCourts),
              FeaturedProducts(key: WidgetKeys.featuredProducts),
              SizedBox(height: AppSizes.bottomNavSpacing),
            ],
          ),
        ),
      ),
    );
  }
}
