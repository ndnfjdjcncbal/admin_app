import '../repositories/orders_repository.dart';

class RejectOrderUseCase {
  const RejectOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<void> call(String orderId, String adminId) =>
      _repository.rejectOrder(orderId, adminId);
}
