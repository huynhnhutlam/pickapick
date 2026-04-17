/// Centralized string constants for the Pickle Pick application.
///
/// All UI text should reference constants defined here to ensure
/// consistency and ease of future localization.
class AppStrings {
  const AppStrings._();

  static const String appName = 'Pickle Pick';

  // ─── Home Screen ──────────────────────────────────────────────────────────
  static const String homeGreeting = 'Chào buổi sáng, Lam!';
  static const String homeLocationDefault = 'TP. Hà Nội';
  static const String homeSearchHint = 'Tìm sân hoặc sản phẩm...';

  // Banner
  static const String bannerPromoTitle = 'GIẢM 20% ĐẶT SÂN';
  static const String bannerPromoSubtitle =
      'Áp dụng cho khung giờ vàng 14:00 - 16:00';
  static const String bannerAction = 'ĐẶT NGAY';

  // Quick Actions
  static const String actionNearby = 'Sân gần bạn';
  static const String actionHotHours = 'Giờ hot';
  static const String actionVouchers = 'Vouchers';
  static const String actionVip = 'Hạng VIP';

  // Section Headers
  static const String sectionFeaturedCourts = 'Sân Pickleball nổi bật';
  static const String sectionNewProducts = 'Dụng cụ mới nhất';
  static const String seeAll = 'Xem tất cả';
  static const String shopNow = 'Shop ngay';

  // ─── Auth – Login ─────────────────────────────────────────────────────────
  static const String loginTitle = 'Chào mừng\ntrở lại 👋';
  static const String loginSubtitle = 'Đăng nhập để đặt sân và mua sắm';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String btnLogin = 'ĐĂNG NHẬP';
  static const String dontHaveAccount = 'Chưa có tài khoản? ';
  static const String registerNow = 'Đăng ký ngay';
  static const String msgLoginFailed = 'Đăng nhập thất bại';

  // ─── Auth – Register ──────────────────────────────────────────────────────
  static const String registerTitle = 'Tạo tài khoản 🏓';
  static const String registerSubtitle =
      'Gia nhập cộng đồng Pickleball ngay hôm nay';
  static const String labelFullName = 'Họ và tên';
  static const String labelPhone = 'Số điện thoại';
  static const String labelEmail = 'Email';
  static const String labelPassword = 'Mật khẩu';
  static const String labelConfirmPassword = 'Xác nhận mật khẩu';
  static const String btnRegister = 'ĐĂNG KÝ';
  static const String alreadyHaveAccount = 'Đã có tài khoản? ';
  static const String login = 'Đăng nhập';
  static const String btnSignIn = 'Đăng nhập';

  // ─── Validation ───────────────────────────────────────────────────────────
  static const String valEmptyName = 'Vui lòng nhập tên';
  static const String valEmptyEmail = 'Vui lòng nhập email';
  static const String valInvalidEmail = 'Email không hợp lệ';
  static const String valEmptyPassword = 'Vui lòng nhập mật khẩu';
  static const String valShortPassword = 'Mật khẩu tối thiểu 6 ký tự';
  static const String valPasswordMismatch = 'Mật khẩu không khớp';
  static const String valEmptyPhone = 'Hãy nhập số điện thoại';

  // ─── Feedback ─────────────────────────────────────────────────────────────
  static const String msgCheckEmail =
      'Vui lòng kiểm tra email để xác nhận tài khoản!';
  static const String msgRegisterFailed = 'Đăng ký thất bại';
  static const String msgUpdateSuccess = 'Cập nhật thông tin thành công';
  static const String msgCancelSuccess = 'Hủy thành công';
  static const String msgOrderFailed = 'Tạo đơn hàng thất bại';
  static const String msgProcessingPayment = 'Đang xử lý thanh toán...';
  static const String msgVoucherSuccess = 'Áp dụng mã giảm giá thành công!';
  static const String msgVoucherInvalid = 'Mã giảm giá không hợp lệ.';
  static const String msgBookingSuccess = 'Đặt sân thành công!';
  static const String msgBookingSuccessSubtitle =
      'Chúc bạn có những giờ chơi vui vẻ!';
  static const String msgPaymentSuccess = 'Thanh toán thành công!';
  static const String msgPaymentSuccessSubtitle =
      'Đơn hàng của bạn đã được ghi nhận.';
  static const String msgAddedToCart = 'Đã thêm';
  static const String msgAddedToCartSuffix = 'vào giỏ hàng';

