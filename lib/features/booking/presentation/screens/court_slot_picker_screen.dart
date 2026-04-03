import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/data/repositories/court_repository_impl.dart';
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
  DateTime _selectedDate = DateTime.now();
  final List<String> _selectedSlots = [];

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
    setState(() {
      if (_selectedSlots.contains(slot)) {
        _selectedSlots.remove(slot);
      } else {
        _selectedSlots.add(slot);
      }
      _selectedSlots.sort();
    });
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
    final bookedSlotsAsync = ref.watch(
      bookedSlotsProvider(
        (facilityId: widget.courtId, date: _selectedDate),
      ),
    );
    final bookedSlots = bookedSlotsAsync.value?.toSet() ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn giờ chơi')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 14,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = DateUtils.isSameDay(_selectedDate, date);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                        _selectedSlots.clear();
                      });
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor
                            : theme.cardColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontSize: 20,
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

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Chọn khung giờ (có thể chọn nhiều)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _LegendItem(color: theme.cardColor, label: 'Trống'),
                const SizedBox(width: 16),
                const _LegendItem(color: Colors.white24, label: 'Đã đặt'),
                const SizedBox(width: 16),
                _LegendItem(color: theme.primaryColor, label: 'Đang chọn'),
              ],
            ),
          ),

          // Slots Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
              ),
              itemCount: _slots.length,
              itemBuilder: (context, index) {
                final slot = _slots[index];
                final isBooked = bookedSlots.contains(slot);
                final isSelected = _selectedSlots.contains(slot);

                return GestureDetector(
                  onTap: isBooked ? null : () => _onSlotTap(slot, bookedSlots),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor
                          : (isBooked ? Colors.white10 : theme.cardColor),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      slot,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.black
                            : (isBooked ? Colors.white24 : Colors.white),
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
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
                            'Tổng cộng (${_selectedSlots.length} giờ)',
                            style: const TextStyle(color: Colors.white54),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final courtAsync = ref
                                  .watch(courtDetailsProvider(widget.courtId));
                              return courtAsync.when(
                                data: (court) => Text(
                                  (court.pricePerHour * _selectedSlots.length)
                                      .toVND(),
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                loading: () => const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                error: (_, __) => const Text('Lỗi giá'),
                              );
                            },
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
                            'Ngày ${_selectedDate.day}/${_selectedDate.month}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  NeonButton(
                    label: 'XÁC NHẬN ĐẶT SÂN',
                    onPressed: () {
                      if (!_isSelectionContinuous()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng chọn khung giờ liên tục.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final courtAsync =
                          ref.read(courtDetailsProvider(widget.courtId));
                      final court = courtAsync.value;
                      if (court == null) return;

                      context.router.push(
                        BookingSummaryRoute(
                          courtId: widget.courtId,
                          courtName: court.name,
                          courtAddress: court.address,
                          courtImage: court.images.isNotEmpty
                              ? court.images.first
                              : 'https://picsum.photos/400/300',
                          selectedDate: _selectedDate,
                          selectedSlot: _getTimeRangeDisplay(),
                          price: court.pricePerHour * _selectedSlots.length,
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white54),
        ),
      ],
    );
  }
}
