import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uniperks/models/product.dart';
import 'package:uniperks/services/product_service.dart';
import 'package:uniperks/services/storage_service.dart';

class AdminProductUploadPage extends StatefulWidget {
  final Product? product;

  const AdminProductUploadPage({super.key, this.product});

  @override
  State<AdminProductUploadPage> createState() => _AdminProductUploadPageState();
}

class _AdminProductUploadPageState extends State<AdminProductUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _imageUrlController = TextEditingController();

  List<String> _categories = [];
  String? _selectedCategory;
  bool _loadingCategories = true;
  bool _submitting = false;
  String? _formError;

  XFile? _pickedImage;
  Uint8List? _previewBytes;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _priceController.text = product.price.toStringAsFixed(2);
      _discountController.text = product.discount.toString();
      _imageUrlController.text = product.imageUrl;
      _selectedCategory = product.category;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await ProductService.getCategories();
    final filtered = categories.where((c) => c != 'All').toList();

    if (filtered.isEmpty) {
      filtered.addAll([
        'Clothing',
        'Accessories',
        'Stationery',
        'Books',
        'Electronics',
      ]);
    }

    if (widget.product != null &&
        widget.product!.category.isNotEmpty &&
        !filtered.contains(widget.product!.category)) {
      filtered.insert(0, widget.product!.category);
    }

    setState(() {
      _categories = filtered;
      _selectedCategory = _selectedCategory ?? filtered.first;
      _loadingCategories = false;
    });
  }

  Future<void> _pickImage() async {
    setState(() {
      _formError = null;
    });
    final ImagePicker picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      setState(() {
        _pickedImage = file;
        _previewBytes = bytes;
        _imageUrlController.clear();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to pick image: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      setState(() {
        _formError = 'Please select a category.';
      });
      return;
    }

    String imageUrl = _imageUrlController.text.trim();
    if (_pickedImage == null && imageUrl.isEmpty) {
      final existing = widget.product?.imageUrl ?? '';
      if (existing.isEmpty) {
        setState(() {
          _formError =
              'Please provide either an image URL or pick a photo from the gallery.';
        });
        return;
      }
      imageUrl = existing;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _submitting = true;
      _formError = null;
    });

    try {
      if (_pickedImage != null) {
        final uploadedUrl = await StorageService.uploadProductImage(
          _pickedImage!,
        );
        if (uploadedUrl == null || uploadedUrl.isEmpty) {
          throw StorageUploadException('Unable to upload image to storage.');
        }
        imageUrl = uploadedUrl;
      }

      if (imageUrl.isEmpty) {
        throw StorageUploadException('Image URL could not be determined.');
      }

      final parsedPrice = double.tryParse(_priceController.text.trim());
      if (parsedPrice == null) {
        throw ArgumentError('Invalid price value.');
      }

      int discount = int.tryParse(_discountController.text.trim()) ?? 0;
      if (discount < 0) discount = 0;
      if (discount > 100) discount = 100;

      final product = Product(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: parsedPrice,
        imageUrl: imageUrl,
        category: _selectedCategory!,
        discount: discount,
      );

      bool success;
      if (widget.product == null) {
        success = await ProductService.addProduct(product);
      } else {
        success = await ProductService.updateProduct(product.id!, product);
      }

      if (!mounted) return;

      if (success) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        throw Exception('Unable to save product. Please try again.');
      }
    } on StorageUploadException catch (error) {
      setState(() {
        _formError = error.message;
      });
    } catch (error) {
      setState(() {
        _formError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _pickedImage = null;
      _previewBytes = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a product name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (RM)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid price.';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return null;
                        }
                        final parsed = int.tryParse(value);
                        if (parsed == null || parsed < 0 || parsed > 100) {
                          return '0 - 100 only.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _loadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
              const SizedBox(height: 24),
              Text(
                'Product Image',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  hintText: 'https://example.com/image.jpg',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _submitting ? null : _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick from Gallery'),
                  ),
                  if (_pickedImage != null) ...[
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _submitting ? null : _removeSelectedImage,
                      icon: const Icon(Icons.close),
                      label: const Text('Remove'),
                    ),
                  ],
                ],
              ),
              if (_pickedImage != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Selected: ${_pickedImage!.name}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 12),
              _buildImagePreview(),
              if (_formError != null) ...[
                const SizedBox(height: 16),
                Text(_formError!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isEditing ? 'Update Product' : 'Create Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null && _previewBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb
            ? Image.memory(
                _previewBytes!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : Image.memory(
                _previewBytes!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
      );
    }

    final existingUrl = _imageUrlController.text.trim().isNotEmpty
        ? _imageUrlController.text.trim()
        : widget.product?.imageUrl ?? '';
    if (existingUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        existingUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 160,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('Unable to load preview'),
        ),
      ),
    );
  }
}
