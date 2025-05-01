import 'package:flutter/foundation.dart';
import 'order_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  accepted,
  packed,
  dispatched,
  delivered,
  completed,
  cancelled,
  refunded,
}

class Order {
  final String id;
  final String userId;
  final String hawkerId;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deliveryAddress;
  final String? notes;
  final bool isRated;
  final num rating;
  
  Order({
    required this.id,
    required this.userId,
    required this.hawkerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deliveryAddress,
    this.notes,
    this.isRated = false,
    this.rating = 0,
  });
  
  factory Order.fromJson(Map<String, dynamic> json) {
    // Parse items
    List<OrderItem> items = [];
    if (json['items'] != null) {
      for (var item in json['items']) {
        items.add(OrderItem.fromJson(item));
      }
    } else if (json['order_items'] != null) {
      for (var item in json['order_items']) {
        items.add(OrderItem.fromJson(item));
      }
    }
    
    // Parse status
    OrderStatus status;
    if (json['status'] is String) {
      switch (json['status'].toString().toLowerCase()) {
        case 'pending': status = OrderStatus.pending; break;
        case 'confirmed': status = OrderStatus.confirmed; break;
        case 'accepted': status = OrderStatus.accepted; break;
        case 'packed': status = OrderStatus.packed; break;
        case 'dispatched': status = OrderStatus.dispatched; break;
        case 'delivered': status = OrderStatus.delivered; break;
        case 'completed': status = OrderStatus.completed; break;
        case 'cancelled': status = OrderStatus.cancelled; break;
        case 'refunded': status = OrderStatus.refunded; break;
        default: status = OrderStatus.pending;
      }
    } else {
      status = OrderStatus.pending;
    }
    
    return Order(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      hawkerId: json['hawker_id'] ?? '',
      items: items,
      totalAmount: json['total_amount'] is num 
        ? (json['total_amount'] as num).toDouble() 
        : 0.0,
      status: status,
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : DateTime.now(),
      deliveryAddress: json['delivery_address'] ?? '',
      notes: json['notes'],
      isRated: json['is_rated'] ?? false,
      rating: json['rating'] ?? 0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hawker_id': hawkerId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'delivery_address': deliveryAddress,
      'notes': notes,
      'is_rated': isRated,
      'rating': rating,
    };
  }
  
  Order copyWith({
    String? id,
    String? userId,
    String? hawkerId,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deliveryAddress,
    String? notes,
    bool? isRated,
    num? rating,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hawkerId: hawkerId ?? this.hawkerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      isRated: isRated ?? this.isRated,
      rating: rating ?? this.rating,
    );
  }
} 