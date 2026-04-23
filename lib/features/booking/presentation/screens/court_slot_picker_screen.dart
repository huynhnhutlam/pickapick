import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/keys/app_keys.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/domain/entities/sub_court.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';

@RoutePage()
class SlotPickerScreen extends ConsumerStatefulWidget {
  final String courtId;
  final String? courtName;
  final String? courtAddress;
  final String? courtImage;

  const SlotPickerScreen({
    super.key,
    required this.courtId,
    this.courtName,
    this.courtAddress,
    this.courtImage,
  });

  @override
  ConsumerState<SlotPickerScreen> createState() => _SlotPickerScreenState();
}

class _SlotPickerScreenState extends ConsumerState<SlotPickerScreen> {
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  // Dynamic selection state
  final List<String> _selectedSlots = [];
  String? _selectedSubCourtId;

  void _onSlotTap(
    String slot,
    Set<String> bookedSlots,
    List<String> currentSlots,
  ) {
    if (_isSlotInPast(slot)) return;
    if (_selectedSubCourtId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.selectSubCourtFirst)),
      );
      return;
    }
    setState(() {
      if (_selectedSlots.contains(slot)) {
        _selectedSlots.remove(slot);
      } else {
        _selectedSlots.add(slot);
      }
      _selectedSlots.sort();
    });
  }

  bool _isSlotInPast(String slot) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selectedDate.isAfter(today)) return false;
    if (selectedDate.isBefore(today)) return true;

    // It's today, compare time
    final parts = slot.split(' - ')[0].split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour < now.hour) return true;
    if (hour == now.hour && minute <= now.minute) return true;

    return false;
  }

  bool _isSelectionContinuous(List<String> currentSlots) {
    if (_selectedSlots.isEmpty) return false;
    if (_selectedSlots.length == 1) return true;

    final indices = _selectedSlots.map((s) => currentSlots.indexOf(s)).toList();
    indices.sort();

    for (int i = 0; i < indices.length - 1; i++) {
      if (indices[i + 1] - indices[i] != 1) return false;
    }
    return true;
  }

  String _getTimeRangeDisplay() {
    if (_selectedSlots.isEmpty) return '';
    _selectedSlots.sort();

    final start = _selectedSlots.first.split(' - ')[0];
    final end = _selectedSlots.last.split(' - ')[1];

    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subCourtsAsync = ref.watch(subCourtsProvider(widget.courtId));

    // Pre-watch court details so facility name is available when confirm is pressed
    final courtDetailsAsync = ref.watch(courtDetailsProvider(widget.courtId));

    // Watch available slots from DB
    final availableSlotsAsync = _selectedSubCourtId != null
        ? ref.watch(
            availableSlotsProvider(
              courtId: _selectedSubCourtId!,
              date: _selectedDate,
            ),
          )
        : const AsyncValue<List<String>>.data([]);

    final currentSlots = availableSlotsAsync.value ?? [];

    // Automatically select the first sub-court if none is selected yet
    if (subCourtsAsync.value != null &&
        subCourtsAsync.value!.isNotEmpty &&
        _selectedSubCourtId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedSubCourtId = subCourtsAsync.value!.first.id;
          });
        }
      });
    }

    final bookedSlotsAsync = _selectedSubCourtId != null
        ? ref.watch(
            bookedSlotsProvider(
              courtId: _selectedSubCourtId!,
              date: _selectedDate,
            ),
          )
        : const AsyncValue<List<String>>.data([]);

    final isAvailabilityLoading = bookedSlotsAsync.isLoading;

    SubCourt? selectedSubCourt;
    if (subCourtsAsync.value != null && _selectedSubCourtId != null) {
      selectedSubCourt = subCourtsAsync.value!.firstWhere(
        (c) => c.id == _selectedSubCourtId,
        orElse: () => subCourtsAsync.value!.first,
      );
    }

    return Scaffold(
      key: WidgetKeys.slotPickerScaffold,
      appBar: AppBar(
        title: Text(
          courtDetailsAsync.value?.name ??
              widget.courtName ??
              AppStrings.selectTime,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (_selectedSubCourtId != null) {
                ref.invalidate(
                  bookedSlotsProvider(
                    courtId: _selectedSubCourtId!,
                    date: _selectedDate,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                itemCount: 14,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = DateUtils.isSameDay(_selectedDate, date);

                  return GestureDetector(
                    key: WidgetKeys.dateItem(index),
                    onTap: () {
                      final normalized =
                          DateTime(date.year, date.month, date.day);
                      setState(() {
                        _selectedDate = normalized;
                        _selectedSlots.clear();
                      });
                    },
                    child: Container(
                      width: AppSizes.dateItemWidth,
                      margin: const EdgeInsets.only(right: AppSizes.p12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor
                            : theme.cardColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppSizes.r20),
                        border: Border.all(
                          color:
                              isSelected ? theme.primaryColor : Colors.white10,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date).toUpperCase(),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white38,
                              fontSize: AppSizes.labelSmall,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p8),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: AppSizes.r20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Sub-courts selector
          subCourtsAsync.when(
            data: (subCourts) {
              if (subCourts.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.p20),
                  child: Text(
                    'Không có sân con nào.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p10),
                child: SizedBox(
                  height: AppSizes.subCourtSelectorHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                    itemCount: subCourts.length,
                    itemBuilder: (context, index) {
                      final subCourt = subCourts[index];
                      final isSelected = _selectedSubCourtId == subCourt.id;

                      return GestureDetector(
                        key: WidgetKeys.subCourtItem(subCourt.id),
                        onTap: () {
                          setState(() {
                            _selectedSubCourtId = subCourt.id;
                            _selectedSlots.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p20,
                          ),
                          margin: const EdgeInsets.only(right: AppSizes.p12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.primaryColor.withValues(alpha: 0.2)
                                : theme.cardColor,
                            borderRadius: BorderRadius.circular(AppSizes.r24),
                            border: Border.all(
                              color: isSelected
                                  ? theme.primaryColor
                                  : Colors.white10,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            subCourt.name,
                            style: TextStyle(
                              color: isSelected
                                  ? theme.primaryColor
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
              child: Text('Lỗi tải sân con: $err'),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p20,
              vertical: AppSizes.p10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.selectTimeHint,
                  style: TextStyle(
                    fontSize: AppSizes.bodyLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (bookedSlotsAsync.isLoading)
                  const SizedBox(
                    width: AppSizes.iconSmall,
                    height: AppSizes.iconSmall,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p20,
              vertical: AppSizes.p8,
            ),
            child: Row(
              children: [
                _LegendItem(
                  color: theme.cardColor,
                  label: AppStrings.statusAvailable,
                ),
                const SizedBox(width: AppSizes.p16),
                const _LegendItem(
                  color: Colors.white24,
                  label: AppStrings.statusBooked,
                ),
                const SizedBox(width: AppSizes.p16),
                _LegendItem(
                  color: theme.primaryColor,
                  label: AppStrings.statusSelected,
                ),
              ],
            ),
          ),

          // Slots Grid
          Expanded(
            child: availableSlotsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Lỗi tải giờ chơi: $err')),
              data: (slots) {
                if (slots.isEmpty) {
                  return const Center(
                    child: Text('Chưa có thông tin giờ mở cửa cho sân này.'),
                  );
                }

                return bookedSlotsAsync.when(
                  data: (bookedSlotsList) {
                    final bookedSlotsSet = bookedSlotsList.toSet();

                    return GridView.builder(
                      padding: const EdgeInsets.all(AppSizes.p20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: AppSizes.p16,
                        mainAxisSpacing: AppSizes.p16,
                        childAspectRatio: AppSizes.gridAspectRatio,
                      ),
                      itemCount: currentSlots.length,
                      itemBuilder: (context, index) {
                        final slot = currentSlots[index];
                        final isPast = _isSlotInPast(slot);

                        // Correctly check for overlaps with booked ranges
                        final isBooked = bookedSlotsSet.any((range) {
                          try {
                            final slotParts = slot.split(' - ');
                            if (slotParts.length != 2) return false;
                            final slotStart = slotParts[0];
                            final slotEnd = slotParts[1];

                            final bookedParts = range.split(' - ');
                            if (bookedParts.length != 2) return false;
                            final bookedStart = bookedParts[0];
                            final bookedEnd = bookedParts[1];

                            // Overlap if: slotStart < bookedEnd && slotEnd > bookedStart
                            return slotStart.compareTo(bookedEnd) < 0 &&
                                slotEnd.compareTo(bookedStart) > 0;
                          } catch (e) {
                            return false;
                          }
                        });

                        final isSelected = _selectedSlots.contains(slot);

                        // If loading, we treat as disabled to prevent clicking something
                        // that might be booked, and to avoid flicker.
                        final isDisabled =
                            isAvailabilityLoading || isBooked || isPast;

                        return GestureDetector(
                          key: WidgetKeys.slotItem(slot),
                          onTap: isDisabled
                              ? null
                              : () => _onSlotTap(
                                    slot,
                                    bookedSlotsSet,
                                    currentSlots,
                                  ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primaryColor
                                  : (isDisabled
                                      ? Colors.white10
                                      : theme.cardColor),
                              borderRadius: BorderRadius.circular(AppSizes.r16),
                              border: Border.all(
                                color: isSelected
                                    ? theme.primaryColor
                                    : Colors.white.withValues(alpha: 0.1),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: isAvailabilityLoading && !isPast && !isBooked
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white24,
                                    ),
                                  )
                                : Text(
                                    slot.replaceAll(' - ', '\n'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.black
                                          : (isDisabled
                                              ? Colors.white24
                                              : Colors.white),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Lỗi: $err')),
                );
              },
            ),
          ),

          // Order Summary
          if (_selectedSlots.isNotEmpty)
            Builder(
              builder: (context) {
                double totalHours = 0;
                double totalPrice = 0;

                for (final slot in _selectedSlots) {
                  try {
                    final parts = slot.split(' - ');
                    final startParts = parts[0].split(':');
                    final endParts = parts[1].split(':');

                    final startHour = int.parse(startParts[0]);
                    final startMin = int.parse(startParts[1]);
                    final endHour = int.parse(endParts[0]);
                    final endMin = int.parse(endParts[1]);

                    final durationMinutes =
                        (endHour * 60 + endMin) - (startHour * 60 + startMin);
                    final slotHours = durationMinutes / 60.0;
                    totalHours += slotHours;

                    if (selectedSubCourt != null) {
                      final isWeekend =
                          _selectedDate.weekday == DateTime.saturday ||
                              _selectedDate.weekday == DateTime.sunday;
                      final isPeakHour = startHour >= 17;
                      final isPeakTime = isWeekend || isPeakHour;

                      final rate = isPeakTime
                          ? selectedSubCourt.peakPricePerHour
                          : selectedSubCourt.pricePerHour;

                      totalPrice += rate * slotHours;
                    }
                  } catch (_) {
                    totalHours += 1.0;
                    if (selectedSubCourt != null) {
                      totalPrice += selectedSubCourt.pricePerHour * 1.0;
                    }
                  }
                }

                return Container(
                  padding: const EdgeInsets.all(AppSizes.p24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSizes.p32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppStrings.totalDuration} (${totalHours.toStringAsFixed(1)} giờ)',
                                style: const TextStyle(color: Colors.white54),
                              ),
                              if (selectedSubCourt != null)
                                Text(
                                  totalPrice.toVND(),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _getTimeRangeDisplay(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${AppStrings.labelDay} ${_selectedDate.day}/${_selectedDate.month}',
                                style: const TextStyle(
                                  fontSize: AppSizes.labelSmall,
                                  color: Colors.white38,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.p24),
                      NeonButton(
                        key: WidgetKeys.continueToSummaryButton,
                        label: AppStrings.btnConfirmBooking,
                        onPressed: () {
                          if (!_isSelectionContinuous(currentSlots)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(AppStrings.valContinuousTime),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          if (selectedSubCourt == null) return;

                          final facility = courtDetailsAsync.value;
                          final facilityName =
                              facility?.name ?? widget.courtName ?? 'Khu sân';
                          final facilityAddress =
                              facility?.address ?? widget.courtAddress ?? '';

                          context.router.push(
                            BookingSummaryRoute(
                              facilityId: widget.courtId,
                              courtId: selectedSubCourt.id,
                              courtName:
                                  '$facilityName - ${selectedSubCourt.name}',
                              courtAddress: facilityAddress,
                              courtImage: selectedSubCourt.images.isNotEmpty
                                  ? selectedSubCourt.images.first
                                  : (facility?.images.isNotEmpty == true
                                      ? facility!.images.first
                                      : (widget.courtImage ??
                                          'https://picsum.photos/400/300')),
                              selectedDate: _selectedDate,
                              selectedSlot: _getTimeRangeDisplay(),
                              price: totalPrice,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizes.iconTiny,
          height: AppSizes.iconTiny,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSizes.p4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.labelSmall,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}
