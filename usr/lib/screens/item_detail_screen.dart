import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';
import 'add_edit_item_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final InventoryItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final InventoryService _inventoryService = InventoryService();
  late InventoryItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${_item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _inventoryService.deleteItem(_item.id);
      if (mounted) {
        Navigator.pop(context); // Go back to list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted')),
        );
      }
    }
  }

  Future<void> _adjustStock(int amount) async {
    final newQuantity = _item.quantity + amount;
    if (newQuantity < 0) return;

    final updatedItem = _item.copyWith(quantity: newQuantity);
    await _inventoryService.updateItem(updatedItem);
    setState(() {
      _item = updatedItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditItemScreen(item: _item),
                ),
              );
              // Refresh item data after edit (in a real app, we might stream this)
              // For now, we rely on the service updating the list, but we need to update local state if we want this screen to reflect changes immediately without re-fetching from list
              // A better way is to listen to the stream or re-fetch.
              // Let's just pop back to home for simplicity or re-fetch if we had a getById method.
              // Since we are passing the item object, let's just rely on the user going back or we could implement a refresh.
              // Actually, let's just pop to home to see the updated list.
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.inventory_2, size: 64, color: Colors.deepPurple),
                    const SizedBox(height: 16),
                    Text(
                      _item.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(_item.category),
                      backgroundColor: Colors.deepPurple.shade50,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildDetailRow(context, 'Price', '\$${_item.price.toStringAsFixed(2)}'),
            const Divider(),
            _buildDetailRow(context, 'Quantity', '${_item.quantity}'),
            const Divider(),
            _buildDetailRow(context, 'SKU', _item.sku),
            const Divider(),
            const SizedBox(height: 16),
            
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _item.description.isNotEmpty ? _item.description : 'No description provided.',
              style: const TextStyle(fontSize: 16),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Quick Stock Adjustment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStockButton(Icons.remove, -1, Colors.red),
                _buildStockButton(Icons.add, 1, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStockButton(IconData icon, int amount, Color color) {
    return ElevatedButton.icon(
      onPressed: () => _adjustStock(amount),
      icon: Icon(icon),
      label: Text(amount > 0 ? 'Add Stock' : 'Remove Stock'),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
