import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../services/supabase_service.dart';

class OrderProvider with ChangeNotifier {
  final SupabaseService _supabaseService;
  List<Order> _userOrders = [];
  List<Order> _hawkerOrders = [];
  List<Order> _allOrders = [];
  bool _isLoading = false;
  String? _error;

  OrderProvider(this._supabaseService);

  List<Order> get userOrders => _userOrders;
  List<Order> get hawkerOrders => _hawkerOrders;
  List<Order> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch orders for a specific user
  Future<void> fetchUserOrders(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userOrders = await _supabaseService.getUserOrders(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch orders for a specific hawker
  Future<void> fetchHawkerOrders(String hawkerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _hawkerOrders = await _supabaseService.getHawkerOrders(hawkerId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch all orders for admin
  Future<void> fetchAllOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _allOrders = await _supabaseService.getAllOrders();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Place a new order
  Future<Order> placeOrder({
    required String userId,
    required String hawkerId,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newOrder = await _supabaseService.placeOrder(
        userId: userId,
        hawkerId: hawkerId,
        items: items,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        notes: notes,
      );

      // Add to local state
      _userOrders.add(newOrder);

      _isLoading = false;
      notifyListeners();
      
      return newOrder;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.updateOrderStatus(
        orderId, 
        OrderStatus.cancelled
      );

      // Update in user orders
      final userOrderIndex = _userOrders.indexWhere((o) => o.id == orderId);
      if (userOrderIndex != -1) {
        _userOrders[userOrderIndex] = _userOrders[userOrderIndex].copyWith(
          status: OrderStatus.cancelled,
          updatedAt: DateTime.now(),
        );
      }

      // Update in hawker orders
      final hawkerOrderIndex = _hawkerOrders.indexWhere((o) => o.id == orderId);
      if (hawkerOrderIndex != -1) {
        _hawkerOrders[hawkerOrderIndex] = _hawkerOrders[hawkerOrderIndex].copyWith(
          status: OrderStatus.cancelled,
          updatedAt: DateTime.now(),
        );
      }

      // Update in all orders
      final allOrderIndex = _allOrders.indexWhere((o) => o.id == orderId);
      if (allOrderIndex != -1) {
        _allOrders[allOrderIndex] = _allOrders[allOrderIndex].copyWith(
          status: OrderStatus.cancelled,
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.updateOrderStatus(orderId, newStatus);

      // Update in user orders
      final userOrderIndex = _userOrders.indexWhere((o) => o.id == orderId);
      if (userOrderIndex != -1) {
        _userOrders[userOrderIndex] = _userOrders[userOrderIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }

      // Update in hawker orders
      final hawkerOrderIndex = _hawkerOrders.indexWhere((o) => o.id == orderId);
      if (hawkerOrderIndex != -1) {
        _hawkerOrders[hawkerOrderIndex] = _hawkerOrders[hawkerOrderIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }

      // Update in all orders
      final allOrderIndex = _allOrders.indexWhere((o) => o.id == orderId);
      if (allOrderIndex != -1) {
        _allOrders[allOrderIndex] = _allOrders[allOrderIndex].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Rate an order
  Future<void> rateOrder(String orderId, double rating, {String? review}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.rateOrder(orderId, rating, review);

      // Update local orders if they exist
      final userOrderIndex = _userOrders.indexWhere((order) => order.id == orderId);
      if (userOrderIndex != -1) {
        _userOrders[userOrderIndex] = _userOrders[userOrderIndex].copyWith(
          rating: rating,
          isRated: true,
        );
      }

      // Update in all orders
      final allOrderIndex = _allOrders.indexWhere((o) => o.id == orderId);
      if (allOrderIndex != -1) {
        _allOrders[allOrderIndex] = _allOrders[allOrderIndex].copyWith(
          rating: rating,
          isRated: true,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get orders for a hawker
  Future<void> loadHawkerOrders(String hawkerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final orders = await _supabaseService.getHawkerOrders(hawkerId);
      _hawkerOrders = orders;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 