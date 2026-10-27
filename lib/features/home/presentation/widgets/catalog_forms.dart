import 'dart:io';

import 'package:adminapp/core/constants/app_color/Colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/catalog_cubit.dart';
import '../../domain/entities/catalog_entities.dart';

Future<bool> showCategoryForm(
  BuildContext context,
  CatalogCubit cubit, {
  CatalogCategory? category,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => _CategoryFormDialog(cubit: cubit, category: category),
      ) ??
      false;
}

class _CategoryFormDialog extends StatefulWidget {
  const _CategoryFormDialog({required this.cubit, this.category});

  final CatalogCubit cubit;
  final CatalogCategory? category;

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _arabicName;
  final _formKey = GlobalKey<FormState>();
  File? _image;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category?.name);
    _arabicName = TextEditingController(text: widget.category?.arabicName);
  }

  @override
  void dispose() {
    _name.dispose();
    _arabicName.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );
    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final category = widget.category;
    if (category == null && _image == null) return;

    setState(() => _saving = true);
    try {
      if (category == null) {
        await widget.cubit.addCategory(
          name: _name.text.trim(),
          arabicName: _arabicName.text.trim(),
          image: _image!,
        );
      } else {
        await widget.cubit.updateCategory(
          id: category.id,
          name: _name.text.trim(),
          arabicName: _arabicName.text.trim(),
          image: _image,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        _showFormError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AlertDialog(
        title: Text(category == null ? 'Add category' : 'Edit category'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FormField(
                    controller: _arabicName,
                    label: 'Category name (Arabic)',
                    required: true,
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    controller: _name,
                    label: 'Category name (English)',
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      _image == null
                          ? (category == null
                                ? 'Choose category image'
                                : 'Change category image (optional)')
                          : 'Image selected',
                    ),
                  ),
                  if (category == null && _image == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'A category image is required.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(category == null ? 'Add' : 'Save changes'),
          ),
        ],
      ),
    );
  }
}

Future<bool> showProductForm(
  BuildContext context,
  CatalogCubit cubit, {
  required int categoryId,
  CatalogProduct? product,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => _ProductFormDialog(
          cubit: cubit,
          categoryId: categoryId,
          product: product,
        ),
      ) ??
      false;
}

class _ProductFormDialog extends StatefulWidget {
  const _ProductFormDialog({
    required this.cubit,
    required this.categoryId,
    this.product,
  });

  final CatalogCubit cubit;
  final int categoryId;
  final CatalogProduct? product;

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  late final Map<String, TextEditingController> _fields;
  final _formKey = GlobalKey<FormState>();
  File? _image;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _fields = {
      'name': TextEditingController(text: product?.name),
      'arabicName': TextEditingController(text: product?.arabicName),
      'price': TextEditingController(text: product?.price),
      'description': TextEditingController(text: product?.description),
      'arabicDescription': TextEditingController(
        text: product?.arabicDescription,
      ),
      'count': TextEditingController(text: product?.count.toString() ?? '0'),
      'color': TextEditingController(text: product?.color),
      'arabicColor': TextEditingController(text: product?.arabicColor),
      'location': TextEditingController(text: product?.location),
      'arabicLocation': TextEditingController(text: product?.arabicLocation),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );
    if (picked != null && mounted) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> _save() async {
    final product = widget.product;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (product == null && _image == null) return;

    final count = int.tryParse(_fields['count']!.text.trim());
    if (count == null || count < 0) {
      _showFormError(context, 'Enter a valid quantity of zero or more.');
      return;
    }

    setState(() => _saving = true);
    try {
      final values = {
        'name': _fields['name']!.text.trim(),
        'arabicName': _fields['arabicName']!.text.trim(),
        'price': _fields['price']!.text.trim(),
        'description': _fields['description']!.text.trim(),
        'arabicDescription': _fields['arabicDescription']!.text.trim(),
        'color': _fields['color']!.text.trim(),
        'arabicColor': _fields['arabicColor']!.text.trim(),
        'location': _fields['location']!.text.trim(),
        'arabicLocation': _fields['arabicLocation']!.text.trim(),
      };

      if (product == null) {
        await widget.cubit.addProduct(
          categoryId: widget.categoryId,
          name: values['name']!,
          arabicName: values['arabicName']!,
          price: values['price']!,
          description: values['description']!,
          arabicDescription: values['arabicDescription']!,
          count: count,
          color: values['color']!,
          arabicColor: values['arabicColor']!,
          location: values['location']!,
          arabicLocation: values['arabicLocation']!,
          image: _image!,
        );
      } else {
        await widget.cubit.updateProduct(
          id: product.colorVariantId,
          categoryId: widget.categoryId,
          name: values['name']!,
          arabicName: values['arabicName']!,
          price: values['price']!,
          description: values['description']!,
          arabicDescription: values['arabicDescription']!,
          count: count,
          color: values['color']!,
          arabicColor: values['arabicColor']!,
          location: values['location']!,
          arabicLocation: values['arabicLocation']!,
          image: _image,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        _showFormError(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AlertDialog(
        title: Text(product == null ? 'Add product' : 'Edit product'),
        content: SizedBox(
          width: 480,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FormField(
                    controller: _fields['arabicName']!,
                    label: 'Product name (Arabic)',
                    required: true,
                  ),
                  _FormField(
                    controller: _fields['name']!,
                    label: 'Product name (English)',
                    required: true,
                  ),
                  _FormField(
                    controller: _fields['price']!,
                    label: 'Price',
                    required: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final price = num.tryParse(value?.trim() ?? '');
                      return price == null || price <= 0
                          ? 'Enter a valid price greater than zero.'
                          : null;
                    },
                  ),
                  _FormField(
                    controller: _fields['count']!,
                    label: 'Stock quantity',
                    keyboardType: TextInputType.number,
                  ),
                  _FormField(
                    controller: _fields['arabicDescription']!,
                    label: 'Description (Arabic)',
                    maxLines: 2,
                  ),
                  _FormField(
                    controller: _fields['description']!,
                    label: 'Description (English)',
                    maxLines: 2,
                  ),
                  _FormField(
                    controller: _fields['arabicColor']!,
                    label: 'Color (Arabic)',
                  ),
                  _FormField(
                    controller: _fields['color']!,
                    label: 'Color (English)',
                  ),
                  _FormField(
                    controller: _fields['arabicLocation']!,
                    label: 'Location (Arabic)',
                  ),
                  _FormField(
                    controller: _fields['location']!,
                    label: 'Location (English)',
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      _image == null
                          ? (product == null
                                ? 'Choose product image'
                                : 'Change product image (optional)')
                          : 'Image selected',
                    ),
                  ),
                  if (product == null && _image == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'A product image is required.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(product == null ? 'Add' : 'Save changes'),
          ),
        ],
      ),
    );
  }
}

Future<bool> confirmCatalogDelete(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.ltr,
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      ) ??
      false;
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.required = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool required;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppColors.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        validator:
            validator ??
            (required
                ? (value) => value == null || value.trim().isEmpty
                      ? 'This field is required'
                      : null
                : null),
      ),
    );
  }
}

void _showFormError(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red.shade700,
    ),
  );
}
