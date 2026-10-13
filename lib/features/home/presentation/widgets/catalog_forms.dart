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
  final fields = <String, TextEditingController>{
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
  File? image;
  final formKey = GlobalKey<FormState>();
  var saving = false;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => Directionality(
        textDirection: TextDirection.ltr,
        child: AlertDialog(
          title: Text(product == null ? 'Add product' : 'Edit product'),
          content: SizedBox(
            width: 480,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FormField(
                      controller: fields['arabicName']!,
                      label: 'Product name (Arabic)',
                      required: true,
                    ),
                    _FormField(
                      controller: fields['name']!,
                      label: 'Product name (English)',
                      required: true,
                    ),
                    _FormField(
                      controller: fields['price']!,
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
                      controller: fields['count']!,
                      label: 'Stock quantity',
                      keyboardType: TextInputType.number,
                    ),
                    _FormField(
                      controller: fields['arabicDescription']!,
                      label: 'Description (Arabic)',
                      maxLines: 2,
                    ),
                    _FormField(
                      controller: fields['description']!,
                      label: 'Description (English)',
                      maxLines: 2,
                    ),
                    _FormField(
                      controller: fields['arabicColor']!,
                      label: 'Color (Arabic)',
                    ),
                    _FormField(
                      controller: fields['color']!,
                      label: 'Color (English)',
                    ),
                    _FormField(
                      controller: fields['arabicLocation']!,
                      label: 'Location (Arabic)',
                    ),
                    _FormField(
                      controller: fields['location']!,
                      label: 'Location (English)',
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 82,
                        );
                        if (picked != null) {
                          setState(() => image = File(picked.path));
                        }
                      },
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(
                        image == null
                            ? (product == null
                                  ? 'Choose product image'
                                  : 'Change product image (optional)')
                            : 'Image selected',
                      ),
                    ),
                    if (product == null && image == null)
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
              onPressed: saving ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      if (product == null && image == null) return;
                      final count = int.tryParse(fields['count']!.text.trim());
                      if (count == null || count < 0) {
                        _showFormError(
                          dialogContext,
                          'Enter a valid quantity of zero or more.',
                        );
                        return;
                      }
                      setState(() => saving = true);
                      try {
                        final name = fields['name']!.text.trim();
                        final arabicName = fields['arabicName']!.text.trim();
                        final price = fields['price']!.text.trim();
                        final description = fields['description']!.text.trim();
                        final arabicDescription = fields['arabicDescription']!
                            .text
                            .trim();
                        final color = fields['color']!.text.trim();
                        final arabicColor = fields['arabicColor']!.text.trim();
                        final location = fields['location']!.text.trim();
                        final arabicLocation = fields['arabicLocation']!.text
                            .trim();
                        if (product == null) {
                          await cubit.addProduct(
                            categoryId: categoryId,
                            name: name,
                            arabicName: arabicName,
                            price: price,
                            description: description,
                            arabicDescription: arabicDescription,
                            count: count,
                            color: color,
                            arabicColor: arabicColor,
                            location: location,
                            arabicLocation: arabicLocation,
                            image: image!,
                          );
                        } else {
                          await cubit.updateProduct(
                            id: product.id,
                            categoryId: categoryId,
                            name: name,
                            arabicName: arabicName,
                            price: price,
                            description: description,
                            arabicDescription: arabicDescription,
                            count: count,
                            color: color,
                            arabicColor: arabicColor,
                            location: location,
                            arabicLocation: arabicLocation,
                            image: image,
                          );
                        }
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } catch (error) {
                        if (dialogContext.mounted) {
                          setState(() => saving = false);
                          _showFormError(dialogContext, error);
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(product == null ? 'Add' : 'Save changes'),
            ),
          ],
        ),
      ),
    ),
  );
  for (final controller in fields.values) {
    controller.dispose();
  }
  return result ?? false;
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
