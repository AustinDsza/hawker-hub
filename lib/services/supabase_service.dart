import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hawker.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/location.dart';
import '../models/inventory_item.dart';
import 'dart:math' show Random, pi, sin, cos, asin, atan2;

class SupabaseService {
  // Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Get the Supabase client
  final supabase = Supabase.instance.client;

  // Auth methods
  Future<Map<String, dynamic>?> signUp(String email, String password, String name, String role, {String? phone}) async {
    try {
      // Create the user in Supabase Auth
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (res.user == null) return null;
      
      // Add user data to users table
      await supabase.from('users').insert({
        'id': res.user!.id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
      });
      
      // If hawker, create hawker entry too
      if (role == 'hawker') {
        await supabase.from('hawkers').insert({
          'id': res.user!.id,
          'name': name,
          'email': email,
          'phone': phone,
          'is_verified': false,
        });
      }

      // Return user data as Map
      return {
        'id': res.user!.id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
      };
    } catch (e) {
      debugPrint('Error during signup: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      debugPrint('Attempting to sign in with email: $email');
      
      // Handle demo accounts specially
      if (password == 'password123') {
        if (email == 'user@example.com') {
          return {
            'id': 'demo-user-id',
            'name': 'Demo User',
            'email': email,
            'role': 'user',
          };
        } else if (email == 'hawker@example.com') {
          debugPrint('Using demo hawker account with role: hawker');
          return {
            'id': 'demo-hawker-id',
            'name': 'Demo Hawker',
            'email': email,
            'role': 'hawker',
            'phone': '+91987654321',
            'address': 'Street Food Complex, Block A'
          };
        } else if (email == 'admin@example.com') {
          return {
            'id': 'demo-admin-id',
            'name': 'Demo Admin',
            'email': email,
            'role': 'admin',
          };
        }
      }
      
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (res.user == null) {
        debugPrint('Sign in failed: User is null');
        return null;
      }
      
      debugPrint('Auth sign in successful for user ID: ${res.user!.id}');
      
      // Get user data including role
      try {
        final data = await supabase
          .from('users')
          .select()
          .eq('id', res.user!.id)
          .maybeSingle();
        
        if (data == null) {
          debugPrint('No user data found in users table, creating a new record');
          // Create basic user entry if it doesn't exist
          final newUserData = {
            'id': res.user!.id,
            'name': email.split('@')[0],
            'email': email,
            'role': email.contains('hawker') ? 'hawker' : 'user', // Ensure hawker emails get hawker role
          };
          
          await supabase.from('users').insert(newUserData);
          
          // If hawker, create hawker entry too
          if (email.contains('hawker')) {
            try {
              // Check if hawker record already exists
              final hawkerExists = await supabase
                .from('hawkers')
                .select('id')
                .eq('id', res.user!.id)
                .maybeSingle();
              
              if (hawkerExists == null) {
                await supabase.from('hawkers').insert({
                  'id': res.user!.id,
                  'name': email.split('@')[0],
                  'email': email,
                  'is_verified': false,
                  'location': {'latitude': 0.0, 'longitude': 0.0}
                });
                debugPrint('Created hawker record for ${res.user!.id}');
              }
            } catch (hawkerError) {
              debugPrint('Error creating hawker record: $hawkerError');
            }
          }
          
          return newUserData;
        }
          
        debugPrint('User data retrieved: ${data['role']}');
        
        // Ensure hawker role and hawker entry
        if (data['role'] == 'hawker') {
          try {
            // Check if hawker record exists
            final hawkerExists = await supabase
              .from('hawkers')
              .select('id')
              .eq('id', res.user!.id)
              .maybeSingle();
            
            if (hawkerExists == null) {
              // Create hawker entry if missing
              await supabase.from('hawkers').insert({
                'id': res.user!.id,
                'name': data['name'],
                'email': data['email'],
                'phone': data['phone'],
                'is_verified': false,
                'location': {'latitude': 0.0, 'longitude': 0.0}
              });
              debugPrint('Created missing hawker record for ${res.user!.id}');
            }
          } catch (hawkerError) {
            debugPrint('Error checking/creating hawker record: $hawkerError');
          }
        }
        
        return data;
      } catch (e) {
        debugPrint('Error retrieving user data: $e');
        // User exists in auth but not in the users table
        // Let's create a basic user entry
        final role = email.contains('hawker') ? 'hawker' : 'user';
        final newUserData = {
          'id': res.user!.id,
          'name': email.split('@')[0],
          'email': email,
          'role': role,
        };
        
        try {
          await supabase.from('users').insert(newUserData);
          
          // If hawker, create hawker entry too
          if (role == 'hawker') {
            try {
              await supabase.from('hawkers').insert({
                'id': res.user!.id,
                'name': email.split('@')[0],
                'email': email,
                'is_verified': false,
                'location': {'latitude': 0.0, 'longitude': 0.0}
              });
            } catch (hawkerError) {
              debugPrint('Error creating hawker record: $hawkerError');
            }
          }
          
          return newUserData;
        } catch (insertError) {
          debugPrint('Error creating user record: $insertError');
          // Return basic user data anyway to let the user in
          return newUserData;
        }
      }
    } catch (e) {
      debugPrint('Error during signin: $e');
      if (e.toString().contains('Email not confirmed')) {
        // Handle unconfirmed email specially
        throw Exception('Please check your email and confirm your account before logging in.');
      }
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) return null;
    
    try {
      final data = await supabase
        .from('users')
        .select()
        .eq('id', currentUser.id)
        .single();
        
      return data;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  // Hawker methods
  Future<List<Hawker>> getNearbyHawkers(Location userLocation, {double maxDistance = 10.0}) async {
    try {
      // For demo hawker account, provide demo nearby hawkers
      if (supabase.auth.currentUser?.email == 'hawker@example.com' || 
          supabase.auth.currentUser?.id == 'demo-hawker-id') {
        debugPrint('Returning dummy nearby hawkers data for demo account');
        return _getDummyHawkers(userLocation);
      }
      
      // For demo user account, provide demo nearby hawkers
      if (supabase.auth.currentUser?.email == 'user@example.com' || 
          supabase.auth.currentUser?.id == 'demo-user-id') {
        debugPrint('Returning dummy nearby hawkers data for demo user');
        return _getDummyHawkers(userLocation);
      }
      
      final data = await supabase
        .from('hawkers')
        .select('*, inventory(*)');
        
      List<Hawker> hawkers = [];
      
      for (final hawker in data) {
        // Parse location
        Location? hawkerLocation;
        if (hawker['location'] != null) {
          final Map<String, dynamic> locationData = hawker['location'];
          hawkerLocation = Location(
            locationData['latitude'] ?? 0.0,
            locationData['longitude'] ?? 0.0
          );
        } else {
          // Skip hawkers without location
          continue;
        }
        
        // Filter by distance
        double distance = userLocation.distanceTo(hawkerLocation);
        if (distance <= maxDistance) {
          // Create inventory items
          List<InventoryItem> inventoryItems = [];
          if (hawker['inventory'] != null) {
            for (final item in hawker['inventory']) {
              inventoryItems.add(InventoryItem(
                id: item['id'] ?? '',
                name: item['name'] ?? '',
                description: '',
                price: (item['price'] ?? 0).toDouble(),
                category: 'Other',
                quantity: (item['quantity'] ?? 0).toInt(),
                unit: item['unit'] ?? 'item',
                available: true,
              ));
            }
          }
          
          // Create hawker object
          hawkers.add(Hawker(
            id: hawker['id'],
            name: hawker['name'],
            email: hawker['email'],
            phone: hawker['phone'] ?? '',
            address: hawker['address'] ?? '',
            location: hawkerLocation.toLatLng(),
            isOpen: hawker['is_open'] ?? false,
            rating: hawker['rating'] ?? 0.0,
            totalRatings: hawker['total_ratings'] ?? 0,
            profileImage: hawker['profile_image'],
            inventory: inventoryItems,
            distanceFromUser: distance,
          ));
        }
      }
      
      // Sort by distance
      hawkers.sort((a, b) => a.distanceFromUser.compareTo(b.distanceFromUser));
      return hawkers;
    } catch (e) {
      debugPrint('Error getting nearby hawkers: $e');
      // Return dummy data in case of error
      return _getDummyHawkers(userLocation);
    }
  }
  
  Future<List<Hawker>> getUnverifiedHawkers() async {
    try {
      final data = await supabase
        .from('hawkers')
        .select('*')
        .eq('is_verified', false);
        
      List<Hawker> hawkers = [];
      
      for (final hawker in data) {
        Location? hawkerLocation;
        if (hawker['location'] != null) {
          final Map<String, dynamic> locationData = hawker['location'];
          hawkerLocation = Location(
            locationData['latitude'] ?? 0.0,
            locationData['longitude'] ?? 0.0
          );
        } else {
          // Default location for hawkers without one
          hawkerLocation = const Location(0.0, 0.0);
        }
        
        hawkers.add(Hawker(
          id: hawker['id'],
          name: hawker['name'],
          email: hawker['email'],
          phone: hawker['phone'] ?? '',
          address: hawker['address'] ?? '',
          location: hawkerLocation.toLatLng(),
          isOpen: hawker['is_open'] ?? false,
          rating: hawker['rating'] ?? 0.0,
          totalRatings: hawker['total_ratings'] ?? 0,
          profileImage: hawker['profile_image'],
          inventory: [],
          distanceFromUser: 0,
        ));
      }
      
      return hawkers;
    } catch (e) {
      debugPrint('Error getting unverified hawkers: $e');
      return [];
    }
  }
  
  Future<bool> verifyHawker(String hawkerId) async {
    try {
      await supabase
        .from('hawkers')
        .update({'is_verified': true})
        .eq('id', hawkerId);
      return true;
    } catch (e) {
      debugPrint('Error verifying hawker: $e');
      return false;
    }
  }
  
  Future<bool> rejectHawker(String hawkerId) async {
    try {
      // Delete the hawker
      await supabase.from('hawkers').delete().eq('id', hawkerId);
      
      // Update user role to regular user
      await supabase
        .from('users')
        .update({'role': 'user'})
        .eq('id', hawkerId);
        
      return true;
    } catch (e) {
      debugPrint('Error rejecting hawker: $e');
      return false;
    }
  }

  // Inventory Management
  Future<List<InventoryItem>> getInventoryItems(String hawkerId) async {
    try {
      final response = await supabase
          .from('inventory')
          .select()
          .eq('hawker_id', hawkerId);
      
      return (response as List)
          .map((item) => InventoryItem.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting inventory items: $e');
      return [];
    }
  }

  Future<void> addInventoryItem(String hawkerId, Map<String, dynamic> item) async {
    try {
      // Add item to the inventory table with hawker reference
      item['hawker_id'] = hawkerId;
      
      await supabase
        .from('inventory')
        .insert(item);
        
    } catch (e) {
      debugPrint('Error adding inventory item: $e');
      throw e;
    }
  }
  
  Future<void> updateInventoryItem(String itemId, Map<String, dynamic> item) async {
    try {
      await supabase
        .from('inventory')
        .update(item)
        .eq('id', itemId);
        
    } catch (e) {
      debugPrint('Error updating inventory item: $e');
      throw e;
    }
  }
  
  Future<void> deleteInventoryItem(String itemId) async {
    try {
      await supabase
        .from('inventory')
        .delete()
        .eq('id', itemId);
        
    } catch (e) {
      debugPrint('Error deleting inventory item: $e');
      throw e;
    }
  }
  
  // Order Management
  Future<Order> placeOrder({
    required String userId,
    required String hawkerId,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    String? notes,
  }) async {
    // Create the order
    final response = await supabase.from('orders').insert({
      'user_id': userId,
      'hawker_id': hawkerId,
      'total_amount': totalAmount,
      'status': 'pending',
      'delivery_address': deliveryAddress,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    }).select('id').single();
    
    String orderId = response['id'];
    
    // Add order items
    for (var item in items) {
      await supabase.from('order_items').insert({
        'order_id': orderId,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
        'unit': item.unit,
        'negotiated_price': item.negotiatedPrice,
      });
    }
    
    // Get the complete order
    final orderData = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();
    
    return Order.fromJson(orderData);
  }
  
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      // For demo user or hawker account, return dummy orders
      if (userId == 'demo-user-id' || userId == 'demo-hawker-id') {
        debugPrint('Returning dummy user orders for demo account');
        return _getDummyOrders(userId);
      }
      
      final data = await supabase
        .from('orders')
        .select('*, items:order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
        
      return _processOrdersData(data);
    } catch (e) {
      debugPrint('Error getting user orders: $e');
      // Return dummy data on error for better demo experience
      return _getDummyOrders(userId);
    }
  }
  
  Future<List<Order>> getHawkerOrders(String hawkerId) async {
    try {
      // For demo hawker account, return dummy orders
      if (hawkerId == 'demo-hawker-id') {
        debugPrint('Returning dummy hawker orders for demo account');
        return _getDummyOrders(hawkerId, isHawker: true);
      }
      
      final data = await supabase
        .from('orders')
        .select('*, items:order_items(*)')
        .eq('hawker_id', hawkerId)
        .order('created_at', ascending: false);
        
      return _processOrdersData(data);
    } catch (e) {
      debugPrint('Error getting hawker orders: $e');
      // Return dummy data on error
      return _getDummyOrders(hawkerId, isHawker: true);
    }
  }
  
  Future<List<Order>> getAllOrders() async {
    final response = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);
    
    List<Order> orders = [];
    for (var orderData in response) {
      orders.add(Order.fromJson(orderData));
    }
    
    return orders;
  }
  
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await supabase
        .from('orders')
        .update({
          'status': status.toString().split('.').last,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId);
  }
  
  Future<void> rateOrder(String orderId, double rating, String? review) async {
    await supabase
        .from('orders')
        .update({
          'rating': rating,
          'review': review
        })
        .eq('id', orderId);
    
    // Get the order to update hawker rating
    final order = await supabase
        .from('orders')
        .select('hawker_id')
        .eq('id', orderId)
        .single();
    
    String hawkerId = order['hawker_id'];
    
    // Update hawker rating
    final hawker = await supabase
        .from('hawkers')
        .select('rating, total_ratings')
        .eq('id', hawkerId)
        .single();
    
    double currentRating = hawker['rating'] ?? 0;
    int totalRatings = hawker['total_ratings'] ?? 0;
    
    double newRating = ((currentRating * totalRatings) + rating) / (totalRatings + 1);
    
    await supabase
        .from('hawkers')
        .update({
          'rating': newRating,
          'total_ratings': totalRatings + 1,
        })
        .eq('id', hawkerId);
  }

  // Helper method to process orders data
  List<Order> _processOrdersData(List<dynamic> data) {
    List<Order> orders = [];
    
    for (final order in data) {
      final List<OrderItem> items = [];
      
      if (order['items'] != null) {
        for (final item in order['items']) {
          items.add(OrderItem(
            id: item['id'], 
            name: item['name'], 
            quantity: item['quantity'],
            price: item['price'],
            unit: item['unit'],
            totalPrice: item['total_price'],
            negotiatedPrice: item['negotiated_price'],
          ));
        }
      }
      
      orders.add(Order(
        id: order['id'],
        userId: order['user_id'],
        hawkerId: order['hawker_id'],
        items: items,
        totalAmount: order['total_amount'],
        status: _parseOrderStatus(order['status']),
        createdAt: DateTime.parse(order['created_at']),
        updatedAt: DateTime.parse(order['updated_at']),
        deliveryAddress: order['delivery_address'],
        notes: order['notes'],
        isRated: order['is_rated'] ?? false,
        rating: order['rating'] ?? 0,
      ));
    }
    
    return orders;
  }
  
  // Helper method to parse order status
  OrderStatus _parseOrderStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return OrderStatus.pending;
      case 'confirmed': return OrderStatus.confirmed;
      case 'accepted': return OrderStatus.accepted;
      case 'packed': return OrderStatus.packed;
      case 'dispatched': return OrderStatus.dispatched;
      case 'delivered': return OrderStatus.delivered;
      case 'completed': return OrderStatus.completed;
      case 'cancelled': return OrderStatus.cancelled;
      case 'refunded': return OrderStatus.refunded;
      default: return OrderStatus.pending;
    }
  }
  
