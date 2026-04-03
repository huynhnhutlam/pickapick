import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/shop_order.dart';

class OrderNotifier extends StateNotifier<AsyncValue<List<ShopOrder>>> {
  RealtimeChannel? _channel;

  OrderNotifier(this._client) : super(const AsyncLoading()) {
    fetchOrders();
    _setupRealtime();
  }

  final SupabaseClient _client;

  void _setupRealtime() {
    final user = _client.auth.currentUser;
    if (user == null) return;

    _channel = _client
        .channel('public:orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            fetchOrders();
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      state = const AsyncData([]);
      return;
    }

    try {
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final orders = (response as List).map((json) {
        return ShopOrder.fromJson(json as Map<String, dynamic>);
      }).toList();

      if (mounted) state = AsyncData(orders);
    } catch (e, s) {
      if (mounted) state = AsyncError(e, s);
      developer.log('Fetch orders failed', error: e, stackTrace: s);
    }
  }

  Future<void> createOrder(List<dynamic> items, double totalAmount) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      // Create order
      final orderResponse = await _client
          .from('orders')
          .insert({
            'user_id': user.id,
            'order_number':
                'DH-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
            'status': 'pending',
            'payment_status': 'unpaid',
            'payment_method': 'cod',
            'subtotal': totalAmount,
            'shipping_fee': 0,
            'total_amount': totalAmount,
            'shipping_name': user.userMetadata?['full_name'] ?? 'Khách',
            'shipping_phone': user.userMetadata?['phone'] ?? '0123456789',
            'shipping_address': 'Địa chỉ mặc định',
            'shipping_city': 'TP. Hồ Chí Minh',
            'shipping_district': 'Quận 1',
          })
          .select()
          .single();

      final orderId = orderResponse['id'];

      // Add order items
      final orderItemsData = items.map((item) {
        return {
          'order_id': orderId,
          'product_id': item.product.id,
          'product_name': item.product.title,
          'product_image':
              item.product.images.isNotEmpty ? item.product.images.first : null,
          'unit_price': item.product.salePrice ?? item.product.price,
          'quantity': item.quantity,
          'total_price':
              (item.product.salePrice ?? item.product.price) * item.quantity,
        };
      }).toList();

      await _client.from('order_items').insert(orderItemsData);

      // Clear cart
      await _client.from('cart_items').delete().eq('user_id', user.id);

      // Refresh both orders and cart
      await fetchOrders();
    } catch (e, s) {
      developer.log('Create order failed', error: e, stackTrace: s);
      rethrow;
    }
  }
}

final orderProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<List<ShopOrder>>>((ref) {
  return OrderNotifier(Supabase.instance.client);
});
