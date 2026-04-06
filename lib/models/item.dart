class Item {
  final String? id;
  final String name;
  final String category;
  final int quantity;
  final double price;

  Item({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'quantity': quantity,
    'price': price,
  };

  factory Item.fromMap(String id, Map<String, dynamic> map) => Item(
    id: id,
    name: map['name'] ?? '',
    category: map['category'] ?? '',
    quantity: (map['quantity'] ?? 0).toInt(),
    price: (map['price'] ?? 0.0).toDouble(),
  );
}