  // ─── Court Detail ──────────────────────────────────────────────────────────
  static const String sectionDescription = 'Giới thiệu';
  static const String sectionAmenities = 'Tiện ích';
  static const String sectionRules = 'Quy định sân';
  static const String sectionLocation = 'Vị trí';
  static const String sectionReviews = 'Đánh giá';
  static const String mapUpdating = 'Bản đồ đang cập nhật';
  static const String startingFrom = 'Chỉ từ';
  static const String btnContinue = 'TIẾP TỤC';

  // ─── Court List ────────────────────────────────────────────────────────────
  static const String courtListTitle = 'Tìm sân Pickleball';
  static const String courtSearchHint = 'Tìm kiếm sân...';
  static const String noCourtFound = 'Không tìm thấy sân nào.';
  static const String courtListDetails = 'Chi tiết';
  static const String orderNow = 'Đặt ngay';
  static const String perHour = '/giờ';

  // ─── Booking – Slot Picker ────────────────────────────────────────────────
  static const String selectTime = 'Chọn giờ chơi';
  static const String selectSubCourtFirst = 'Vui lòng chọn sân con trước';
  static const String selectTimeHint = 'Chọn khung giờ (có thể chọn nhiều)';
  static const String statusAvailable = 'Trống';
  static const String statusBooked = 'Đã đặt/Hết giờ';
  static const String statusSelected = 'Đang chọn';
  static const String valContinuousTime = 'Vui lòng chọn khung giờ liên tục.';
  static const String btnConfirmBooking = 'XÁC NHẬN ĐẶT SÂN';

  // ─── Booking – Summary ────────────────────────────────────────────────────
  static const String bookingSummaryTitle = 'Xác nhận đặt sân';
  static const String bookingDetailSection = 'Chi tiết lịch đặt';
  static const String equipmentRentalSection = 'Thuê thêm dụng cụ';
  static const String voucherSection = 'Mã giảm giá (Court Voucher)';
  static const String voucherHint = 'Nhập mã giảm giá...';
  static const String btnApplyVoucher = 'Áp dụng';
  static const String paymentInfoSection = 'Thông tin thanh toán';
  static const String paymentMethodSection = 'Phương thức thanh toán';
  static const String courtTotalLabel = 'Tổng tiền sân (theo giờ)';
  static const String equipmentTotalLabel = 'Tiền thuê dụng cụ';
  static const String btnConfirmAndPay = 'XÁC NHẬN & THANH TOÁN';
  static const String btnViewBooking = 'XEM LỊCH ĐẶT';
  static const String paymentPicklePay = 'Ví PicklePay';
  static const String paymentMoMo = 'Ví MoMo';
  static const String paymentVnPay = 'VNPay';
  static const String labelDate = 'Ngày';
  static const String labelTimeSlot = 'Khung giờ';
  static const String totalDuration = 'Tổng cộng';
  static const String totalAmount = 'Tổng cộng';
  static const String labelDay = 'Ngày';
  static const String bookingSummary = 'Tóm tắt đặt sân';
  static const String payNow = 'Thanh toán ngay';

  // ─── Booking – History ────────────────────────────────────────────────────
  static const String bookingHistoryTitle = 'Lịch đặt sân';
  static const String noBookingsYet = 'Bạn chưa có lịch đặt sân nào';
  static const String statusUpcoming = 'Sắp tới';
  static const String statusPlayed = 'Đã chơi';
  static const String statusCancelled = 'Đã hủy';
  static const String btnRetry = 'Thử lại';

