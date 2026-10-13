import '../repositories/orders_repository.dart';

class ApproveOrderUseCase {
  const ApproveOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<void> call(String orderId, String admin_id) =>
      _repository.approveOrder(orderId, admin_id);
}
