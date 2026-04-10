import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/constants/app_strings.dart';
import 'package:pickle_pick/features/booking/domain/entities/equipment.dart';
import 'package:pickle_pick/features/booking/presentation/providers/booking_providers.dart';
import 'package:pickle_pick/shared/utils/formatters.dart';

class EquipmentSection extends ConsumerWidget {
  const EquipmentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentsAsync = ref.watch(equipmentSelectionProvider);
    final equipmentsData = equipmentsAsync.valueOrNull ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Equipment Section
        if (equipmentsAsync.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (equipmentsData.isNotEmpty) ...[
          const Text(
            AppStrings.equipmentRentalSection,
            style: TextStyle(
              fontSize: AppSizes.titleLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          ...equipmentsData.map(
            (e) => _buildEquipmentItem(
              e,
              context,
              onDecrease: () =>
                  ref.read(equipmentSelectionProvider.notifier).decrement(e.id),
              onIncrease: () =>
                  ref.read(equipmentSelectionProvider.notifier).increment(e.id),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEquipmentItem(
    Equipment equipment,
    BuildContext context, {
    Function? onDecrease,
    Function? onIncrease,
  }) {
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
                onPressed:
                    equipment.quantity > 0 ? () => onDecrease?.call() : null,
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
                onPressed: () => onIncrease?.call(),
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
}
