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

  // Booking
  static const bookingScreenScaffold =
      ValueKey<String>('booking_screen_scaffold');
  static const courtSearchField = ValueKey<String>('court_search_field');
  static const courtList = ValueKey<String>('court_list');
  static ValueKey<String> courtListItem(String id) =>
      ValueKey<String>('court_list_item_$id');
  static ValueKey<String> courtOrderButton(String id) =>
      ValueKey<String>('court_order_button_$id');

  // Court Detail
  static const courtDetailScaffold = ValueKey<String>('court_detail_scaffold');
  static const bookNowButton = ValueKey<String>('book_now_button');

  // Slot Picker
  static const slotPickerScaffold = ValueKey<String>('slot_picker_scaffold');
  static const continueToSummaryButton =
      ValueKey<String>('continue_to_summary_button');
  static ValueKey<String> slotItem(String slot) =>
      ValueKey<String>('slot_item_$slot');
  static ValueKey<String> subCourtItem(String id) =>
      ValueKey<String>('sub_court_item_$id');
  static ValueKey<String> dateItem(int index) =>
      ValueKey<String>('date_item_$index');

  // Booking Summary
  static const bookingSummaryScaffold =
      ValueKey<String>('booking_summary_scaffold');
  static const confirmBookingButton =
      ValueKey<String>('confirm_booking_button');

  // Booking Detail
  static const bookingDetailScaffold =
      ValueKey<String>('booking_detail_scaffold');
  static const bookingDetailBody = ValueKey<String>('booking_detail_body');
  static const bookingDetailQr = ValueKey<String>('booking_detail_qr');
  static const qrCodeImage = ValueKey<String>('qr_code_image');
  static const cancelBookingButton = ValueKey<String>('cancel_booking_button');
  static const cancelConfirmYes = ValueKey<String>('cancel_confirm_yes');
  static const cancelConfirmNo = ValueKey<String>('cancel_confirm_no');

  // Booking History
  static const bookingHistoryScaffold =
      ValueKey<String>('booking_history_scaffold');
  static const emptyBookingState = ValueKey<String>('empty_booking_state');
  static ValueKey<String> bookingHistoryItem(String id) =>
      ValueKey<String>('booking_history_item_$id');
  static ValueKey<String> bookingHistoryPrice(String id) =>
      ValueKey<String>('booking_history_price_$id');
  static ValueKey<String> bookingHistoryStatus(String id) =>
      ValueKey<String>('booking_history_status_$id');
}
