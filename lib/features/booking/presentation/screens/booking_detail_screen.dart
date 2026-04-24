import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/enum/enum.dart';
import '../../domain/entities/booked_court.dart';
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
      key: WidgetKeys.bookingDetailScaffold,
      appBar: AppBar(
        title: Text(context.l10n.bookingDetail),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        key: WidgetKeys.bookingDetailBody,
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          children: [
            // ─── QR / Check-in Card ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSizes.p20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppSizes.r24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    context.l10n.checkInCode,
                    style: TextStyle(
                      fontSize: AppSizes.bodyLarge,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p20),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppSizes.r20),
                    ),
                    child: QrImageView(
                      key: WidgetKeys.qrCodeImage,
                      data: booking.id,
                      version: QrVersions.auto,
                      size: AppSizes.qrSize,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Text(
                    booking.id.toUpperCase().substring(0, 8),
                    style: const TextStyle(
                      fontSize: AppSizes.titleLarge,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: AppSizes.p16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.labelStatus,
                        style: TextStyle(color: Colors.white54),
                      ),
                      _StatusBadge(status: booking.status),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.p24),

            // ─── Details Card ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSizes.p24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppSizes.r24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.courtInfo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.titleLarge,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p20),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: context.l10n.labelCourtName,
                    value: booking.courtName,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: context.l10n.labelPlayDate,
                    value: dateFormat.format(booking.date),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  _DetailRow(
                    icon: Icons.access_time,
                    label: context.l10n.labelPlayTime,
                    value: booking.slot,
                  ),
                  const SizedBox(height: AppSizes.p16),
                  _DetailRow(
                    icon: Icons.location_city_outlined,
                    label: context.l10n.labelCourtAddress,
                    value: booking.courtAddress,
                  ),
                  const SizedBox(height: AppSizes.p24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: AppSizes.p24),
                  Text(
                    context.l10n.paymentInfo,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizes.titleLarge,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.labelTotalMoney,
                        style: TextStyle(color: Colors.white54),
                      ),
                      Text(
                        booking.price.toVND(),
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: AppSizes.h3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.p32),

            // ─── Cancel Button (Upcoming only) ─────────────────────────────
            if (booking.status == BookingStatus.upcoming)
              Consumer(
                builder: (context, ref, child) => SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _CancelDialog(
                          bookingId: booking.id,
                          notifier: ref.read(bookingProvider.notifier),
                        ),
                      );
                    },
                    key: WidgetKeys.cancelBookingButton,
                    icon: const Icon(Icons.cancel_outlined),
                    label: Text(context.l10n.btnCancelBooking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r16),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppSizes.bottomNavSpacing),
          ],
        ),
      ),
    );
  }
}

/// Extracted cancel confirmation dialog to keep the main screen widget slim.
class _CancelDialog extends StatelessWidget {
  final String bookingId;
  final Booking notifier;

  const _CancelDialog({required this.bookingId, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.cancelBookingTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.cancelBookingContent),
          SizedBox(height: AppSizes.p12),
          Text(
            context.l10n.cancelPolicy24hBefore,
            style: TextStyle(
              fontSize: AppSizes.labelSmall,
              color: Colors.greenAccent,
            ),
          ),
          Text(
            context.l10n.cancelPolicy24hWithin,
            style: TextStyle(
              fontSize: AppSizes.labelSmall,
              color: Colors.orangeAccent,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: WidgetKeys.cancelConfirmNo,
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.l10n.btnNo,
            style: TextStyle(color: Colors.white54),
          ),
        ),
        TextButton(
          key: WidgetKeys.cancelConfirmYes,
          onPressed: () async {
            Navigator.pop(context);
            try {
              await notifier.cancelBooking(bookingId);
              if (context.mounted) {
                context.router.back();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.msgCancelSuccess)),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.errorLoading(e.toString()))),
                );
              }
            }
          },
          child: Text(
            context.l10n.btnYes,
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
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
        Icon(
          icon,
          size: AppSizes.iconLarge,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: AppSizes.p12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: AppSizes.labelSmall,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.bodyLarge,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p12,
        vertical: AppSizes.p4 + 2,
      ),
      decoration: BoxDecoration(
        color: status.badgeColor,
        borderRadius: BorderRadius.circular(AppSizes.r10),
        border: Border.all(color: status.badgeBorderColor),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          color: status.color,
          fontSize: AppSizes.labelSmall,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
