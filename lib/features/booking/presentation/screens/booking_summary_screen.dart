import 'dart:developer' as developer;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_summary_riverpod.dart';
import 'package:pickle_pick/features/booking/presentation/screens/widgets/equipment_section.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';

import '../../../../core/enum/enum.dart';
import 'widgets/booking_detail_row.dart';
import 'widgets/court_info_card.dart';
import 'widgets/item_payment_option.dart';
import 'widgets/payment_summary_section.dart';
import 'widgets/voucher_section.dart';

@RoutePage()
class BookingSummaryScreen extends ConsumerWidget {
  final String facilityId;
  final String courtId;
  final String courtName;
  final String courtAddress;
  final String courtImage;
  final DateTime selectedDate;
  final String selectedSlot;
  final double price;

  const BookingSummaryScreen({
    super.key,
    required this.facilityId,
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
      key: WidgetKeys.bookingSummaryScaffold,
      appBar: AppBar(
        title: const Text(AppStrings.bookingSummaryTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CourtInfoCard(
              image: courtImage,
              name: courtName,
              address: courtAddress,
            ),
            const SizedBox(height: AppSizes.p32),
            const Text(
              AppStrings.bookingDetailSection,
              style: TextStyle(
                fontSize: AppSizes.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            BookingDetailRow(
              icon: Icons.calendar_today,
              label: AppStrings.labelDay,
              value: dateStr,
            ),
            const SizedBox(height: AppSizes.p12),
            BookingDetailRow(
              icon: Icons.access_time,
              label: AppStrings.labelTimeSlot,
              value: selectedSlot,
            ),
            const SizedBox(height: AppSizes.p32),
            const EquipmentSection(),
            const SizedBox(height: AppSizes.p32),
            const VoucherSection(),
            const SizedBox(height: AppSizes.p32),
            PaymentSummarySection(basePrice: price),
            const SizedBox(height: AppSizes.p48),
            const Text(
              AppStrings.paymentMethodSection,
              style: TextStyle(
                fontSize: AppSizes.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            ...PaymentMethod.values.map(
              (method) => Consumer(
                builder: (context, ref, child) {
                  final isSelected = ref.watch(
                    bookingSummaryProvider
                        .select((s) => s.selectedPaymentMethod == method),
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.p12),
                    child: ItemPaymentOption(
                      icon: method.icon,
                      label: method.label,
                      color: method.color,
                      isSelected: isSelected,
                      onTap: () => ref
                          .read(bookingSummaryProvider.notifier)
                          .setPaymentMethod(method),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.p60),
            Consumer(
              builder: (context, ref, child) {
                final isProcessing = ref.watch(
                  bookingSummaryProvider.select((s) => s.isProcessing),
                );

                return NeonButton(
                  key: WidgetKeys.confirmBookingButton,
                  label: AppStrings.btnConfirmAndPay,
                  isLoading: isProcessing,
                  color: theme.primaryColor,
                  onPressed: () => _processPayment(context, ref),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);

    try {
      await ref.read(bookingSummaryProvider.notifier).confirmBooking(
            facilityId: facilityId,
            courtId: courtId,
            courtName: courtName,
            courtAddress: courtAddress,
            courtImage: courtImage,
            selectedDate: selectedDate,
            selectedSlot: selectedSlot,
            basePrice: price,
          );

      if (!context.mounted) return;
      _showSuccessDialog(context, theme);
    } catch (e) {
      developer.log('Booking error', error: e, name: 'BookingSummary');
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorLoading}$e')),
      );
    }
  }

  void _showSuccessDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: AppSizes.iconHero,
              color: Colors.greenAccent,
            ),
            const SizedBox(height: AppSizes.p24),
            const Text(
              AppStrings.msgBookingSuccess,
              style: TextStyle(
                fontSize: AppSizes.h5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p12),
            const Text(
              AppStrings.msgBookingSuccessSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: AppSizes.p32),
            SizedBox(
              width: double.infinity,
              child: NeonButton(
                label: AppStrings.btnViewBooking,
                color: theme.primaryColor,
                onPressed: () {
                  Navigator.pop(context);
                  context.router.replaceAll([
                    const MainWrapperRoute(),
                    const BookingHistoryRoute(),
                  ]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
