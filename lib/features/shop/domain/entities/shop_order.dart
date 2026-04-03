class OrderItem {
  final String id;
  final String productName;
  final String productImage;
  final double unitPrice;
  final int quantity;

  OrderItem({
    required this.id,
    required this.productName,
    required this.productImage,
    required this.unitPrice,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      productName: json['product_name'] as String? ?? 'Sản phẩm',
      productImage: json['product_image'] as String? ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}

class ShopOrder {
  final String id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final double totalAmount;
  final DateTime createdAt;
  final List<OrderItem> items;

  ShopOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.totalAmount,
    required this.createdAt,
    required this.items,
  });

  factory ShopOrder.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['order_items'] as List?)
            ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    return ShopOrder(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String? ?? 'DH-000000',
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      items: itemsList,
    );
  }
}
