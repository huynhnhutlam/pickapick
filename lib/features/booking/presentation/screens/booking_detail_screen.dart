import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/booking_providers.dart';

@RoutePage()
class BookingDetailScreen extends StatelessWidget {
  final BookedCourt booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đặt sân'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Mã vé check-in',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: QrImageView(
                      data: booking.id,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    booking.id.toUpperCase().substring(0, 8),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trạng thái',
                        style: TextStyle(color: Colors.white54),
                      ),
                      _StatusBadge(status: booking.status),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Details Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin sân',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Tên sân',
                    value: booking.courtName,
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày chơi',
                    value: dateFormat.format(booking.date),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Giờ chơi',
                    value: booking.slot,
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 24),
                  const Text(
                    'Thanh toán',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng tiền',
                        style: TextStyle(color: Colors.white54),
                      ),
                      Text(
                        booking.price.toVND(),
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            if (booking.status == 'Upcoming')
              Consumer(
                builder: (context, ref, child) => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hủy đặt sân'),
                          content: const Text(
                            'Bạn có chắc chắn muốn hủy lịch đặt sân này không?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'KHÔNG',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                try {
                                  await ref
                                      .read(bookingProvider.notifier)
                                      .cancelBooking(booking.id);
                                  if (context.mounted) {
                                    context.router.back();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Hủy thành công'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Lỗi: $e')),
                                    );
                                  }
                                }
                              },
                              child: const Text(
                                'CÓ',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Hủy đặt sân'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case 'Upcoming':
      case 'confirmed':
        color = Colors.green;
        text = 'Đã xác nhận';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Chờ xử lý';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'Đã hủy';
        break;
      case 'Completed':
      case 'completed':
        color = Colors.blue;
        text = 'Hoàn thành';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
