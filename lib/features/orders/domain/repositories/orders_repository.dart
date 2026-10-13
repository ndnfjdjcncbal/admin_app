import '../entities/store_order.dart';

abstract class OrdersRepository {
  Future<List<StoreOrder>> getNewOrders();
  Future<void> approveOrder(String orderId, String admin_id);
  Future<void> rejectOrder(String orderId);
}
