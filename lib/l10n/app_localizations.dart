import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Pickleball Hub'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome\nBack 👋'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to book courts and shop'**
  String get loginSubtitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @btnLogin.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get btnLogin;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get registerNow;

  /// No description provided for @msgLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get msgLoginFailed;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account 🏓'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the Pickleball community today'**
  String get registerSubtitle;

  /// No description provided for @labelFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get labelFullName;

  /// No description provided for @labelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get labelPhone;

  /// No description provided for @labelEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get labelEmail;

  /// No description provided for @labelPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get labelPassword;

  /// No description provided for @labelConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get labelConfirmPassword;

  /// No description provided for @btnRegister.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get btnRegister;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @valEmptyName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get valEmptyName;

  /// No description provided for @valEmptyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get valEmptyEmail;

  /// No description provided for @valInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get valInvalidEmail;

  /// No description provided for @valEmptyPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get valEmptyPassword;

  /// No description provided for @valShortPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get valShortPassword;

  /// No description provided for @valPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get valPasswordMismatch;

  /// No description provided for @valEmptyPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get valEmptyPhone;

  /// No description provided for @msgCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to confirm your account!'**
  String get msgCheckEmail;

  /// No description provided for @msgRegisterFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get msgRegisterFailed;

  /// No description provided for @myActivities.
  ///
  /// In en, this message translates to:
  /// **'My Activities'**
  String get myActivities;

  /// No description provided for @bookings.
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// No description provided for @noBookings.
  ///
  /// In en, this message translates to:
  /// **'No scheduled bookings'**
  String get noBookings;

  /// No description provided for @bookingsCount.
  ///
  /// In en, this message translates to:
  /// **'You have {count} bookings'**
  String bookingsCount(int count);

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @ordersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your orders'**
  String get ordersSubtitle;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Saved courts and products'**
  String get favoritesSubtitle;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your profile'**
  String get personalInfoSubtitle;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationsSubtitle;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get supportSubtitle;

  /// No description provided for @btnLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get btnLogout;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @hintDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get hintDisplayName;

  /// No description provided for @hintPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get hintPhone;

  /// No description provided for @btnSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get btnSaveChanges;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Update successful'**
  String get updateSuccess;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @greetingWithName.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}!'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @homeLocationDefault.
  ///
  /// In en, this message translates to:
  /// **'Hanoi City'**
  String get homeLocationDefault;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorGeneric;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoading(String error);

  /// No description provided for @valContinuousTime.
  ///
  /// In en, this message translates to:
  /// **'Please select continuous time slots.'**
  String get valContinuousTime;

  /// No description provided for @msgVoucherInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid voucher code.'**
  String get msgVoucherInvalid;

  /// No description provided for @msgOrderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create order'**
  String get msgOrderFailed;

  /// No description provided for @selectSubCourtFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a court first'**
  String get selectSubCourtFirst;

  /// No description provided for @noCourtFound.
  ///
  /// In en, this message translates to:
  /// **'No courts found.'**
  String get noCourtFound;

  /// No description provided for @noBookingsYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any bookings yet'**
  String get noBookingsYet;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartEmpty;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any orders yet'**
  String get noOrdersYet;

  /// No description provided for @bookingHistory.
  ///
  /// In en, this message translates to:
  /// **'Booking History'**
  String get bookingHistory;

  /// No description provided for @btnRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get btnRetry;

  /// No description provided for @checkInCode.
  ///
  /// In en, this message translates to:
  /// **'Check-in Code'**
  String get checkInCode;

  /// No description provided for @bookingDetail.
  ///
  /// In en, this message translates to:
  /// **'Booking Detail'**
  String get bookingDetail;

  /// No description provided for @labelStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get labelStatus;

  /// No description provided for @courtInfo.
  ///
  /// In en, this message translates to:
  /// **'Court Information'**
  String get courtInfo;

  /// No description provided for @labelCourtName.
  ///
  /// In en, this message translates to:
  /// **'Court Name'**
  String get labelCourtName;

  /// No description provided for @labelPlayDate.
  ///
  /// In en, this message translates to:
  /// **'Play Date'**
  String get labelPlayDate;

  /// No description provided for @labelPlayTime.
  ///
  /// In en, this message translates to:
  /// **'Play Time'**
  String get labelPlayTime;

  /// No description provided for @labelCourtAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get labelCourtAddress;

  /// No description provided for @paymentInfo.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentInfo;

  /// No description provided for @labelTotalMoney.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get labelTotalMoney;

  /// No description provided for @btnCancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get btnCancelBooking;

  /// No description provided for @cancelBookingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get cancelBookingTitle;

  /// No description provided for @cancelBookingContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking?'**
  String get cancelBookingContent;

  /// No description provided for @cancelPolicy24hBefore.
  ///
  /// In en, this message translates to:
  /// **'• Cancel before 24h: 100% refund to PicklePay wallet.'**
  String get cancelPolicy24hBefore;

  /// No description provided for @cancelPolicy24hWithin.
  ///
  /// In en, this message translates to:
  /// **'• Cancel within 24h: 50% cancellation fee.'**
  String get cancelPolicy24hWithin;

  /// No description provided for @btnNo.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get btnNo;

  /// No description provided for @btnYes.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get btnYes;

  /// No description provided for @msgCancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cancelled successfully'**
  String get msgCancelSuccess;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @btnShopNow.
  ///
  /// In en, this message translates to:
  /// **'Shop now'**
  String get btnShopNow;

  /// No description provided for @labelTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get labelTotal;

  /// No description provided for @labelPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment:'**
  String get labelPayment;

  /// No description provided for @btnCheckout.
  ///
  /// In en, this message translates to:
  /// **'CHECKOUT'**
  String get btnCheckout;

  /// No description provided for @processingPayment.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingPayment;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Success!'**
  String get paymentSuccess;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your order has been confirmed.'**
  String get orderConfirmed;

  /// No description provided for @btnContinueShopping.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE SHOPPING'**
  String get btnContinueShopping;

  /// No description provided for @purchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get purchaseHistory;

  /// No description provided for @labelOrderDate.
  ///
  /// In en, this message translates to:
  /// **'Order date: {date}'**
  String labelOrderDate(String date);

  /// No description provided for @labelQuantityShort.
  ///
  /// In en, this message translates to:
  /// **'Qty: {count}'**
  String labelQuantityShort(int count);

  /// No description provided for @shopSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search equipment, accessories...'**
  String get shopSearchHint;

  /// No description provided for @shopCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get shopCategoryAll;

  /// No description provided for @courtList.
  ///
  /// In en, this message translates to:
  /// **'Court List'**
  String get courtList;

  /// No description provided for @courtSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or address...'**
  String get courtSearchHint;

  /// No description provided for @perHour.
  ///
  /// In en, this message translates to:
  /// **'/hour'**
  String get perHour;

  /// No description provided for @orderNow.
  ///
  /// In en, this message translates to:
  /// **'Order Now'**
  String get orderNow;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @noSubCourts.
  ///
  /// In en, this message translates to:
  /// **'No sub-courts available.'**
  String get noSubCourts;

  /// No description provided for @selectTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Select Time Slot'**
  String get selectTimeHint;

  /// No description provided for @statusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusAvailable;

  /// No description provided for @statusBooked.
  ///
  /// In en, this message translates to:
  /// **'Booked'**
  String get statusBooked;

  /// No description provided for @statusSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get statusSelected;

  /// No description provided for @noOpeningHours.
  ///
  /// In en, this message translates to:
  /// **'No opening hours available for this court.'**
  String get noOpeningHours;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total Duration'**
  String get totalDuration;

  /// No description provided for @labelDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get labelDay;

  /// No description provided for @btnConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM BOOKING'**
  String get btnConfirmBooking;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String hoursShort(String count);

  /// No description provided for @bookingSummary.
  ///
  /// In en, this message translates to:
  /// **'Booking Summary'**
  String get bookingSummary;

  /// No description provided for @bookingDetailSection.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get bookingDetailSection;

  /// No description provided for @labelTimeSlot.
  ///
  /// In en, this message translates to:
  /// **'Time Slot'**
  String get labelTimeSlot;

  /// No description provided for @paymentMethodSection.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodSection;

  /// No description provided for @btnConfirmAndPay.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM & PAY'**
  String get btnConfirmAndPay;

  /// No description provided for @msgBookingSuccess.
  ///
  /// In en, this message translates to:
  /// **'Booking Successful!'**
  String get msgBookingSuccess;

  /// No description provided for @msgBookingSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your court has been reserved.'**
  String get msgBookingSuccessSubtitle;

  /// No description provided for @btnViewBooking.
  ///
  /// In en, this message translates to:
  /// **'VIEW BOOKING'**
  String get btnViewBooking;

  /// No description provided for @equipmentRentalSection.
  ///
  /// In en, this message translates to:
  /// **'Equipment Rental'**
  String get equipmentRentalSection;

  /// No description provided for @voucherSection.
  ///
  /// In en, this message translates to:
  /// **'Voucher'**
  String get voucherSection;

  /// No description provided for @voucherHint.
  ///
  /// In en, this message translates to:
  /// **'Enter voucher code'**
  String get voucherHint;

  /// No description provided for @btnApplyVoucher.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get btnApplyVoucher;

  /// No description provided for @msgVoucherSuccess.
  ///
  /// In en, this message translates to:
  /// **'Voucher applied successfully!'**
  String get msgVoucherSuccess;

  /// No description provided for @paymentInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get paymentInfoSection;

  /// No description provided for @courtTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Court Price'**
  String get courtTotalLabel;

  /// No description provided for @equipmentTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Equipment Rental'**
  String get equipmentTotalLabel;

  /// No description provided for @labelVoucher.
  ///
  /// In en, this message translates to:
  /// **'Voucher ({code})'**
  String labelVoucher(String code);

  /// No description provided for @sectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get sectionDescription;

  /// No description provided for @sectionAmenities.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get sectionAmenities;

  /// No description provided for @sectionRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get sectionRules;

  /// No description provided for @sectionLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get sectionLocation;

  /// No description provided for @sectionReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get sectionReviews;

  /// No description provided for @startingFrom.
  ///
  /// In en, this message translates to:
  /// **'Starting from'**
  String get startingFrom;

  /// No description provided for @mapUpdating.
  ///
  /// In en, this message translates to:
  /// **'Map updating...'**
  String get mapUpdating;

  /// No description provided for @btnContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get btnContinue;

  /// No description provided for @reviewsCount.
  ///
  /// In en, this message translates to:
  /// **'Reviews ({count})'**
  String reviewsCount(int count);

  /// No description provided for @actionNearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get actionNearby;

  /// No description provided for @actionHotHours.
  ///
  /// In en, this message translates to:
  /// **'Hot Hours'**
  String get actionHotHours;

  /// No description provided for @actionVouchers.
  ///
  /// In en, this message translates to:
  /// **'Vouchers'**
  String get actionVouchers;

  /// No description provided for @actionVip.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get actionVip;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search pickleball courts...'**
  String get homeSearchHint;

  /// No description provided for @featuredCourtsSection.
  ///
  /// In en, this message translates to:
  /// **'Featured Courts'**
  String get featuredCourtsSection;

  /// No description provided for @featuredProductsSection.
  ///
  /// In en, this message translates to:
  /// **'Premium Equipment'**
  String get featuredProductsSection;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @bannerAction.
  ///
  /// In en, this message translates to:
  /// **'EXPLORE NOW'**
  String get bannerAction;

  /// No description provided for @featureUnderDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature under development'**
  String get featureUnderDevelopment;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageVi.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get languageVi;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
