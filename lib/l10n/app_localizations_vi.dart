// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Pickleball Hub';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get loginTitle => 'Chào mừng\ntrở lại 👋';

  @override
  String get loginSubtitle => 'Đăng nhập để đặt sân và mua sắm';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get btnLogin => 'ĐĂNG NHẬP';

  @override
  String get dontHaveAccount => 'Chưa có tài khoản? ';

  @override
  String get registerNow => 'Đăng ký ngay';

  @override
  String get msgLoginFailed => 'Đăng nhập thất bại';

  @override
  String get registerTitle => 'Tạo tài khoản 🏓';

  @override
  String get registerSubtitle => 'Gia nhập cộng đồng Pickleball ngay hôm nay';

  @override
  String get labelFullName => 'Họ và tên';

  @override
  String get labelPhone => 'Số điện thoại';

  @override
  String get labelEmail => 'Email';

  @override
  String get labelPassword => 'Mật khẩu';

  @override
  String get labelConfirmPassword => 'Xác nhận mật khẩu';

  @override
  String get btnRegister => 'ĐĂNG KÝ';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản? ';

  @override
  String get valEmptyName => 'Vui lòng nhập tên';

  @override
  String get valEmptyEmail => 'Vui lòng nhập email';

  @override
  String get valInvalidEmail => 'Email không hợp lệ';

  @override
  String get valEmptyPassword => 'Vui lòng nhập mật khẩu';

  @override
  String get valShortPassword => 'Mật khẩu tối thiểu 6 ký tự';

  @override
  String get valPasswordMismatch => 'Mật khẩu không khớp';

  @override
  String get valEmptyPhone => 'Hãy nhập số điện thoại';

  @override
  String get msgCheckEmail => 'Vui lòng kiểm tra email để xác nhận tài khoản!';

  @override
  String get msgRegisterFailed => 'Đăng ký thất bại';

  @override
  String get myActivities => 'Hoạt động của tôi';

  @override
  String get bookings => 'Lịch đặt sân';

  @override
  String get noBookings => 'Chưa có lịch đặt';

  @override
  String bookingsCount(int count) {
    return 'Bạn có $count lịch đặt';
  }

  @override
  String get orders => 'Đơn mua hàng';

  @override
  String get ordersSubtitle => 'Theo dõi đơn hàng của bạn';

  @override
  String get favorites => 'Yêu thích';

  @override
  String get favoritesSubtitle => 'Sân và sản phẩm đã lưu';

  @override
  String get account => 'Tài khoản';

  @override
  String get personalInfo => 'Thông tin cá nhân';

  @override
  String get personalInfoSubtitle => 'Cập nhật thông tin của bạn';

  @override
  String get notifications => 'Thông báo';

  @override
  String get notificationsSubtitle => 'Cài đặt thông báo';

  @override
  String get support => 'Hỗ trợ';

  @override
  String get supportSubtitle => 'Liên hệ với chúng tôi';

  @override
  String get btnLogout => 'Đăng xuất';

  @override
  String get guest => 'Khách';

  @override
  String get editProfile => 'Chỉnh sửa thông tin';

  @override
  String get displayName => 'Tên hiển thị';

  @override
  String get hintDisplayName => 'Nhập tên của bạn';

  @override
  String get hintPhone => 'Nhập số điện thoại';

  @override
  String get btnSaveChanges => 'LƯU THAY ĐỔI';

  @override
  String get updateSuccess => 'Cập nhật thông tin thành công';

  @override
  String get error => 'Lỗi';

  @override
  String get home => 'Trang chủ';

  @override
  String get shop => 'Shop';

  @override
  String get profileTab => 'Tôi';

  @override
  String get goodMorning => 'Chào buổi sáng';

  @override
  String get goodAfternoon => 'Chào buổi chiều';

  @override
  String get goodEvening => 'Chào buổi tối';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name!';
  }

  @override
  String get homeLocationDefault => 'TP. Hà Nội';

  @override
  String get errorGeneric => 'Đã có lỗi xảy ra';

  @override
  String errorLoading(String error) {
    return 'Lỗi tải dữ liệu: $error';
  }

  @override
  String get valContinuousTime => 'Vui lòng chọn khung giờ liên tục.';

  @override
  String get msgVoucherInvalid => 'Mã giảm giá không hợp lệ.';

  @override
  String get msgOrderFailed => 'Tạo đơn hàng thất bại';

  @override
  String get selectSubCourtFirst => 'Vui lòng chọn sân con trước';

  @override
  String get noCourtFound => 'Không tìm thấy sân nào.';

  @override
  String get noBookingsYet => 'Bạn chưa có lịch đặt sân nào';

  @override
  String get noProductsFound => 'Không có sản phẩm nào';

  @override
  String get cartEmpty => 'Giỏ hàng trống';

  @override
  String get noOrdersYet => 'Bạn chưa có đơn hàng nào';

  @override
  String get bookingHistory => 'Lịch đặt sân';

  @override
  String get btnRetry => 'Thử lại';

  @override
  String get checkInCode => 'Mã vé check-in';

  @override
  String get bookingDetail => 'Chi tiết đặt sân';

  @override
  String get labelStatus => 'Trạng thái';

  @override
  String get courtInfo => 'Thông tin sân';

  @override
  String get labelCourtName => 'Tên sân';

  @override
  String get labelPlayDate => 'Ngày chơi';

  @override
  String get labelPlayTime => 'Giờ chơi';

  @override
  String get labelCourtAddress => 'Địa chỉ';

  @override
  String get paymentInfo => 'Thanh toán';

  @override
  String get labelTotalMoney => 'Tổng tiền';

  @override
  String get btnCancelBooking => 'Hủy đặt sân';

  @override
  String get cancelBookingTitle => 'Hủy đặt sân';

  @override
  String get cancelBookingContent =>
      'Bạn có chắc chắn muốn hủy đặt sân này không?';

  @override
  String get cancelPolicy24hBefore =>
      '• Hủy trước 24h: Hoàn tiền 100% về ví PicklePay.';

  @override
  String get cancelPolicy24hWithin => '• Hủy trong vòng 24h: Phí hủy sân 50%.';

  @override
  String get btnNo => 'KHÔNG';

  @override
  String get btnYes => 'CÓ';

  @override
  String get msgCancelSuccess => 'Hủy thành công';

  @override
  String get cartTitle => 'Giỏ hàng';

  @override
  String get btnShopNow => 'MUA SẮM NGAY';

  @override
  String get labelTotal => 'Tổng cộng';

  @override
  String get labelPayment => 'Thanh toán:';

  @override
  String get btnCheckout => 'THANH TOÁN';

  @override
  String get processingPayment => 'Đang xử lý thanh toán...';

  @override
  String get paymentSuccess => 'Thanh toán thành công!';

  @override
  String get orderConfirmed => 'Đơn hàng của bạn đã được ghi nhận.';

  @override
  String get btnContinueShopping => 'TIẾP TỤC MUA SẮM';

  @override
  String get purchaseHistory => 'Lịch sử mua hàng';

  @override
  String labelOrderDate(String date) {
    return 'Ngày đặt: $date';
  }

  @override
  String labelQuantityShort(int count) {
    return 'SL: $count';
  }

  @override
  String get shopSearchHint => 'Tìm kiếm dụng cụ, phụ kiện...';

  @override
  String get shopCategoryAll => 'Tất cả';

  @override
  String get courtList => 'Danh sách sân';

  @override
  String get courtSearchHint => 'Tìm theo tên hoặc địa chỉ...';

  @override
  String get perHour => '/giờ';

  @override
  String get orderNow => 'Đặt ngay';

  @override
  String get selectTime => 'Chọn giờ chơi';

  @override
  String get noSubCourts => 'Không có sân con nào.';

  @override
  String get selectTimeHint => 'Chọn khung giờ';

  @override
  String get statusAvailable => 'Còn trống';

  @override
  String get statusBooked => 'Đã đặt';

  @override
  String get statusSelected => 'Đang chọn';

  @override
  String get noOpeningHours => 'Chưa có thông tin giờ mở cửa cho sân này.';

  @override
  String get totalDuration => 'Tổng thời gian';

  @override
  String get labelDay => 'Ngày';

  @override
  String get btnConfirmBooking => 'XÁC NHẬN ĐẶT SÂN';

  @override
  String hoursShort(String count) {
    return '$count giờ';
  }

  @override
  String get bookingSummary => 'Xác nhận đặt sân';

  @override
  String get bookingDetailSection => 'Thông tin đặt sân';

  @override
  String get labelTimeSlot => 'Khung giờ';

  @override
  String get paymentMethodSection => 'Phương thức thanh toán';

  @override
  String get btnConfirmAndPay => 'XÁC NHẬN & THANH TOÁN';

  @override
  String get msgBookingSuccess => 'Đặt sân thành công!';

  @override
  String get msgBookingSuccessSubtitle => 'Sân của bạn đã được giữ chỗ.';

  @override
  String get btnViewBooking => 'XEM LỊCH ĐẶT';

  @override
  String get equipmentRentalSection => 'Thuê dụng cụ';

  @override
  String get voucherSection => 'Mã giảm giá';

  @override
  String get voucherHint => 'Nhập mã giảm giá';

  @override
  String get btnApplyVoucher => 'ÁP DỤNG';

  @override
  String get msgVoucherSuccess => 'Áp dụng mã thành công!';

  @override
  String get paymentInfoSection => 'Thông tin thanh toán';

  @override
  String get courtTotalLabel => 'Tiền sân';

  @override
  String get equipmentTotalLabel => 'Tiền thuê dụng cụ';

  @override
  String labelVoucher(String code) {
    return 'Mã giảm giá ($code)';
  }

  @override
  String get sectionDescription => 'Mô tả';

  @override
  String get sectionAmenities => 'Tiện ích';

  @override
  String get sectionRules => 'Quy định';

  @override
  String get sectionLocation => 'Vị trí';

  @override
  String get sectionReviews => 'Đánh giá';

  @override
  String get startingFrom => 'Chỉ từ';

  @override
  String get mapUpdating => 'Đang cập nhật bản đồ...';

  @override
  String get btnContinue => 'TIẾP TỤC';

  @override
  String reviewsCount(int count) {
    return 'Đánh giá ($count)';
  }

  @override
  String get actionNearby => 'Lân cận';

  @override
  String get actionHotHours => 'Giờ vàng';

  @override
  String get actionVouchers => 'Ưu đãi';

  @override
  String get actionVip => 'VIP Member';

  @override
  String get homeSearchHint => 'Tìm kiếm sân pickleball...';

  @override
  String get featuredCourtsSection => 'Sân nổi bật';

  @override
  String get featuredProductsSection => 'Dụng cụ cao cấp';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get bannerAction => 'KHÁM PHÁ NGAY';

  @override
  String get featureUnderDevelopment => 'Tính năng đang phát triển';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageEn => 'Tiếng Anh';

  @override
  String get languageVi => 'Tiếng Việt';
}
