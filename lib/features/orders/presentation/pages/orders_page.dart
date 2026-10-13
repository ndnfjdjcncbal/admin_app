import 'package:adminapp/core/constants/app_color/Colors.dart';
import 'package:adminapp/features/home/presentation/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/store_order.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adminId = context.select<ProfileCubit, String>(
      (cubit) => cubit.state.user?.id ?? '',
    );
    return BlocListener<OrdersCubit, OrdersState>(
      listenWhen: (previous, current) =>
          previous.notice != current.notice && current.notice != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.notice!),
              backgroundColor: state.noticeIsError
                  ? Colors.red.shade700
                  : Colors.green.shade700,
            ),
          );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New orders',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Review and manage incoming orders',
                        style: TextStyle(color: AppColors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh orders',
                  onPressed: () => context.read<OrdersCubit>().loadOrders(),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: BlocBuilder<OrdersCubit, OrdersState>(
                builder: (context, state) {
                  if (state.isLoading && state.orders.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.error != null && state.orders.isEmpty) {
                    return _OrdersMessage(
                      icon: Icons.cloud_off_outlined,
                      title: 'Could not load orders',
                      message: state.error!,
                      actionLabel: 'Try again',
                      onAction: () => context.read<OrdersCubit>().loadOrders(),
                    );
                  }
                  if (state.orders.isEmpty) {
                    return const _OrdersMessage(
                      icon: Icons.receipt_long_outlined,
                      title: 'No new orders',
                      message: 'New orders will appear here.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: context.read<OrdersCubit>().loadOrders,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: state.orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = state.orders[index];
                        return _OrderCard(
                          order: order,
                          isProcessing: state.processingOrderId == order.id,
                          actionsDisabled:
                              state.processingOrderId != null ||
                              state.isLoading,
                          adminId: adminId,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.adminId,
    required this.order,
    required this.isProcessing,
    required this.actionsDisabled,
  });

  final String adminId;
  final StoreOrder order;
  final bool isProcessing;
  final bool actionsDisabled;

  Future<void> _reject(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject order?'),
        content: Text('Are you sure you want to reject order #${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<OrdersCubit>().reject(order.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black,
                    ),
                  ),
                ),
                if (isProcessing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (order.customerName.isNotEmpty)
              _OrderDetail(
                icon: Icons.person_outline_rounded,
                text: order.customerName,
              ),
            if (order.customerPhone.isNotEmpty)
              _OrderDetail(
                icon: Icons.phone_outlined,
                text: order.customerPhone,
              ),
            if (order.userId.isNotEmpty)
              _OrderDetail(
                icon: Icons.account_circle_outlined,
                text: 'Customer ID: ${order.userId}',
              ),
            if (order.address.isNotEmpty)
              _OrderDetail(
                icon: Icons.location_on_outlined,
                text: order.address,
              ),
            if (order.status.isNotEmpty)
              _OrderDetail(
                icon: Icons.info_outline_rounded,
                text: 'Status: ${order.status}',
              ),
            if (order.orderType.isNotEmpty)
              _OrderDetail(
                icon: Icons.local_shipping_outlined,
                text: 'Type: ${order.orderType}',
              ),
            if (order.itemCount.isNotEmpty)
              _OrderDetail(
                icon: Icons.shopping_bag_outlined,
                text: 'Items: ${order.itemCount}',
              ),
            if (order.itemsSummary.isNotEmpty)
              _OrderDetail(
                icon: Icons.shopping_bag_outlined,
                text: order.itemsSummary,
              ),
            if (order.paymentMethod.isNotEmpty)
              _OrderDetail(
                icon: Icons.payment_rounded,
                text: order.paymentMethod,
              ),
            if (order.createdAt.isNotEmpty)
              _OrderDetail(icon: Icons.schedule_rounded, text: order.createdAt),
            if (order.receivedAt.isNotEmpty)
              _OrderDetail(
                icon: Icons.check_circle_outline_rounded,
                text: 'Received: ${order.receivedAt}',
              ),
            if (order.deliveryUserId != null)
              _OrderDetail(
                icon: Icons.delivery_dining_outlined,
                text: 'Delivery user ID: ${order.deliveryUserId}',
              ),
            if (order.itemId.isNotEmpty)
              _OrderDetail(
                icon: Icons.inventory_2_outlined,
                text: 'Item ID: ${order.itemId}',
              ),
            if (order.couponId.isNotEmpty)
              _OrderDetail(
                icon: Icons.confirmation_number_outlined,
                text: 'Coupon ID: ${order.couponId}',
              ),
            if (order.couponDiscount.isNotEmpty)
              _OrderDetail(
                icon: Icons.discount_outlined,
                text: 'Coupon discount: ${order.couponDiscount}',
              ),
            if (order.shipping.isNotEmpty)
              _OrderDetail(
                icon: Icons.local_shipping_outlined,
                text: 'Shipping: ${order.shipping}',
              ),
            if (order.total.isNotEmpty) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    order.total,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: actionsDisabled ? null : () => _reject(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: actionsDisabled || adminId.isEmpty
                        ? null
                        : () => context.read<OrdersCubit>().approve(
                            order.id,
                            adminId,
                          ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetail extends StatelessWidget {
  const _OrderDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.grey),
          const SizedBox(width: 9),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _OrdersMessage extends StatelessWidget {
  const _OrdersMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.grey),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 14),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
