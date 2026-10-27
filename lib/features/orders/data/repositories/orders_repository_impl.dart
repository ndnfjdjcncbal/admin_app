import '../../domain/entities/store_order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../models/store_order_model.dart';
import '../remote_data_source/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._remoteDataSource);

  final OrdersRemoteDataSource _remoteDataSource;

  @override
  Future<List<StoreOrder>> getNewOrders() async {
    final response = await _remoteDataSource.getNewOrders();
    final payload = _ordersPayload(response.data);
    return payload
        .map((item) => StoreOrderModel.fromJson(item).toEntity())
        .toList();
  }

  @override
  Future<void> approveOrder(String orderId, String adminId) async {
    await _remoteDataSource.approveOrder(orderId, adminId);
  }

  @override
  Future<void> rejectOrder(String orderId, String adminId) async {
    await _remoteDataSource.rejectOrder(orderId, adminId);
  }

  List<Map<String, dynamic>> _ordersPayload(dynamic response) {
    final payload = response is List
        ? response
        : response is Map
        ? _wrappedOrdersPayload(response)
        : null;
    if (payload is! List) {
      throw const FormatException(
        'The orders list is missing from the response.',
      );
    }
    return payload.map((item) {
      if (item is! Map) {
        throw const FormatException(
          'The server response contains an invalid order.',
        );
      }
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  dynamic _wrappedOrdersPayload(Map response) {
    final data = response['data'];
    return data is List
        ? data
        : data is Map
        ? data['orders'] ?? response['orders']
        : response['orders'];
  }
}
