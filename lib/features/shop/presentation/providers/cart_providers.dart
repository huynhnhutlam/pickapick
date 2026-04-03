import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/shop_repository_impl.dart';
import '../../domain/entities/product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({String? id, Product? product, int? quantity}) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartNotifier extends StateNotifier<AsyncValue<List<CartItem>>> {
  RealtimeChannel? _channel;

  CartNotifier(this._client) : super(const AsyncLoading()) {
    fetchCart();
    _setupRealtime();
  }

  final SupabaseClient _client;

  void _setupRealtime() {
    final user = _client.auth.currentUser;
    if (user == null) return;

    _channel = _client
        .channel('public:cart_items')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'cart_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            fetchCart();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> fetchCart() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      state = const AsyncData([]);
      return;
    }
    try {
      final response = await _client
          .from('cart_items')
          .select('*, products:product_id(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final items = (response as List).map((json) {
        return CartItem(
          id: json['id'] as String,
          product: SupabaseShopRepository.toProduct(
            json['products'] as Map<String, dynamic>,
          ),
          quantity: json['quantity'] as int,
        );
      }).toList();

      if (mounted) state = AsyncData(items);
    } catch (e, s) {
      if (mounted) state = AsyncError(e, s);
      developer.log('Fetch cart failed', error: e, stackTrace: s);
    }
  }

  Future<void> add(Product product) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final currentItems = state.valueOrNull ?? [];
    try {
      if (currentItems.any((item) => item.product.id == product.id)) {
        final existingItem =
            currentItems.firstWhere((item) => item.product.id == product.id);
        await updateQuantity(existingItem.id, existingItem.quantity + 1);
      } else {
        await _client.from('cart_items').insert({
          'user_id': user.id,
          'product_id': product.id,
          'quantity': 1,
        });
      }
      await fetchCart();
    } catch (e, s) {
      developer.log('Add cart failed', error: e, stackTrace: s);
    }
  }

  Future<void> remove(String cartItemId) async {
    try {
      await _client.from('cart_items').delete().eq('id', cartItemId);
      await fetchCart();
    } catch (e, s) {
      developer.log('Remove cart failed', error: e, stackTrace: s);
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await remove(cartItemId);
      return;
    }
    try {
      await _client
          .from('cart_items')
          .update({'quantity': quantity}).eq('id', cartItemId);
      await fetchCart();
    } catch (e, s) {
      developer.log('Update quantity failed', error: e, stackTrace: s);
    }
  }

  Future<void> clear() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    try {
      await _client.from('cart_items').delete().eq('user_id', user.id);
      await fetchCart();
    } catch (e, s) {
      developer.log('Clear cart failed', error: e, stackTrace: s);
    }
  }

  double get totalAmount {
    final items = state.valueOrNull ?? [];
    return items.fold(0, (total, item) {
      final price = item.product.salePrice ?? item.product.price;
      return total + (price * item.quantity);
    });
  }

  int get itemCount {
    final items = state.valueOrNull ?? [];
    return items.fold(0, (count, item) => count + item.quantity);
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<List<CartItem>>>((ref) {
  return CartNotifier(Supabase.instance.client);
});
