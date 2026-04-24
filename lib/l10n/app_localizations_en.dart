// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pickleball Hub';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginTitle => 'Welcome\nBack 👋';

  @override
  String get loginSubtitle => 'Sign in to book courts and shop';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get btnLogin => 'LOGIN';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get registerNow => 'Register now';

  @override
  String get msgLoginFailed => 'Login failed';

  @override
  String get registerTitle => 'Create Account 🏓';

  @override
  String get registerSubtitle => 'Join the Pickleball community today';

  @override
  String get labelFullName => 'Full Name';

  @override
  String get labelPhone => 'Phone Number';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Password';

  @override
  String get labelConfirmPassword => 'Confirm Password';

  @override
  String get btnRegister => 'REGISTER';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get valEmptyName => 'Please enter your name';

  @override
  String get valEmptyEmail => 'Please enter your email';

  @override
  String get valInvalidEmail => 'Invalid email';

  @override
  String get valEmptyPassword => 'Please enter your password';

  @override
  String get valShortPassword => 'Password must be at least 6 characters';

  @override
  String get valPasswordMismatch => 'Passwords do not match';

  @override
  String get valEmptyPhone => 'Please enter your phone number';

  @override
  String get msgCheckEmail =>
      'Please check your email to confirm your account!';

  @override
  String get msgRegisterFailed => 'Registration failed';

  @override
  String get myActivities => 'My Activities';

  @override
  String get bookings => 'Bookings';

  @override
  String get noBookings => 'No scheduled bookings';

  @override
  String bookingsCount(int count) {
    return 'You have $count bookings';
  }

  @override
  String get orders => 'Orders';

  @override
  String get ordersSubtitle => 'Track your orders';

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesSubtitle => 'Saved courts and products';

  @override
  String get account => 'Account';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get personalInfoSubtitle => 'Update your profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Notification settings';

  @override
  String get support => 'Support';

  @override
  String get supportSubtitle => 'Contact us';

  @override
  String get btnLogout => 'Logout';

  @override
  String get guest => 'Guest';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get displayName => 'Display Name';

  @override
  String get hintDisplayName => 'Enter your name';

  @override
  String get hintPhone => 'Enter phone number';

  @override
  String get btnSaveChanges => 'SAVE CHANGES';

  @override
  String get updateSuccess => 'Update successful';

  @override
  String get error => 'Error';

  @override
  String get home => 'Home';

  @override
  String get shop => 'Shop';

  @override
  String get profileTab => 'Profile';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name!';
  }

  @override
  String get homeLocationDefault => 'Hanoi City';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String errorLoading(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get valContinuousTime => 'Please select continuous time slots.';

  @override
  String get msgVoucherInvalid => 'Invalid voucher code.';

  @override
  String get msgOrderFailed => 'Failed to create order';

  @override
  String get selectSubCourtFirst => 'Please select a court first';

  @override
  String get noCourtFound => 'No courts found.';

  @override
  String get noBookingsYet => 'You don\'t have any bookings yet';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get noOrdersYet => 'You don\'t have any orders yet';

  @override
  String get bookingHistory => 'Booking History';

  @override
  String get btnRetry => 'Retry';

  @override
  String get checkInCode => 'Check-in Code';

  @override
  String get bookingDetail => 'Booking Detail';

  @override
  String get labelStatus => 'Status';

  @override
  String get courtInfo => 'Court Information';

  @override
  String get labelCourtName => 'Court Name';

  @override
  String get labelPlayDate => 'Play Date';

  @override
  String get labelPlayTime => 'Play Time';

  @override
  String get labelCourtAddress => 'Address';

  @override
  String get paymentInfo => 'Payment';

  @override
  String get labelTotalMoney => 'Total';

  @override
  String get btnCancelBooking => 'Cancel Booking';

  @override
  String get cancelBookingTitle => 'Cancel Booking';

  @override
  String get cancelBookingContent =>
      'Are you sure you want to cancel this booking?';

  @override
  String get cancelPolicy24hBefore =>
      '• Cancel before 24h: 100% refund to PicklePay wallet.';

  @override
  String get cancelPolicy24hWithin =>
      '• Cancel within 24h: 50% cancellation fee.';

  @override
  String get btnNo => 'NO';

  @override
  String get btnYes => 'YES';

  @override
  String get msgCancelSuccess => 'Cancelled successfully';

  @override
  String get cartTitle => 'Cart';

  @override
  String get btnShopNow => 'SHOP NOW';

  @override
  String get labelTotal => 'Total';

  @override
  String get labelPayment => 'Payment:';

  @override
  String get btnCheckout => 'CHECKOUT';

  @override
  String get processingPayment => 'Processing payment...';

  @override
  String get paymentSuccess => 'Payment Success!';

  @override
  String get orderConfirmed => 'Your order has been confirmed.';

  @override
  String get btnContinueShopping => 'CONTINUE SHOPPING';

  @override
  String get purchaseHistory => 'Purchase History';

  @override
  String labelOrderDate(String date) {
    return 'Order date: $date';
  }

  @override
  String labelQuantityShort(int count) {
    return 'Qty: $count';
  }

  @override
  String get shopSearchHint => 'Search equipment, accessories...';

  @override
  String get shopCategoryAll => 'All';

  @override
  String get courtList => 'Court List';

  @override
  String get courtSearchHint => 'Search by name or address...';

  @override
  String get perHour => '/hour';

  @override
  String get orderNow => 'Order Now';

  @override
  String get selectTime => 'Select Time';

  @override
  String get noSubCourts => 'No sub-courts available.';

  @override
  String get selectTimeHint => 'Select Time Slot';

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusBooked => 'Booked';

  @override
  String get statusSelected => 'Selected';

  @override
  String get noOpeningHours => 'No opening hours available for this court.';

  @override
  String get totalDuration => 'Total Duration';

  @override
  String get labelDay => 'Day';

  @override
  String get btnConfirmBooking => 'CONFIRM BOOKING';

  @override
  String hoursShort(String count) {
    return '${count}h';
  }

  @override
  String get bookingSummary => 'Booking Summary';

  @override
  String get bookingDetailSection => 'Booking Details';

  @override
  String get labelTimeSlot => 'Time Slot';

  @override
  String get paymentMethodSection => 'Payment Method';

  @override
  String get btnConfirmAndPay => 'CONFIRM & PAY';

  @override
  String get msgBookingSuccess => 'Booking Successful!';

  @override
  String get msgBookingSuccessSubtitle => 'Your court has been reserved.';

  @override
  String get btnViewBooking => 'VIEW BOOKING';

  @override
  String get equipmentRentalSection => 'Equipment Rental';

  @override
  String get voucherSection => 'Voucher';

  @override
  String get voucherHint => 'Enter voucher code';

  @override
  String get btnApplyVoucher => 'APPLY';

  @override
  String get msgVoucherSuccess => 'Voucher applied successfully!';

  @override
  String get paymentInfoSection => 'Payment Information';

  @override
  String get courtTotalLabel => 'Court Price';

  @override
  String get equipmentTotalLabel => 'Equipment Rental';

  @override
  String labelVoucher(String code) {
    return 'Voucher ($code)';
  }

  @override
  String get sectionDescription => 'Description';

  @override
  String get sectionAmenities => 'Amenities';

  @override
  String get sectionRules => 'Rules';

  @override
  String get sectionLocation => 'Location';

  @override
  String get sectionReviews => 'Reviews';

  @override
  String get startingFrom => 'Starting from';

  @override
  String get mapUpdating => 'Map updating...';

  @override
  String get btnContinue => 'CONTINUE';

  @override
  String reviewsCount(int count) {
    return 'Reviews ($count)';
  }

  @override
  String get actionNearby => 'Nearby';

  @override
  String get actionHotHours => 'Hot Hours';

  @override
  String get actionVouchers => 'Vouchers';

  @override
  String get actionVip => 'VIP';

  @override
  String get homeSearchHint => 'Search pickleball courts...';

  @override
  String get featuredCourtsSection => 'Featured Courts';

  @override
  String get featuredProductsSection => 'Premium Equipment';

  @override
  String get seeAll => 'See all';

  @override
  String get bannerAction => 'EXPLORE NOW';
}
