class OrderItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String unit;
  final double? totalPrice;
  final double? negotiatedPrice;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.unit,
    this.totalPrice,
    this.negotiatedPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      unit: json['unit'] ?? 'unit',
      totalPrice: (json['total_price'] is num) 
        ? (json['total_price'] as num).toDouble() 
        : null,
      negotiatedPrice: (json['negotiated_price'] is num)
        ? (json['negotiated_price'] as num).toDouble()
        : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'unit': unit,
      'total_price': totalPrice ?? (price * quantity),
      'negotiated_price': negotiatedPrice,
    };
  }
} 