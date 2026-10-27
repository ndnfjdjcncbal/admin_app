import 'package:adminapp/core/constants/api_client/link_api.dart';
import 'package:adminapp/core/constants/app_color/Colors.dart';
import 'package:adminapp/core/services/service_locator.dart';
import 'package:adminapp/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:adminapp/features/orders/presentation/pages/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/catalog_entities.dart';
import '../bloc/catalog_cubit.dart';
import '../bloc/catalog_state.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../widgets/catalog_forms.dart';
import 'category_products_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CatalogCubit>()..loadCategories()),
        BlocProvider(create: (_) => sl<ProfileCubit>()..loadProfile()),
        BlocProvider(create: (_) => sl<HomeCubit>()),
        BlocProvider(create: (_) => sl<OrdersCubit>()..loadOrders()),
      ],
      child: BlocListener<HomeCubit, HomeState>(
        listenWhen: (previous, current) => current.notice != null,
        listener: (context, state) => _showMessage(context, state.notice!),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.backgroundGrey,
            body: SafeArea(
              child: Column(
                children: [
                  const _HomeHeader(),
                  Expanded(
                    child: BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) => IndexedStack(
                        index: state.selectedTab,
                        children: const [
                          CategoriesPage(),
                          OrdersPage(),
                          ProfilePage(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => NavigationBar(
                selectedIndex: state.selectedTab,
                onDestinationSelected: context.read<HomeCubit>().selectTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.grid_view_rounded),
                    selectedIcon: Icon(Icons.grid_view_rounded),
                    label: 'Categories',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long_rounded),
                    label: 'Orders',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final user = state.user;
        final image = user?.image;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primaryPale,
                backgroundImage: _imageProvider(image),
                child: image == null || image.isEmpty
                    ? const Icon(Icons.person, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back',
                      style: TextStyle(fontSize: 13, color: AppColors.grey),
                    ),
                    Text(
                      user?.name.isNotEmpty == true
                          ? user!.name
                          : 'Store Admin',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: context.read<HomeCubit>().openNotifications,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                ),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  Future<void> _openForm(
    BuildContext context, [
    CatalogCategory? category,
  ]) async {
    final changed = await showCategoryForm(
      context,
      context.read<CatalogCubit>(),
      category: category,
    );
    if (changed && context.mounted) _showMessage(context, 'Category saved.');
  }

  Future<void> _delete(BuildContext context, CatalogCategory category) async {
    final confirmed = await confirmCatalogDelete(
      context,
      title: 'Delete category',
      message:
          'Delete "${category.name}"? Categories with products cannot be deleted.',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await context.read<CatalogCubit>().deleteCategory(category.id);
      if (context.mounted) _showMessage(context, 'Category deleted.');
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, error.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      'Store categories',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select a category to view and manage its products',
                      style: TextStyle(color: AppColors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add_rounded, size: 19),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: BlocBuilder<CatalogCubit, CatalogState>(
              builder: (context, state) {
                if (state.categoriesLoading && state.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.categoriesError != null && state.categories.isEmpty) {
                  return _ErrorView(
                    message: state.categoriesError!,
                    onRetry: () =>
                        context.read<CatalogCubit>().loadCategories(),
                  );
                }
                if (state.categories.isEmpty) {
                  return _EmptyView(
                    icon: Icons.category_outlined,
                    title: 'No categories yet',
                    message: 'Add your first category to manage your store.',
                    onRefresh: () =>
                        context.read<CatalogCubit>().loadCategories(),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      context.read<CatalogCubit>().loadCategories(),
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: columns == 2 ? 0.96 : 1.08,
                        ),
                        itemCount: state.categories.length,
                        itemBuilder: (context, index) {
                          final category = state.categories[index];
                          return _CategoryCard(
                            category: category,
                            imageRevision: state.categoryImageRevision,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) =>
                                      sl<CatalogCubit>()
                                        ..loadProducts(category.id),
                                  child: CategoryProductsPage(
                                    category: category,
                                  ),
                                ),
                              ),
                            ),
                            onEdit: () => _openForm(context, category),
                            onDelete: () => _delete(context, category),
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
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.imageRevision,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final CatalogCategory category;
  final int imageRevision;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final image = category.image;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
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
                            Icons.category_rounded,
                            color: AppColors.primary,
                            size: 48,
                          ),
                        )
                      : Image.network(
                            _resolveCategoryImage(image, imageRevision),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: AppColors.primaryPale,
                            child: Icon(
                              Icons.category_rounded,
                              color: AppColors.primary,
                              size: 48,
                            ),
                          ),
                        ),
                  Positioned(
                    top: 7,
                    left: 7,
                    child: Row(
                      children: [
                        _RoundAction(icon: Icons.edit_outlined, onTap: onEdit),
                        const SizedBox(width: 5),
                        _RoundAction(
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
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.notice != null) _showMessage(context, state.notice!);
      },
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return _ErrorView(
            message: state.error!,
            onRetry: () => context.read<ProfileCubit>().loadProfile(),
          );
        }
        final user = state.user;
        final name = user?.name;
        final email = user?.email;
        final image = user?.image;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'My profile',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.primaryPale,
                    backgroundImage: _imageProvider(image),
                    child: image == null || image.isEmpty
                        ? const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 45,
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name == null || name.isEmpty ? 'Store Admin' : name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email == null || email.isEmpty ? '—' : email,
                    style: const TextStyle(color: AppColors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  _ProfileInfo(
                    icon: Icons.badge_outlined,
                    title: 'Name',
                    value: name == null || name.isEmpty
                        ? 'Not available'
                        : name,
                  ),
                  _ProfileInfo(
                    icon: Icons.email_outlined,
                    title: 'Email address',
                    value: email == null || email.isEmpty
                        ? 'Not available'
                        : email,
                  ),
                  _ProfileInfo(
                    icon: Icons.phone_outlined,
                    title: 'Phone number',
                    value: user?.phone ?? 'Not available',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: context
                          .read<ProfileCubit>()
                          .requestProfileEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit profile'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(color: AppColors.grey)),
      subtitle: Text(
        value.isEmpty ? 'Not available' : value,
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

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
          const Text('Unable to load data'),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRefresh,
  });

  final IconData icon;
  final String title;
  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 90),
          Icon(icon, color: AppColors.primaryLight, size: 55),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

ImageProvider<Object>? _imageProvider(String? path) {
  if (path == null || path.isEmpty || path == 'null') return null;
  return NetworkImage(_resolveImage(path));
}

String _resolveImage(String path) {
  final imagePath = path.trim();
  if (Uri.tryParse(imagePath)?.hasScheme == true) return imagePath;
  final relativePath = imagePath.replaceFirst(RegExp(r'^/+'), '');
  if (relativePath.startsWith('upload/')) {
    return '${ApiConstants.Api}/$relativePath';
  }
  return '${ApiConstants.rimages}/$relativePath';
}

String _resolveCategoryImage(String path, int revision) {
  final imagePath = path.trim();
  final imageUrl = Uri.tryParse(imagePath)?.hasScheme == true
      ? imagePath
      : _resolveRelativeCategoryImage(imagePath);
  return Uri.parse(imageUrl)
      .replace(
        queryParameters: {
          ...Uri.parse(imageUrl).queryParameters,
          'image_revision': '$revision',
        },
      )
      .toString();
}

String _resolveRelativeCategoryImage(String path) {
  final relativePath = path.replaceFirst(RegExp(r'^/+'), '');
  if (relativePath.startsWith('upload/')) {
    return '${ApiConstants.Api}/$relativePath';
  }
  if (relativePath.startsWith('image/')) {
    return '${ApiConstants.Api}/$relativePath';
  }
  if (relativePath.startsWith('categories/')) {
    return '${ApiConstants.Api}/upload/$relativePath';
  }
  return '${ApiConstants.rimages}/$relativePath';
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
