import '../../domain/entities/store_order.dart';

class StoreOrderModel extends StoreOrder {
  const StoreOrderModel({
    required super.id,
    super.customerName,
    super.customerPhone,
    super.userId,
    super.address,
    super.total,
    super.paymentMethod,
    super.createdAt,
    super.itemsSummary,
    super.status,
    super.orderType,
    super.itemCount,
    super.couponDiscount,
    super.shipping,
    super.couponId,
    super.itemId,
    super.deliveryUserId,
    super.receivedAt,
  });

  factory StoreOrderModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] is Map
        ? Map<String, dynamic>.from(json['order'] as Map)
        : json;
    final customer = order['user'] is Map
        ? Map<String, dynamic>.from(order['user'] as Map)
        : order;

    final id = _firstValue(order, const [
      'order_id',
      'orders_id',
      'id',
    ]);
    if (id.isEmpty) {
      throw const FormatException('An order is missing its ID.');
    }

    return StoreOrderModel(
      id: id,
      customerName: _firstValue(customer, const [
        'user_name',
        'users_name',
        'customer_name',
        'name',
      ]),
      customerPhone: _firstValue(customer, const [
        'user_phone',
        'users_phone',
        'customer_phone',
        'phone',
      ]),
      userId: _firstValue(order, const ['order_userid', 'user_id']),
      address: _firstValue(order, const [
        'order_address',
        'orders_address',
        'address',
      ]),
      total: _firstValue(order, const [
        'order_total',
        'orders_totalprice',
        'orders_price',
        'total',
      ]),
      paymentMethod: _firstValue(order, const [
        'order_payment',
        'order_payment_method',
        'orders_paymentmethod',
        'payment_method',
      ]),
      createdAt: _firstValue(order, const [
        'order_datetime',
        'order_date',
        'orders_date',
        'created_at',
      ]),
      itemsSummary: _itemsSummary(order['items'] ?? order['order_items']),
      status: _firstValue(order, const ['order_status', 'status']),
      orderType: _firstValue(order, const ['order_type', 'type']),
      itemCount: _firstValue(order, const ['order_countitem', 'item_count']),
      couponDiscount: _firstValue(order, const [
        'order_cupon_discount',
        'order_coupon_discount',
        'coupon_discount',
      ]),
      shipping: _firstValue(order, const [
        'orders_shipping',
        'order_shipping',
        'shipping',
      ]),
      couponId: _firstValue(order, const [
        'orders_cupon',
        'orders_coupon',
        'coupon_id',
      ]),
      itemId: _firstValue(order, const ['orders_item', 'order_item', 'item_id']),
      deliveryUserId: _nullableValue(order, const [
        'delivery_userid',
        'delivery_user_id',
      ]),
      receivedAt: _firstValue(order, const [
        'order_received_at',
        'received_at',
      ]),
    );
  }

  StoreOrder toEntity() => StoreOrder(
    id: id,
    customerName: customerName,
    customerPhone: customerPhone,
    userId: userId,
    address: address,
    total: total,
    paymentMethod: paymentMethod,
    createdAt: createdAt,
    itemsSummary: itemsSummary,
    status: status,
    orderType: orderType,
    itemCount: itemCount,
    couponDiscount: couponDiscount,
    shipping: shipping,
    couponId: couponId,
    itemId: itemId,
    deliveryUserId: deliveryUserId,
    receivedAt: receivedAt,
  );

  static String _firstValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  static String? _nullableValue(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  static String _itemsSummary(dynamic value) {
    if (value is! List) return '';
    return value
        .whereType<Map>()
        .map((item) {
          final name =
              item['items_name'] ?? item['item_name'] ?? item['name'] ?? '';
          final quantity =
              item['quantity'] ?? item['count'] ?? item['item_count'] ?? '';
          if (name.toString().isEmpty) return '';
          return quantity.toString().isEmpty
              ? name.toString()
              : '${name.toString()} × ${quantity.toString()}';
        })
        .where((item) => item.isNotEmpty)
        .join(', ');
  }
}
