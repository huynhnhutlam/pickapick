import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/domain/entities/sub_court.dart';
import 'package:pickle_pick/features/booking/presentation/providers/court_providers.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';

@RoutePage()
class SlotPickerScreen extends ConsumerStatefulWidget {
  final String courtId;
  const SlotPickerScreen({super.key, required this.courtId});

  @override
  ConsumerState<SlotPickerScreen> createState() => _SlotPickerScreenState();
}

class _SlotPickerScreenState extends ConsumerState<SlotPickerScreen> {
  DateTime _selectedDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final List<String> _selectedSlots = [];
  String? _selectedSubCourtId;

  // Mock slots - 0: Available, 1: Booked, 2: Selected
  final List<String> _slots = [
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
    '19:00',
    '20:00',
  ];

  void _onSlotTap(String slot, Set<String> bookedSlots) {
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
    final parts = slot.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (hour < now.hour) return true;
    if (hour == now.hour && minute <= now.minute) return true;

    return false;
  }

  bool _isSelectionContinuous() {
    if (_selectedSlots.isEmpty) return false;
    if (_selectedSlots.length == 1) return true;

    final indices = _selectedSlots.map((s) => _slots.indexOf(s)).toList();
    indices.sort();

    for (int i = 0; i < indices.length - 1; i++) {
      if (indices[i + 1] - indices[i] != 1) return false;
    }
    return true;
  }

  String _getTimeRangeDisplay() {
    if (_selectedSlots.isEmpty) return '';
    _selectedSlots.sort();

    final start = _selectedSlots.first;
    final last = _selectedSlots.last;

    // Assuming each slot is 1 hour
    final lastTimePart = int.parse(last.split(':')[0]);
    final endTime = '${(lastTimePart + 1).toString().padLeft(2, '0')}:00';

    if (_selectedSlots.length == 1) {
      return '$start - $endTime';
    }
    return '$start - $endTime';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subCourtsAsync = ref.watch(subCourtsProvider(widget.courtId));

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

    // We use .value to check data, but we also check .isLoading to prevent flicker
    final bookedSlotsSet = bookedSlotsAsync.value?.toSet() ?? {};
    final isAvailabilityLoading = bookedSlotsAsync.isLoading;

    SubCourt? selectedSubCourt;
    if (subCourtsAsync.value != null && _selectedSubCourtId != null) {
      selectedSubCourt = subCourtsAsync.value!.firstWhere(
        (c) => c.id == _selectedSubCourtId,
        orElse: () => subCourtsAsync.value!.first,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.selectTime),
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
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSizes.p20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSizes.p16,
                mainAxisSpacing: AppSizes.p16,
                childAspectRatio: AppSizes.gridAspectRatio,
              ),
              itemCount: _slots.length,
              itemBuilder: (context, index) {
                final slot = _slots[index];
                final isPast = _isSlotInPast(slot);

                // Correctly check for overlaps with booked ranges
                final isBooked = bookedSlotsSet.any((range) {
                  try {
                    final parts = range.split(' - ');
                    if (parts.length != 2) return false;
                    return slot.compareTo(parts[0]) >= 0 &&
                        slot.compareTo(parts[1]) < 0;
                  } catch (e) {
                    return false;
                  }
                });

                final isSelected = _selectedSlots.contains(slot);

                // If loading, we treat as disabled to prevent clicking something
                // that might be booked, and to avoid flicker.
                final isDisabled = isAvailabilityLoading || isBooked || isPast;

                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () => _onSlotTap(slot, bookedSlotsSet),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor
                          : (isDisabled ? Colors.white10 : theme.cardColor),
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
                            slot,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.black
                                  : (isDisabled
                                      ? Colors.white24
                                      : Colors.white),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),

          // Order Summary
          if (_selectedSlots.isNotEmpty)
            Container(
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
                            '${AppStrings.totalDuration} (${_selectedSlots.length} giờ)',
                            style: const TextStyle(color: Colors.white54),
                          ),
                          if (selectedSubCourt != null)
                            Text(
                              (selectedSubCourt.pricePerHour *
                                      _selectedSlots.length)
                                  .toVND(),
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
                            style: const TextStyle(fontWeight: FontWeight.w600),
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
                    label: AppStrings.btnConfirmBooking,
                    onPressed: () {
                      if (!_isSelectionContinuous()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(AppStrings.valContinuousTime),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      if (selectedSubCourt == null) return;

                      final facilityAsync =
                          ref.read(courtDetailsProvider(widget.courtId));
                      final facility = facilityAsync.value;
                      final facilityName = facility?.name ?? 'Khu sân';
                      final facilityAddress = facility?.address ?? '';

                      context.router.push(
                        BookingSummaryRoute(
                          facilityId: widget.courtId,
                          courtId: selectedSubCourt.id,
                          courtName: '$facilityName - ${selectedSubCourt.name}',
                          courtAddress: facilityAddress,
                          courtImage: selectedSubCourt.images.isNotEmpty
                              ? selectedSubCourt.images.first
                              : (facility?.images.isNotEmpty == true
                                  ? facility!.images.first
                                  : 'https://picsum.photos/400/300'),
                          selectedDate: _selectedDate,
                          selectedSlot: _getTimeRangeDisplay(),
                          price: selectedSubCourt.pricePerHour *
                              _selectedSlots.length,
                        ),
                      );
                    },
                  ),
                ],
              ),
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
