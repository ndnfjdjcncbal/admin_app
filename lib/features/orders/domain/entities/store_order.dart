class StoreOrder {
  const StoreOrder({
    required this.id,
    this.customerName = '',
    this.customerPhone = '',
    this.userId = '',
    this.address = '',
    this.total = '',
    this.paymentMethod = '',
    this.createdAt = '',
    this.itemsSummary = '',
    this.status = '',
    this.orderType = '',
    this.itemCount = '',
    this.couponDiscount = '',
    this.shipping = '',
    this.couponId = '',
    this.itemId = '',
    this.deliveryUserId,
    this.receivedAt = '',
  });

  final String id;
  final String customerName;
  final String customerPhone;
  final String userId;
  final String address;
  final String total;
  final String paymentMethod;
  final String createdAt;
  final String itemsSummary;
  final String status;
  final String orderType;
  final String itemCount;
  final String couponDiscount;
  final String shipping;
  final String couponId;
  final String itemId;
  final String? deliveryUserId;
  final String receivedAt;
}