  // Helper method to generate dummy orders
  List<Order> _getDummyOrders(String userId, {bool isHawker = false}) {
    final List<Order> dummyOrders = [];
    
    // Food items that could be ordered
    final List<Map<String, dynamic>> availableItems = [
      {'name': 'Samosa', 'price': 15.0, 'unit': 'pcs'},
      {'name': 'Vada Pav', 'price': 20.0, 'unit': 'pcs'},
      {'name': 'Pani Puri', 'price': 40.0, 'unit': 'plate'},
      {'name': 'Dosa', 'price': 80.0, 'unit': 'pcs'},
      {'name': 'Idli', 'price': 50.0, 'unit': 'plate'},
      {'name': 'Biryani', 'price': 120.0, 'unit': 'plate'},
      {'name': 'Noodles', 'price': 70.0, 'unit': 'plate'},
      {'name': 'Fried Rice', 'price': 80.0, 'unit': 'plate'},
      {'name': 'Tea', 'price': 15.0, 'unit': 'cup'},
      {'name': 'Coffee', 'price': 25.0, 'unit': 'cup'},
      {'name': 'Juice', 'price': 35.0, 'unit': 'glass'},
      {'name': 'Ice Cream', 'price': 40.0, 'unit': 'scoop'},
    ];
    
    // Delivery addresses
    final List<String> addresses = [
      'Apartment 101, Green Meadows',
      'House 23, Lake View Road',
      'Flat 302, Sunshine Apartments',
      'Villa 7, Hill Side',
      'Room 405, City Center Residency',
    ];
    
    // Generate 5-8 dummy orders
    final numOrders = 5 + Random().nextInt(4);
    
    // Order statuses weighted towards recent orders being pending/in progress
    final List<OrderStatus> possibleStatuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.accepted,
      OrderStatus.packed,
      OrderStatus.dispatched,
      OrderStatus.delivered,
      OrderStatus.completed,
      OrderStatus.cancelled,
    ];
    
