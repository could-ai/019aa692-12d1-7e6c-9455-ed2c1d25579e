import 'dart:async';
import '../models/inventory_item.dart';

class InventoryService {
  // Singleton instance
  static final InventoryService _instance = InventoryService._internal();
  factory InventoryService() => _instance;
  InventoryService._internal();

  // Mock data
  final List<InventoryItem> _items = [
    InventoryItem(
      id: '1',
      name: 'Laptop',
      description: 'High performance laptop',
      quantity: 15,
      price: 1200.00,
      category: 'Electronics',
      sku: 'ELEC-001',
    ),
    InventoryItem(
      id: '2',
      name: 'Office Chair',
      description: 'Ergonomic office chair',
      quantity: 50,
      price: 150.00,
      category: 'Furniture',
      sku: 'FURN-001',
    ),
    InventoryItem(
      id: '3',
      name: 'Wireless Mouse',
      description: 'Bluetooth wireless mouse',
      quantity: 100,
      price: 25.00,
      category: 'Electronics',
      sku: 'ELEC-002',
    ),
  ];

  // Stream controller to broadcast changes
  final _itemsController = StreamController<List<InventoryItem>>.broadcast();
  Stream<List<InventoryItem>> get itemsStream => _itemsController.stream;

  Future<List<InventoryItem>> getItems() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_items);
  }

  Future<void> addItem(InventoryItem item) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _items.add(item);
    _itemsController.add(List.from(_items));
  }

  Future<void> updateItem(InventoryItem updatedItem) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      _itemsController.add(List.from(_items));
    }
  }

  Future<void> deleteItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _items.removeWhere((item) => item.id == id);
    _itemsController.add(List.from(_items));
  }
}
