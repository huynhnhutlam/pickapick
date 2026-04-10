import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_summary_riverpod.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'booking_price_row.dart';

class PaymentSummarySection extends ConsumerWidget {
  final double basePrice;

  const PaymentSummarySection({
    super.key,
    required this.basePrice,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Lắng nghe các giá trị cụ thể để tối ưu rebuild
    final equipmentPrice = ref.watch(equipmentTotalPriceProvider);
    final totalPrice =
        ref.watch(totalBookingPriceProvider(basePrice: basePrice));

    // Chỉ lắng nghe các thuộc tính voucher cần thiết
    final isVoucherApplied = ref.watch(
      bookingSummaryProvider.select((s) => s.isVoucherApplied),
    );
    final voucherCode = ref.watch(
      bookingSummaryProvider.select((s) => s.voucherCode),
    );
    final discountAmount = ref.watch(
      bookingSummaryProvider.select((s) => s.discountAmount),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.paymentInfoSection,
          style: TextStyle(
            fontSize: AppSizes.titleLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.p16),
        BookingPriceRow(
          label: AppStrings.courtTotalLabel,
          amount: basePrice,
        ),
        if (equipmentPrice > 0)
          BookingPriceRow(
            label: AppStrings.equipmentTotalLabel,
            amount: equipmentPrice,
          ),
        if (isVoucherApplied)
          BookingPriceRow(
            label: 'Mã giảm giá ($voucherCode)',
            amount: -discountAmount,
            color: Colors.greenAccent,
          ),
        const Divider(height: AppSizes.p32, color: Colors.white12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppStrings.totalAmount,
              style: TextStyle(
                fontSize: AppSizes.bodyLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              totalPrice.toVND(),
              style: TextStyle(
                fontSize: AppSizes.h4,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
