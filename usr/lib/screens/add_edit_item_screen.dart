import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final InventoryItem? item;

  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inventoryService = InventoryService();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _categoryController;
  late TextEditingController _skuController;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '0');
    _priceController = TextEditingController(text: widget.item?.price.toString() ?? '0.00');
    _categoryController = TextEditingController(text: widget.item?.category ?? '');
    _skuController = TextEditingController(text: widget.item?.sku ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _skuController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final name = _nameController.text;
      final description = _descriptionController.text;
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final category = _categoryController.text;
      final sku = _skuController.text;

      try {
        if (widget.item != null) {
          // Update existing
          final updatedItem = widget.item!.copyWith(
            name: name,
            description: description,
            quantity: quantity,
            price: price,
            category: category,
            sku: sku,
          );
          await _inventoryService.updateItem(updatedItem);
        } else {
          // Create new
          // Note: In a real app, use a proper UUID generator. 
          // Since we don't have the uuid package in pubspec yet, we'll use a simple timestamp.
          final newItem = InventoryItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            description: description,
            quantity: quantity,
            price: price,
            category: category,
            sku: sku,
          );
          await _inventoryService.addItem(newItem);
        }
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.item != null ? 'Item updated' : 'Item added')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving item: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Item' : 'Add New Item'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter item name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skuController,
                            decoration: const InputDecoration(
                              labelText: 'SKU',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.qr_code),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _categoryController,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.category),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter category';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter quantity';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid price';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    FilledButton.icon(
                      onPressed: _saveItem,
                      icon: const Icon(Icons.save),
                      label: Text(isEditing ? 'Update Item' : 'Save Item'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
