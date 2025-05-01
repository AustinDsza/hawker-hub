import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'inventory_item.dart';

class Hawker {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final LatLng location;
  final bool isOpen;
  final double rating;
  final int totalRatings;
  final String? profileImage;
  final List<InventoryItem> inventory;
  final double distanceFromUser;

  Hawker({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.location,
    required this.isOpen,
    required this.rating,
    required this.totalRatings,
    this.profileImage,
    required this.inventory,
    required this.distanceFromUser,
  });

  factory Hawker.fromJson(Map<String, dynamic> json, {double distance = 0.0}) {
    // Parse location from JSON
    final double lat = json['latitude'] != null ? double.parse(json['latitude'].toString()) : 0.0;
    final double lng = json['longitude'] != null ? double.parse(json['longitude'].toString()) : 0.0;
    
    // Parse inventory or use empty list if null
    final List<InventoryItem> inventoryList = [];
    if (json['inventory'] != null) {
      if (json['inventory'] is List) {
        inventoryList.addAll(
          (json['inventory'] as List).map((item) => InventoryItem.fromJson(item)).toList()
        );
      } else if (json['inventory'] is Map) {
        // Handle case where inventory might be a map of items
        final Map<String, dynamic> invMap = json['inventory'] as Map<String, dynamic>;
        invMap.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            final item = InventoryItem.fromJson(value);
            if (!item.id.isNotEmpty) {
              item.id = key;
            }
            inventoryList.add(item);
          }
        });
      }
    }
    
    return Hawker(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Hawker',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? 'No address provided',
      location: LatLng(lat, lng),
      isOpen: json['is_open'] ?? true,
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 4.0,
      totalRatings: json['total_ratings'] ?? 0,
      profileImage: json['profile_image'],
      inventory: inventoryList,
      distanceFromUser: distance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'rating': rating,
      'total_ratings': totalRatings,
      'is_open': isOpen,
      'inventory': inventory.map((e) => e.toJson()).toList(),
      'profile_image': profileImage,
    };
  }

  Hawker copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    LatLng? location,
    bool? isOpen,
    double? rating,
    int? totalRatings,
    String? profileImage,
    List<InventoryItem>? inventory,
    double? distanceFromUser,
  }) {
    return Hawker(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      location: location ?? this.location,
      isOpen: isOpen ?? this.isOpen,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      profileImage: profileImage ?? this.profileImage,
      inventory: inventory ?? this.inventory,
      distanceFromUser: distanceFromUser ?? this.distanceFromUser,
    );
  }

  // Get a formatted distance string
  String get formattedDistance {
    if (distanceFromUser < 1) {
      // Convert to meters if less than 1 km
      final meters = (distanceFromUser * 1000).round();
      return '$meters m';
    } else {
      // Show kilometers with one decimal place
      return '${distanceFromUser.toStringAsFixed(1)} km';
    }
  }
} 