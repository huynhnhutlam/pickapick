import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/data/repositories/court_repository_impl.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_providers.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';

@RoutePage()
class BookingSummaryScreen extends ConsumerWidget {
  final String courtId;
  final String courtName;
  final String courtAddress;
  final String courtImage;
  final DateTime selectedDate;
  final String selectedSlot;
  final double price;

  const BookingSummaryScreen({
    super.key,
    required this.courtId,
    required this.courtName,
    required this.courtAddress,
    required this.courtImage,
    required this.selectedDate,
    required this.selectedSlot,
    required this.price,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đặt sân')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Court Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      courtImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.image, color: Colors.white24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courtName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              courtAddress,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Chi tiết lịch đặt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildDetailRow(Icons.calendar_today, 'Ngày', dateStr),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.access_time, 'Khung giờ', selectedSlot),
            const SizedBox(height: 12),
            Consumer(
              builder: (context, ref, child) {
                final courtAsync = ref.watch(courtDetailsProvider(courtId));
                final durationMin = courtAsync.value != null
                    ? (price / courtAsync.value!.pricePerHour * 60).round()
                    : 60;
                return _buildDetailRow(
                  Icons.timer_outlined,
                  'Thời lượng',
                  '$durationMin phút',
                );
              },
            ),

            const SizedBox(height: 32),
            const Text(
              'Thông tin thanh toán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final courtAsync = ref.watch(courtDetailsProvider(courtId));
                    final durationH = courtAsync.value != null
                        ? (price / courtAsync.value!.pricePerHour).round()
                        : 1;
                    return Text(
                      'Tiền sân ($durationH giờ)',
                      style: const TextStyle(color: Colors.white54),
                    );
                  },
                ),
                Text(price.toVND()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Phí dịch vụ',
                  style: TextStyle(color: Colors.white54),
                ),
                Text(0.toVND()),
              ],
            ),
            const Divider(height: 32, color: Colors.white12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  price.toVND(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            const Text(
              'Phương thức thanh toán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              context: context,
              icon: Icons.wallet,
              label: 'Ví PicklePay',
              color: Colors.blue,
              isSelected: true,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              context: context,
              icon: Icons.qr_code,
              label: 'Thanh toán VNPay',
              color: Colors.red,
              isSelected: false,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              context: context,
              icon: Icons.account_balance_wallet,
              label: 'Ví MoMo',
              color: Colors.pink,
              isSelected: false,
            ),
            const SizedBox(height: 60),

            NeonButton(
              label: 'XÁC NHẬN & THANH TOÁN',
              color: theme.primaryColor,
              onPressed: () async {
                // Show simulated payment processing dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: theme.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Đang xử lý thanh toán...',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

                // Simulate network/payment delay (e.g VNPay, MoMo)
                await Future.delayed(const Duration(seconds: 2));

                if (context.mounted) {
                  // Pop loading dialog
                  Navigator.of(context).pop();

                  try {
                    // 1. Add booking to state (and DB)
                    await ref.read(bookingProvider.notifier).addBooking(
                          BookedCourt(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            courtName: courtName,
                            courtAddress: courtAddress,
                            courtImage: courtImage,
                            date: selectedDate,
                            slot: selectedSlot,
                            price: price,
                          ),
                          courtId, // Passing courtId/facilityId
                        );

                    // 2. Success logic: Invalidate providers to refresh UI state
                    ref.invalidate(bookingProvider);
                    ref.invalidate(
                      bookedSlotsProvider(
                        (
                          facilityId: courtId,
                          date: selectedDate,
                        ),
                      ),
                    );

                    // Show success dialog
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: theme.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 80,
                                color: Colors.greenAccent,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Đặt sân thành công!',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Thanh toán đã được xác nhận. Chúc bạn có những giờ chơi vui vẻ!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white54),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: NeonButton(
                                  label: 'XEM LỊCH ĐẶT',
                                  color: theme.primaryColor,
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    context.router.replaceAll([
                                      const MainWrapperRoute(),
                                      const BookingHistoryRoute(),
                                    ]);
                                  },
                                  radius: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  context.router
                                      .replaceAll([const MainWrapperRoute()]);
                                },
                                child: const Text('VỀ TRANG CHỦ'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi đặt sân: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white38),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white54)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.5)
              : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          if (isSelected) Icon(Icons.check_circle, color: theme.primaryColor),
        ],
      ),
    );
  }
}
