import 'package:intl/intl.dart';

extension PriceFormatting on num {
  String toVND() {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
    ).format(this);
  }
}
