import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/booking/data/repositories/court_repository_impl.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_providers.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';
import 'package:pickle_pick/shared/widgets/common_widgets.dart';

import '../../../../core/enum/enum.dart';

class Equipment {
  final String id;
  final String name;
  final double pricePerUnit;
  int quantity;

  Equipment({
    required this.id,
    required this.name,
    required this.pricePerUnit,
    this.quantity = 0,
  });
}

@RoutePage()
class BookingSummaryScreen extends ConsumerStatefulWidget {
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
  ConsumerState<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  List<Equipment> _equipments = [];
  bool _isEquipmentInitialized = false;

  String _voucherCode = '';
  double _discountAmount = 0;
  bool _isVoucherApplied = false;
  final TextEditingController _voucherController = TextEditingController();

  PaymentMethod _selectedPaymentMethod = PaymentMethod.picklePay;

  double get _totalEquipmentPrice => _equipments.fold(
        0,
        (sum, item) => sum + (item.pricePerUnit * item.quantity),
      );

  double get _totalPrice {
    final total = widget.price + _totalEquipmentPrice - _discountAmount;
    return total > 0 ? total : 0;
  }

  void _applyVoucher() {
    setState(() {
      if (_voucherController.text.toUpperCase() == 'PICKLE50') {
        _discountAmount = 50000;
        _isVoucherApplied = true;
        _voucherCode = _voucherController.text.toUpperCase();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.msgVoucherSuccess)),
        );
      } else {
        _discountAmount = 0;
        _isVoucherApplied = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.msgVoucherInvalid)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd/MM/yyyy').format(widget.selectedDate);

    ref.watch(rentalServicesProvider).whenData((data) {
      if (!_isEquipmentInitialized) {
        _equipments = data
            .map(
              (e) => Equipment(
                id: e['id'] as String,
                name: e['name'] as String,
                pricePerUnit: (e['price_per_unit'] as num).toDouble(),
              ),
            )
            .toList();
        _isEquipmentInitialized = true;
        Future.microtask(() => setState(() {}));
      }
    });

    return Scaffold(
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
            // ─── Court Info Card ───────────────────────────────────────────
            _CourtInfoCard(
              image: widget.courtImage,
              name: widget.courtName,
              address: widget.courtAddress,
            ),

            const SizedBox(height: AppSizes.p32),

            // ─── Booking Detail ────────────────────────────────────────────
            const Text(
              AppStrings.bookingDetailSection,
              style: TextStyle(
                fontSize: AppSizes.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            _buildDetailRow(Icons.calendar_today, AppStrings.labelDay, dateStr),
            const SizedBox(height: AppSizes.p12),
            _buildDetailRow(
              Icons.access_time,
              AppStrings.labelTimeSlot,
              widget.selectedSlot,
            ),

            const SizedBox(height: AppSizes.p32),

            // ─── Equipment Rental ──────────────────────────────────────────
            const Text(
              AppStrings.equipmentRentalSection,
              style: TextStyle(
                fontSize: AppSizes.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            ..._equipments.map((equipment) => _buildEquipmentItem(equipment)),

            const SizedBox(height: AppSizes.p32),

            // ─── Voucher ───────────────────────────────────────────────────
            const Text(
              AppStrings.voucherSection,
              style: TextStyle(
                fontSize: AppSizes.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherController,
                    decoration: InputDecoration(
                      hintText: AppStrings.voucherHint,
                      fillColor: theme.cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.p12),
                SizedBox(
                  height: AppSizes.searchBarHeight,
                  child: ElevatedButton(
                    onPressed: _applyVoucher,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r12),
                      ),
                    ),
                    child: const Text(AppStrings.btnApplyVoucher),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.p32),

            // ─── Payment Info ──────────────────────────────────────────────
            const Text(
              AppStrings.paymentInfoSection,
              style: TextStyle(
                fontSize: AppSizes.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            _buildPriceRow(AppStrings.courtTotalLabel, widget.price),
            if (_totalEquipmentPrice > 0)
              _buildPriceRow(
                AppStrings.equipmentTotalLabel,
                _totalEquipmentPrice,
              ),
            if (_isVoucherApplied)
              _buildPriceRow(
                'Mã giảm giá ($_voucherCode)',
                -_discountAmount,
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
                  _totalPrice.toVND(),
                  style: TextStyle(
                    fontSize: AppSizes.h4,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.p48),

            // ─── Payment Method ────────────────────────────────────────────
            const Text(
              AppStrings.paymentMethodSection,
              style: TextStyle(
                fontSize: AppSizes.titleLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.p16),
            // Build one _PaymentOption per PaymentMethod enum value.
            ...PaymentMethod.values.map(
              (method) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.p12),
                child: _PaymentOption(
                  icon: method.icon,
                  label: method.label,
                  color: method.color,
                  isSelected: _selectedPaymentMethod == method,
                  onTap: () => setState(() => _selectedPaymentMethod = method),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.p60),

            NeonButton(
              label: AppStrings.btnConfirmAndPay,
              color: theme.primaryColor,
              onPressed: () => _processPayment(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentItem(Equipment equipment) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      padding: const EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipment.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '+${equipment.pricePerUnit.toVND()}/đv',
                  style: const TextStyle(
                    fontSize: AppSizes.labelSmall,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: equipment.quantity > 0
                    ? () => setState(() => equipment.quantity--)
                    : null,
                icon: const Icon(
                  Icons.remove_circle_outline,
                  size: AppSizes.iconLarge,
                ),
              ),
              Text(
                '${equipment.quantity}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizes.bodyLarge,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => equipment.quantity++),
                icon: Icon(
                  Icons.add_circle_outline,
                  size: AppSizes.iconLarge,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {Color? color}) => Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.p8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54)),
            Text(
              amount.toVND(),
              style: TextStyle(
                color: color,
                fontWeight: color != null ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      );

  Widget _buildDetailRow(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: AppSizes.iconLarge, color: Colors.white38),
          const SizedBox(width: AppSizes.p12),
          Text(label, style: const TextStyle(color: Colors.white54)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      );

  Future<void> _processPayment(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const LoadingDialog(message: AppStrings.msgProcessingPayment),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;
    Navigator.of(context).pop();

    try {
      await ref.read(bookingProvider.notifier).addBooking(
            BookedCourt(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              courtName: widget.courtName,
              courtAddress: widget.courtAddress,
              courtImage: widget.courtImage,
              date: widget.selectedDate,
              slot: widget.selectedSlot,
              price: _totalPrice,
            ),
            widget.facilityId,
            widget.courtId,
          );

      ref.invalidate(bookedSlotsProvider);

      if (context.mounted) {
        _showSuccessDialog(context, theme);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorLoading}$e')),
        );
      }
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

// ─── Court Info Card ───────────────────────────────────────────────────────

class _CourtInfoCard extends StatelessWidget {
  final String image;
  final String name;
  final String address;

  const _CourtInfoCard({
    required this.image,
    required this.name,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppSizes.r20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.r12),
            child: Image.network(
              image,
              width: AppSizes.cartItemSize,
              height: AppSizes.cartItemSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.image, color: Colors.white24),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.p16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: AppSizes.titleLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.p4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: AppSizes.iconSmall,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: AppSizes.p4),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: AppSizes.labelMedium,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Payment Option ────────────────────────────────────────────────────────

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppSizes.r16),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor.withValues(alpha: 0.5)
                : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSizes.p12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }
}

// ─── Loading Dialog ────────────────────────────────────────────────────────

class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSizes.p24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppSizes.r16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: theme.primaryColor),
              const SizedBox(height: AppSizes.p16),
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