  // ─── Booking – Detail ─────────────────────────────────────────────────────
  static const String bookingDetailTitle = 'Chi tiết đặt sân';
  static const String checkInCode = 'Mã vé check-in';
  static const String courtInfoSection = 'Thông tin sân';
  static const String paymentSection = 'Thanh toán';
  static const String labelCourtName = 'Tên sân';
  static const String labelPlayDate = 'Ngày chơi';
  static const String labelPlayTime = 'Giờ chơi';
  static const String labelStatus = 'Trạng thái';
  static const String labelTotalMoney = 'Tổng tiền';
  static const String cancelBookingTitle = 'Hủy đặt sân';
  static const String cancelBookingContent =
      'Bạn có chắc chắn muốn hủy đặt sân này không?';
  static const String cancelPolicy24hBefore =
      '• Hủy trước 24h: Hoàn tiền 100% về ví PicklePay.';
  static const String cancelPolicy24hWithin =
      '• Hủy trong vòng 24h: Phí hủy sân 50%.';
  static const String btnNo = 'KHÔNG';
  static const String btnYes = 'CÓ';
  static const String btnCancelBooking = 'Hủy đặt sân';

  // ─── Profile ───────────────────────────────────────────────────────────────
  static const String myActivitiesSection = 'Hoạt động của tôi';
  static const String menuBookings = 'Lịch đặt sân';
  static const String menuBookingsNoSchedule = 'Chưa có lịch đặt';
  static const String menuBookingsCount = 'Bạn có';
  static const String menuBookingsCountSuffix = 'lịch đặt';
  static const String menuOrders = 'Đơn mua hàng';
  static const String menuOrdersSubtitle = 'Theo dõi đơn hàng của bạn';
  static const String menuFavorites = 'Yêu thích';
  static const String menuFavoritesSubtitle = 'Sân và sản phẩm đã lưu';
  static const String accountSection = 'Tài khoản';
  static const String menuPersonalInfo = 'Thông tin cá nhân';
  static const String menuPersonalInfoSubtitle = 'Cập nhật thông tin của bạn';
  static const String menuNotifications = 'Thông báo';
  static const String menuNotificationsSubtitle = 'Cài đặt thông báo';
  static const String menuSupport = 'Hỗ trợ';
  static const String menuSupportSubtitle = 'Liên hệ với chúng tôi';
  static const String btnLogout = 'Đăng xuất';
  static const String defaultUserName = 'Khách';

  // Edit Profile
  static const String editProfileTitle = 'Chỉnh sửa thông tin';
  static const String labelDisplayName = 'Tên hiển thị';
  static const String hintDisplayName = 'Nhập tên của bạn';
  static const String hintPhone = 'Nhập số điện thoại';
  static const String btnSaveChanges = 'LƯU THAY ĐỔI';

  // ─── Shop ──────────────────────────────────────────────────────────────────
  static const String shopTitle = 'Pickle Shop';
  static const String shopSearchHint = 'Tìm vợt, bóng, phụ kiện...';
  static const String shopCategoryAll = 'Tất cả';
  static const String noProductsFound = 'Không có sản phẩm nào';
  static const String btnAddToCart = 'THÊM VÀO GIỎ';
  static const String btnViewCart = 'XEM GIỎ';
  static const String productDescription = 'Mô tả sản phẩm';
  static const String productSpecs = 'Thông số kỹ thuật';
  static const String saleBadge = 'TIẾT KIỆM 20%';

  // Cart
  static const String cartTitle = 'Giỏ hàng';
  static const String cartEmpty = 'Giỏ hàng trống';
  static const String btnShopNow = 'MUA SẮM NGAY';
  static const String paymentLabel = 'Thanh toán:';
  static const String btnCheckout = 'THANH TOÁN';
  static const String btnContinueShopping = 'TIẾP TỤC MUA SẮM';

  // Purchase History
  static const String purchaseHistoryTitle = 'Lịch sử mua hàng';
  static const String noOrdersYet = 'Bạn chưa có đơn hàng nào';
  static const String btnShopMore = 'Mua sắm ngay';
  static const String labelOrderDate = 'Ngày đặt: ';
  static const String labelQuantity = 'SL: ';

  // ─── Common ────────────────────────────────────────────────────────────────
  static const String errorGeneric = 'Đã có lỗi xảy ra';
  static const String errorLoading = 'Lỗi tải dữ liệu: ';
  static const String btnBack = 'Quay lại';
}
