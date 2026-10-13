import 'package:adminapp/core/constants/api_client/link_api.dart';
import 'package:adminapp/core/constants/app_color/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/catalog_entities.dart';
import '../bloc/catalog_cubit.dart';
import '../bloc/catalog_state.dart';
import '../widgets/catalog_forms.dart';

class CategoryProductsPage extends StatelessWidget {
  const CategoryProductsPage({super.key, required this.category});

  final CatalogCategory category;

  Future<void> _openForm(
    BuildContext context, [
    CatalogProduct? product,
  ]) async {
    final changed = await showProductForm(
      context,
      context.read<CatalogCubit>(),
      categoryId: category.id,
      product: product,
    );
    if (changed && context.mounted) {
      _showMessage(context, 'Product saved.');
    }
  }

  Future<void> _delete(BuildContext context, CatalogProduct product) async {
    final confirmed = await confirmCatalogDelete(
      context,
      title: 'Delete product',
      message: 'Delete "${product.name}"?',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await context.read<CatalogCubit>().deleteProduct(product.id, category.id);
      if (context.mounted) _showMessage(context, 'Product deleted.');
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, error.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        appBar: AppBar(
          title: Text(category.name),
          backgroundColor: AppColors.backgroundGrey,
          foregroundColor: AppColors.black,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Category products',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _openForm(context),
                    icon: const Icon(Icons.add_rounded, size: 19),
                    label: const Text('Add product'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: BlocBuilder<CatalogCubit, CatalogState>(
                  builder: (context, state) {
                    if (state.productsLoading && state.products.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.productsError != null && state.products.isEmpty) {
                      return _ProductsErrorView(
                        message: state.productsError!,
                        onRetry: () => context
                            .read<CatalogCubit>()
                            .loadProducts(category.id),
                      );
                    }
                    final products = state.products;
                    if (products.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => context
                            .read<CatalogCubit>()
                            .loadProducts(category.id),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 90),
                            Icon(
                              Icons.inventory_2_outlined,
                              color: AppColors.primaryLight,
                              size: 54,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No products in this category',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Add your first product using the button above.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.grey),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => context
                          .read<CatalogCubit>()
                          .loadProducts(category.id),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 850
                              ? 4
                              : constraints.maxWidth >= 560
                              ? 3
                              : 2;
                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: columns == 2 ? 0.73 : 0.82,
                                ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return _ProductCard(
                                product: product,
                                onEdit: () => _openForm(context, product),
                                onDelete: () => _delete(context, product),
                              );
                            },
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
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final CatalogProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final image = product.image;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                image == null || image.isEmpty
                    ? const ColoredBox(
                        color: AppColors.primaryPale,
                        child: Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary,
                          size: 44,
                        ),
                      )
                    : Image.network(
                        _resolveImage(image),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: AppColors.primaryPale,
                          child: Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primary,
                            size: 44,
                          ),
                        ),
                      ),
                Positioned(
                  top: 7,
                  left: 7,
                  child: Row(
                    children: [
                      _ProductAction(icon: Icons.edit_outlined, onTap: onEdit),
                      const SizedBox(width: 5),
                      _ProductAction(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.red.shade700,
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 9, 11, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'EGP ${product.price}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      'Stock ${product.count}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductAction extends StatelessWidget {
  const _ProductAction({
    required this.icon,
    required this.onTap,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }
}

class _ProductsErrorView extends StatelessWidget {
  const _ProductsErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.grey, size: 42),
          const SizedBox(height: 10),
          const Text('Unable to load products'),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

String _resolveImage(String path) {
  if (Uri.tryParse(path)?.hasScheme == true) return path;
  return '${ApiConstants.Api}/${path.replaceFirst(RegExp(r'^/+'), '')}';
}

void _showMessage(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.primary,
      ),
    );
}
