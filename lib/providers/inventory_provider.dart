import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/supabase_service.dart';

class InventoryProvider with ChangeNotifier {
  final SupabaseService _supabaseService;
  List<InventoryItem> _inventoryItems = [];
  bool _isLoading = false;
  String? _error;

  InventoryProvider(this._supabaseService);

  List<InventoryItem> get inventoryItems => _inventoryItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get inventory items for a specific hawker
  Future<List<InventoryItem>> getInventoryItems(String hawkerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final items = await _supabaseService.getInventoryItems(hawkerId);
      _inventoryItems = items;
      
      _isLoading = false;
      notifyListeners();
      
      return _inventoryItems;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // Add a new inventory item
  Future<void> addInventoryItem(String hawkerId, Map<String, dynamic> item) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.addInventoryItem(hawkerId, item);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an inventory item
  Future<void> updateInventoryItem(String itemId, Map<String, dynamic> item) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.updateInventoryItem(itemId, item);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete an inventory item
  Future<void> deleteInventoryItem(String itemId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.deleteInventoryItem(itemId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
} 