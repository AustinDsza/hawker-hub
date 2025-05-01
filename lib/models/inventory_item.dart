class InventoryItem {
  String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool available;
  final int quantity;
  final String unit;

  InventoryItem({
    required this.id,
    required this.name,
    required this.description, 
    required this.price,
    required this.category,
    this.imageUrl,
    this.available = true,
    this.quantity = 0,
    this.unit = 'item',
  });

  // Convert a JSON object to an InventoryItem
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? 'Other',
      imageUrl: json['image_url'],
      available: json['available'] ?? true,
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? 'item',
    );
  }

  // Convert an InventoryItem to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'available': available,
      'quantity': quantity,
      'unit': unit,
    };
  }

  // Create a copy of this InventoryItem with the given fields replaced with new values
  InventoryItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? available,
    int? quantity,
    String? unit,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      available: available ?? this.available,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
} 