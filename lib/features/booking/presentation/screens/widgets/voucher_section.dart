import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_summary_riverpod.dart';

class VoucherSection extends ConsumerStatefulWidget {
  const VoucherSection({super.key});

  @override
  ConsumerState<VoucherSection> createState() => _VoucherSectionState();
}

class _VoucherSectionState extends ConsumerState<VoucherSection> {
  final TextEditingController _voucherController = TextEditingController();

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  void _applyVoucher() {
    final isApplied = ref
        .read(bookingSummaryProvider.notifier)
        .applyVoucher(_voucherController.text.trim());

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isApplied
              ? context.l10n.msgVoucherSuccess
              : context.l10n.msgVoucherInvalid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.voucherSection,
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
                  hintText: context.l10n.voucherHint,
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
                child: Text(context.l10n.btnApplyVoucher),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
