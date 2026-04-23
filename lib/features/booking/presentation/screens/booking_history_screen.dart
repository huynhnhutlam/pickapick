import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/enum/enum.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_providers.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';

@RoutePage()
class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  // Status color is now derived directly from the BookingStatus enum.
  Color _getStatusColor(BookingStatus status, ThemeData theme) {
    if (status == BookingStatus.upcoming) return theme.primaryColor;
    return status.color;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingProvider);
    final theme = Theme.of(context);

    return Scaffold(
      key: WidgetKeys.bookingHistoryScaffold,
      appBar: AppBar(
        title: const Text(AppStrings.bookingHistoryTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(bookingProvider),
          ),
        ],
      ),
      body: bookings.when(
        data: (data) {
          if (data.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(bookingProvider),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const Center(
                    child: Column(
                      key: WidgetKeys.emptyBookingState,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: AppSizes.iconXXL,
                          color: Colors.white10,
                        ),
                        SizedBox(height: AppSizes.p16),
                        Text(
                          AppStrings.noBookingsYet,
                          style: TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(bookingProvider),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.p20),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final booking = data[index];
                final statusColor = _getStatusColor(booking.status, theme);
                return GestureDetector(
                  key: WidgetKeys.bookingHistoryItem(booking.id),
                  onTap: () =>
                      context.router.push(BookingDetailRoute(booking: booking)),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.p16),
                    padding: const EdgeInsets.all(AppSizes.p16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(AppSizes.r20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.r12),
                          child: Image.network(
                            booking.courtImage,
                            width: AppSizes.dateItemWidth,
                            height: AppSizes.dateItemWidth,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.image,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.p16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.courtName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizes.bodyLarge,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p4),
                              Text(
                                '${DateFormat('dd/MM/yyyy').format(booking.date)} • ${booking.slot}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: AppSizes.labelMedium,
                                ),
                              ),
                              const SizedBox(height: AppSizes.p4),
                              if (booking.createdAt != null)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 11,
                                      color: Colors.white24,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Đặt lúc ${DateFormat('HH:mm dd/MM/yyyy').format(booking.createdAt!.toLocal())}',
                                      style: const TextStyle(
                                        color: Colors.white24,
                                        fontSize: AppSizes.labelTiny,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: AppSizes.p8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.p8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(AppSizes.r4),
                                ),
                                child: Text(
                                  booking.status.label.toUpperCase(),
                                  key: WidgetKeys.bookingHistoryStatus(
                                    booking.id,
                                  ),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: AppSizes.labelTiny,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.p12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              booking.price.toVND(),
                              key: WidgetKeys.bookingHistoryPrice(booking.id),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSizes.p4),
                            Text(
                              '#PB${booking.id.substring(0, 5).toUpperCase()}',
                              style: const TextStyle(
                                color: Colors.white24,
                                fontSize: AppSizes.labelSmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${AppStrings.errorLoading}$error'),
              const SizedBox(height: AppSizes.p16),
              ElevatedButton(
                onPressed: () => ref.invalidate(bookingProvider),
                child: const Text(AppStrings.btnRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
