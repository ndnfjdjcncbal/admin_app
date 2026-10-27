import 'package:adminapp/core/constants/api_client/link_api.dart';
import 'package:adminapp/core/network/api_consumer.dart';
import 'package:dio/dio.dart';

class OrdersRemoteDataSource {
  const OrdersRemoteDataSource(this._api);

  final ApiConsumer _api;

  Future<Response> getNewOrders() => _api.get(ApiConstants.get_new_orders);

  Future<Response> approveOrder(String orderId, String adminId) => _api.post(
    ApiConstants.aproveorder,
    data: FormData.fromMap({'orders_id': orderId, 'admin_id': adminId}),
  );

  Future<Response> rejectOrder(String orderId, String adminId) => _api.post(
    ApiConstants.rejectorder,
    data: FormData.fromMap({'orders_id': orderId, 'admin_id': adminId}),
  );
}
