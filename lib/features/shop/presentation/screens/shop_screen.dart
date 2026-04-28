import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickle_pick/core/constants/app_sizes.dart';
import 'package:pickle_pick/core/extensions/context_extension.dart';
import 'package:pickle_pick/core/router/app_router.dart';
import 'package:pickle_pick/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:pickle_pick/features/shop/presentation/providers/cart_providers.dart';
import 'package:pickle_pick/shared/widgets/item_cards.dart';

@RoutePage()
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(allProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.shop),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if ((ref.watch(cartProvider).valueOrNull ?? []).isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: AppSizes.shopCartBadgeMin,
                        minHeight: AppSizes.shopCartBadgeMin,
                      ),
                      child: Text(
                        '${ref.read(cartProvider.notifier).itemCount}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: AppSizes.badgeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.router.push(const CartRoute()),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ─── Search Bar ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.p20,
                0,
                AppSizes.p20,
                AppSizes.p10,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                height: AppSizes.searchBarHeight,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(AppSizes.r16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white38),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.toLowerCase()),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: context.l10n.shopSearchHint,
                          border: InputBorder.none,
                          hintStyle: const TextStyle(color: Colors.white24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Categories ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: categoriesAsync.when(
              data: (categories) => SizedBox(
                height: AppSizes.categorySelectorHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                  ),
                  itemCount: categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _CategoryChip(
                        label: context.l10n.shopCategoryAll,
                        isSelected: _selectedCategoryId == null,
                        onTap: () => setState(() => _selectedCategoryId = null),
                      );
                    }
                    final cat = categories[index - 1];
                    return _CategoryChip(
                      label: cat['name'] as String,
                      isSelected: _selectedCategoryId == cat['id'],
                      onTap: () => setState(
                        () => _selectedCategoryId = cat['id'] as String?,
                      ),
                    );
                  },
                ),
              ),
              loading: () =>
                  const SizedBox(height: AppSizes.categorySelectorHeight),
              error: (_, __) =>
                  const SizedBox(height: AppSizes.categorySelectorHeight),
            ),
          ),

          // ─── Product Grid ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.p20),
            sliver: productsAsync.when(
              data: (data) {
                final filtered = data
                    .where(
                      (p) => p.title.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text(context.l10n.noProductsFound)),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSizes.p16,
                    mainAxisSpacing: AppSizes.p16,
                    childAspectRatio: AppSizes.productGridAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = filtered[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.router
                            .push(ProductDetailsRoute(product: product)),
                      );
                    },
                    childCount: filtered.length,
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Text(context.l10n.errorLoading(e.toString())),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSizes.bottomNavSpacing),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSizes.p12),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSizes.r25),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
