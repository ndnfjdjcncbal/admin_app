import '../repositories/orders_repository.dart';

class RejectOrderUseCase {
  const RejectOrderUseCase(this._repository);

  final OrdersRepository _repository;

  Future<void> call(String orderId) => _repository.rejectOrder(orderId);
}