    for (int i = 0; i < numOrders; i++) {
      final isRecent = i < 3; // First few orders are more recent
      
      // Create random order items (1-4 items per order)
      final numItems = 1 + Random().nextInt(4);
      final List<OrderItem> orderItems = [];
      double totalAmount = 0;
      
      for (int j = 0; j < numItems; j++) {
        final itemIndex = Random().nextInt(availableItems.length);
        final item = availableItems[itemIndex];
        final quantity = 1 + Random().nextInt(3); // 1-3 items
        final price = item['price'] as double;
        final totalPrice = price * quantity;
        
        orderItems.add(OrderItem(
          id: 'item-${Random().nextInt(10000)}',
          name: item['name'] as String,
          quantity: quantity,
          price: price,
          unit: item['unit'] as String,
          totalPrice: totalPrice,
        ));
        
        totalAmount += totalPrice;
      }
      
      // For recent orders, bias towards pending/in-progress statuses
      OrderStatus status;
      if (isRecent) {
        // Recent orders are more likely to be in-progress
        status = possibleStatuses[Random().nextInt(5)]; // First 5 statuses (pending to dispatched)
      } else {
        // Older orders are more likely to be completed/cancelled
        final statusIndex = 4 + Random().nextInt(4); // Last 4 statuses (dispatched to cancelled)
        status = possibleStatuses[statusIndex < possibleStatuses.length ? statusIndex : possibleStatuses.length - 1];
      }
      
      // Create random dates (more recent for first few orders)
      final now = DateTime.now();
      final daysAgo = isRecent ? Random().nextInt(3) : 3 + Random().nextInt(28); // Recent: 0-2 days ago, Others: 3-30 days ago
      final createdAt = now.subtract(Duration(days: daysAgo, hours: Random().nextInt(24), minutes: Random().nextInt(60)));
      final updatedAt = createdAt.add(Duration(minutes: 15 + Random().nextInt(120))); // 15-135 minutes after creation
      
      final orderId = 'order-${100000 + Random().nextInt(900000)}'; // 6-digit order ID
      
      // Choose either demo user or one of the demo hawkers
      final String hawkerId;
      final String userIdVal;
      
      if (isHawker) {
        hawkerId = userId;
        userIdVal = 'demo-user-id';
      } else {
        hawkerId = 'dummy-hawker-${1 + Random().nextInt(10)}';
        userIdVal = userId;
      }
      
      dummyOrders.add(Order(
        id: orderId,
        userId: userIdVal,
        hawkerId: hawkerId,
        items: orderItems,
        totalAmount: totalAmount,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deliveryAddress: addresses[Random().nextInt(addresses.length)],
        notes: Random().nextBool() ? 'Please deliver it hot.' : null,
        isRated: !isRecent && status == OrderStatus.completed && Random().nextBool(),
        rating: 3.0 + Random().nextInt(3), // 3-5 star rating
      ));
    }
    
