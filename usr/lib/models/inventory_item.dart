class InventoryItem {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String category;
  final String sku;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.category,
    required this.sku,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? description,
    int? quantity,
    double? price,
    String? category,
    String? sku,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      category: category ?? this.category,
      sku: sku ?? this.sku,
    );
  }
}
