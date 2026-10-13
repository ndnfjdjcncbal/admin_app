import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/use_cases/approve_order_use_case.dart';
import '../../domain/use_cases/get_new_orders_use_case.dart';
import '../../domain/use_cases/reject_order_use_case.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({
    required this._getNewOrders,
    required this._approveOrder,
    required this._rejectOrder,
  }) : super(const OrdersState());

  final GetNewOrdersUseCase _getNewOrders;
  final ApproveOrderUseCase _approveOrder;
  final RejectOrderUseCase _rejectOrder;

  Future<void> loadOrders() async {
    emit(state.copyWith(isLoading: true, clearError: true, clearNotice: true));
    try {
      final orders = await _getNewOrders();
      emit(state.copyWith(orders: orders, isLoading: false));
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  Future<void> approve(String orderId, String admin_id) => _runOrderAction(
    orderId,
    () => _approveOrder(orderId, admin_id),
    'Order approved successfully.',
  );

  Future<void> reject(String orderId) => _runOrderAction(
    orderId,
    () => _rejectOrder(orderId),
    'Order rejected successfully.',
  );

  Future<void> _runOrderAction(
    String orderId,
    Future<void> Function() action,
    String successMessage,
  ) async {
    if (state.processingOrderId != null) return;
    emit(
      state.copyWith(
        processingOrderId: orderId,
        clearNotice: true,
        clearError: true,
      ),
    );
    try {
      await action();
      emit(
        state.copyWith(
          orders: state.orders.where((order) => order.id != orderId).toList(),
          clearProcessingOrderId: true,
          notice: successMessage,
          noticeIsError: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          clearProcessingOrderId: true,
          notice: error.toString(),
          noticeIsError: true,
        ),
      );
    }
  }
}