    // Sort by created date (newest first)
    dummyOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return dummyOrders;
  }

  // Helper method to generate dummy hawkers
  List<Hawker> _getDummyHawkers(Location userLocation) {
    final List<Hawker> dummyHawkers = [];
    final List<String> cuisines = [
      'North Indian', 'South Indian', 'Chinese', 'Street Food', 
      'Chaat', 'Biryani', 'Fast Food', 'Beverages', 'Desserts', 
      'Vegetarian', 'Non-Vegetarian'
    ];
    
    final List<String> areas = [
      'Gandhi Nagar', 'Shivaji Market', 'Food Street', 'Main Bazaar',
      'Central Market', 'Metro Station', 'City Center', 'Lake View',
      'Green Park', 'College Road', 'Railway Station'
    ];
    
    final List<String> hawkerNames = [
      'Spice King', 'Tasty Bites', 'Food Express', 'Street Delights',
      'Flavor Junction', 'Urban Eats', 'Food Corner', 'Culinary Delight',
      'Savory Treats', 'Quick Bites', 'Street Chef', 'Food Master'
    ];
    
    // Generate 10 dummy hawkers
    for (int i = 0; i < 10; i++) {
      // Generate slightly varying coordinates (within ~500m to ~2km)
      final double distanceRadius = 0.005 + (Random().nextDouble() * 0.015); // 0.5km to 2km approx
      final double bearing = Random().nextDouble() * 360; // Random direction
      
      // Calculate new point based on distance and bearing
      final double lat1 = userLocation.latitude * pi / 180;
      final double lon1 = userLocation.longitude * pi / 180;
      final double angularDistance = distanceRadius / 6371.0; // Earth radius in km
      final double bearingRad = bearing * pi / 180;
      
      double lat2 = asin(sin(lat1) * cos(angularDistance) + 
                       cos(lat1) * sin(angularDistance) * cos(bearingRad));
      double lon2 = lon1 + atan2(sin(bearingRad) * sin(angularDistance) * cos(lat1),
                               cos(angularDistance) - sin(lat1) * sin(lat2));
                               
      // Convert back to degrees
      lat2 = lat2 * 180 / pi;
      lon2 = lon2 * 180 / pi;
      
      final hawkerLocation = Location(lat2, lon2);
      
      // Calculate real distance
      final distanceToUser = userLocation.distanceTo(hawkerLocation);
      
      // Generate a unique hawker name
      final String hawkerName = '${hawkerNames[i % hawkerNames.length]} ${cuisines[i % cuisines.length]}';
      
      // Generate random inventory items
      final inventoryItems = _generateRandomInventory();
      
      // Hawkers closer to user more likely to be open
      final bool isOpen = distanceToUser < 1.0 ? Random().nextDouble() > 0.2 : Random().nextDouble() > 0.5;
      
      dummyHawkers.add(Hawker(
        id: 'dummy-hawker-${i+1}',
        name: hawkerName,
        email: 'hawker${i+1}@example.com',
        phone: '+9198765432${i+1}',
        address: '${areas[i % areas.length]}, Stall #${i+100}',
        location: hawkerLocation.toLatLng(),
        isOpen: isOpen,
        rating: 3.0 + Random().nextDouble() * 2.0, // Random rating between 3.0 and 5.0
        totalRatings: 10 + Random().nextInt(90), // Random number of ratings between 10 and 99
        profileImage: null,
        inventory: inventoryItems,
        distanceFromUser: distanceToUser,
      ));
    }
    
    // Sort by distance
    dummyHawkers.sort((a, b) => a.distanceFromUser.compareTo(b.distanceFromUser));
    
    debugPrint("Generated ${dummyHawkers.length} dummy hawkers near ${userLocation.latitude}, ${userLocation.longitude}");
    for (final hawker in dummyHawkers) {
      debugPrint("- ${hawker.name}: ${hawker.distanceFromUser.toStringAsFixed(2)}km, ${hawker.inventory.length} items");
    }
    
    return dummyHawkers;
  }
  
  // Generate realistic inventory items for dummy hawkers
  List<InventoryItem> _generateRandomInventory() {
    final List<InventoryItem> items = [];
    final List<Map<String, dynamic>> foodItems = [
      {
        'name': 'Samosa',
        'description': 'Crispy fried pastry with savory filling',
        'price': 15.0,
        'category': 'Snacks',
        'imageUrl': null,
        'unit': 'pcs',
      },
      {
        'name': 'Pav Bhaji',
        'description': 'Spicy vegetable curry served with soft bread rolls',
        'price': 50.0,
        'category': 'Main Course',
        'imageUrl': null,
        'unit': 'plate',
      },
      {
        'name': 'Vada Pav',
        'description': 'Spicy potato fritter in a bun with chutneys',
        'price': 20.0,
        'category': 'Snacks',
        'imageUrl': null,
        'unit': 'pcs',
      },
      {
        'name': 'Masala Chai',
        'description': 'Spiced tea with milk',
        'price': 10.0,
        'category': 'Beverages',
        'imageUrl': null,
        'unit': 'cup',
      },
      {
        'name': 'Idli Sambar',
        'description': 'Steamed rice cakes with lentil soup',
        'price': 35.0,
        'category': 'Breakfast',
        'imageUrl': null,
        'unit': 'plate',
      },
      {
        'name': 'Dosa',
        'description': 'Crispy rice pancake served with chutneys',
        'price': 40.0,
        'category': 'Breakfast',
        'imageUrl': null,
        'unit': 'pcs',
      },
      {
        'name': 'Chole Bhature',
        'description': 'Spicy chickpea curry with fried bread',
        'price': 60.0,
        'category': 'Main Course',
        'imageUrl': null,
        'unit': 'plate',
      },
      {
        'name': 'Panipuri',
        'description': 'Hollow crisp balls filled with flavored water',
        'price': 30.0,
        'category': 'Chaat',
        'imageUrl': null,
        'unit': 'plate',
      },
      {
        'name': 'Bhel Puri',
        'description': 'Puffed rice, vegetables and tangy tamarind sauce',
        'price': 25.0,
        'category': 'Chaat',
        'imageUrl': null,
        'unit': 'plate',
      },
      {
        'name': 'Lassi',
        'description': 'Sweet or savory yogurt-based drink',
        'price': 30.0,
        'category': 'Beverages',
        'imageUrl': null,
        'unit': 'glass',
      },
      {
        'name': 'Momos',
        'description': 'Steamed dumplings with spicy sauce',
        'price': 45.0,
        'category': 'Snacks',
        'imageUrl': null,
        'unit': 'plate',
      },
      {
        'name': 'Aloo Tikki',
        'description': 'Spiced potato patties served with chutneys',
        'price': 25.0,
        'category': 'Chaat',
        'imageUrl': null,
        'unit': 'plate',
      },
    ];
    
    // Each hawker has between 3 and 8 menu items
    final int itemCount = 3 + Random().nextInt(6);
    final shuffledItems = List<Map<String, dynamic>>.from(foodItems)..shuffle();
    
    for (int i = 0; i < itemCount; i++) {
      if (i < shuffledItems.length) {
        final item = shuffledItems[i];
        
        // Add slight price variations
        final double priceVariation = (Random().nextDouble() * 0.2) - 0.1; // -10% to +10%
        final double adjustedPrice = item['price'] * (1 + priceVariation);
        
        items.add(InventoryItem(
          id: 'dummy-item-${Random().nextInt(10000)}',
          name: item['name'],
          description: item['description'],
          price: adjustedPrice.roundToDouble(),
          category: item['category'],
          imageUrl: item['imageUrl'],
          available: Random().nextDouble() > 0.2, // 80% chance of being available
          quantity: Random().nextInt(30) + 5, // 5-35 items in stock
          unit: item['unit'] ?? 'item',
        ));
      }
    }
    
    return items;
  }

  // Get all hawkers
  Future<List<Hawker>> getHawkers(Location userLocation) async {
    try {
      // For the demo app, return dummy hawkers
      final currentUser = supabase.auth.currentUser;
      if (currentUser?.email?.contains('demo') ?? false) {
        debugPrint('Using dummy hawkers for demo account');
        return _getDummyHawkers(userLocation);
      }

      // TODO: This would be a Supabase query in a real app
      final response = await supabase
          .from('hawkers')
          .select('*, inventory(*)');

      List<Hawker> hawkers = [];

      for (final hawkerData in response) {
        // Parse location
        final lat = hawkerData['location']['latitude'] as double;
        final lng = hawkerData['location']['longitude'] as double;
        final location = Location(lat, lng).toLatLng();

        // Calculate distance from user
        final hawkerLocation = Location(lat, lng);
        final distanceToUser = userLocation.distanceTo(hawkerLocation);

        // Parse inventory items
        List<InventoryItem> inventoryItems = [];
        if (hawkerData['inventory'] != null) {
          for (final itemData in hawkerData['inventory']) {
            inventoryItems.add(InventoryItem(
              id: itemData['id'],
              name: itemData['name'],
              description: itemData['description'] ?? '',
              price: (itemData['price'] ?? 0).toDouble(),
              category: itemData['category'] ?? 'Other',
              imageUrl: itemData['image_url'],
              available: itemData['available'] ?? true,
              quantity: itemData['quantity'] ?? 0,
              unit: itemData['unit'] ?? 'item',
            ));
          }
        }

        hawkers.add(Hawker(
          id: hawkerData['id'],
          name: hawkerData['name'],
          email: hawkerData['email'],
          phone: hawkerData['phone'],
          address: hawkerData['address'],
          location: location,
          isOpen: hawkerData['is_open'] ?? false,
          rating: (hawkerData['rating'] ?? 0).toDouble(),
          totalRatings: hawkerData['total_ratings'] ?? 0,
          profileImage: hawkerData['profile_image'],
          inventory: inventoryItems,
          distanceFromUser: distanceToUser,
        ));
      }

      // Sort by distance
      hawkers.sort((a, b) => a.distanceFromUser.compareTo(b.distanceFromUser));
      
      return hawkers;
    } catch (e) {
      debugPrint('Error getting hawkers: $e');
      return [];
    }
  }

  Future<List<InventoryItem>> getHawkerInventory(String hawkerId) async {
    try {
      final response = await supabase
          .from('inventory_items')
          .select()
          .eq('hawker_id', hawkerId);

      if (response == null) {
        return [];
      }

      return (response as List<dynamic>)
          .map((item) => InventoryItem.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error getting hawker inventory: $e');
      return [];
    }
  }

  Future<void> updateHawkerStatus(String hawkerId, bool isOpen) async {
    try {
      // Handle demo accounts
      if (hawkerId == 'demo-hawker-id' || 
          supabase.auth.currentUser?.email == 'hawker@example.com') {
        debugPrint('Updating demo hawker status to: $isOpen');
        // For demo account, just return success without making a database call
        return;
      }

      // For real accounts, proceed with database update
      final hawkerData = await supabase
          .from('hawkers')
          .select('id')
          .eq('id', hawkerId)
          .single();
          
      if (hawkerData == null) {
        throw Exception('Hawker not found');
      }

      await supabase
          .from('hawkers')
          .update({'is_open': isOpen})
          .eq('id', hawkerId);

    } catch (e) {
      debugPrint('Error updating hawker status: $e');
      throw e;
    }
  }
} 