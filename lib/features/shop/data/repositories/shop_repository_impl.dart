import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/product.dart';

/// Supabase-backed shop repository.
class SupabaseShopRepository {
  SupabaseShopRepository(this._client);

  final SupabaseClient _client;

  Future<List<Product>> getFeaturedProducts() async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('sold_count', ascending: false)
          .limit(10);
      return (response as List)
          .map((json) => toProduct(json as Map<String, dynamic>))
          .toList();
    } catch (e, s) {
      developer.log(
        'Failed to fetch featured products',
        name: 'ShopRepository',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<List<Product>> getProducts({String? categoryId}) async {
    try {
      var query = _client.from('products').select().eq('is_active', true);
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      final response = await query.order('sold_count', ascending: false);
      return (response as List)
          .map((json) => toProduct(json as Map<String, dynamic>))
          .toList();
    } catch (e, s) {
      developer.log(
        'Failed to fetch products',
        name: 'ShopRepository',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<Product> getProductDetails(String id) async {
    try {
      final response =
          await _client.from('products').select().eq('id', id).single();
      return toProduct(response);
    } catch (e, s) {
      developer.log(
        'Failed to fetch product $id',
        name: 'ShopRepository',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('product_categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  static Product toProduct(Map<String, dynamic> json) {
    final images = (json['images'] as List?)?.cast<String>() ?? [];
    return Product(
      id: json['id'] as String,
      title: json['name'] as String,
      description: json['description'] as String? ?? '',
      images: images.isNotEmpty
          ? images
          : ['https://picsum.photos/seed/${json['id']}/400/400'],
      price: (json['price'] as num).toDouble(),
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      category: json['brand'] as String? ?? '',
      variants: const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: (json['total_reviews'] as int?) ?? 0,
      isFavorite: false,
      stock: (json['stock_quantity'] as int?) ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final shopRepositoryProvider = Provider<SupabaseShopRepository>((ref) {
  return SupabaseShopRepository(Supabase.instance.client);
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(shopRepositoryProvider).getFeaturedProducts();
});

final allProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(shopRepositoryProvider).getProducts();
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(shopRepositoryProvider).getCategories();
});
