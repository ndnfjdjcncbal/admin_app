import '../entities/store_order.dart';
import '../repositories/orders_repository.dart';

class GetNewOrdersUseCase {
  const GetNewOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  Future<List<StoreOrder>> call() => _repository.getNewOrders();
}
