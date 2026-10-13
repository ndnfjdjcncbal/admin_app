import '../../domain/entities/store_order.dart';

class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.processingOrderId,
    this.error,
    this.notice,
    this.noticeIsError = false,
  });

  final List<StoreOrder> orders;
  final bool isLoading;
  final String? processingOrderId;
  final String? error;
  final String? notice;
  final bool noticeIsError;

  OrdersState copyWith({
    List<StoreOrder>? orders,
    bool? isLoading,
    String? processingOrderId,
    bool clearProcessingOrderId = false,
    String? error,
    bool clearError = false,
    String? notice,
    bool clearNotice = false,
    bool? noticeIsError,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      processingOrderId: clearProcessingOrderId
          ? null
          : processingOrderId ?? this.processingOrderId,
      error: clearError ? null : error ?? this.error,
      notice: clearNotice ? null : notice ?? this.notice,
      noticeIsError: noticeIsError ?? this.noticeIsError,
    );
  }
}
