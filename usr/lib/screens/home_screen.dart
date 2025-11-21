import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/inventory_service.dart';
import 'add_edit_item_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<InventoryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
    // Listen for updates
    _inventoryService.itemsStream.listen((items) {
      if (mounted) {
        setState(() {
          _items = items;
        });
      }
    });
  }

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);
    final items = await _inventoryService.getItems();
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No items in inventory'))
              : ListView.builder(
                  itemCount: _items.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getCategoryColor(item.category),
                          child: Text(
                            item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Qty: ${item.quantity} | ${item.category}'),
                        trailing: Text(
                          '\$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailScreen(item: item),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditItemScreen(),
            ),
          );
        },
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Colors.blue;
      case 'furniture':
        return Colors.brown;
      case 'clothing':
        return Colors.pink;
      case 'food':
        return Colors.green;
      default:
        return Colors.deepPurple;
    }
  }
}
