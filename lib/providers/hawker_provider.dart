import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/hawker.dart';
import '../models/location.dart';
import '../services/supabase_service.dart';
import '../models/inventory_item.dart';

class HawkerProvider with ChangeNotifier {
  final SupabaseService _supabaseService;
  List<Hawker> _hawkers = [];
  List<Hawker> _nearbyHawkers = [];
  List<Hawker> _unverifiedHawkers = [];
  bool _isLoading = false;
  String? _error;

  HawkerProvider(this._supabaseService);

  List<Hawker> get hawkers => _hawkers;
  List<Hawker> get nearbyHawkers => _nearbyHawkers;
  List<Hawker> get unverifiedHawkers => _unverifiedHawkers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHawkers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use a default location if none is provided
      final defaultLocation = Location(18.9220, 72.8347); // Mumbai
      _hawkers = await _supabaseService.getHawkers(defaultLocation);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadNearbyHawkers(Location userLocation) async {
    try {
      // Set loading state
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Get all hawkers
      final hawkers = await _supabaseService.getHawkers(userLocation);
      
      // Debug print the hawkers
      debugPrint('Loaded ${hawkers.length} hawkers near ${userLocation.latitude}, ${userLocation.longitude}');
      for (final hawker in hawkers) {
        debugPrint('- ${hawker.name}: ${hawker.distanceFromUser.toStringAsFixed(2)}km, ${hawker.inventory.length} items');
      }

      // Update state with loaded hawkers
      _hawkers = hawkers;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading nearby hawkers: $e');
      _error = 'Failed to load hawkers: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnverifiedHawkers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _unverifiedHawkers = await _supabaseService.getUnverifiedHawkers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> verifyHawker(String hawkerId) async {
    try {
      await _supabaseService.verifyHawker(hawkerId);
      
      // Remove the hawker from unverified list
      _unverifiedHawkers.removeWhere((h) => h.id == hawkerId);
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> rejectHawker(String hawkerId) async {
    try {
      await _supabaseService.rejectHawker(hawkerId);
      
      // Remove the hawker from unverified list
      _unverifiedHawkers.removeWhere((h) => h.id == hawkerId);
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add a new inventory item
  Future<void> addInventoryItem(String hawkerId, Map<String, dynamic> item) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _supabaseService.addInventoryItem(hawkerId, item);

      // Refresh hawker data
      await loadNearbyHawkers(Location(0, 0));

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

      // Refresh hawker data
      await loadNearbyHawkers(Location(0, 0));

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

      // Refresh hawker data
      await loadNearbyHawkers(Location(0, 0));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Hawker? getHawkerById(String hawkerId) {
    try {
      return _hawkers.firstWhere((h) => h.id == hawkerId);
    } catch (e) {
      return null;
    }
  }

  Future<List<InventoryItem>> getHawkerInventory(String hawkerId) async {
    try {
      final response = await _supabaseService.getHawkerInventory(hawkerId);
      return response;
    } catch (e) {
      debugPrint('Error getting hawker inventory: $e');
      return [];
    }
  }

  Future<void> updateHawkerStatus(String hawkerId, bool isOpen) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // For demo account, just update local state
      if (hawkerId == 'demo-hawker-id') {
        debugPrint('Updating demo hawker status locally to: $isOpen');
        final hawkerIndex = _hawkers.indexWhere((h) => h.id == hawkerId);
        if (hawkerIndex != -1) {
          _hawkers[hawkerIndex] = _hawkers[hawkerIndex].copyWith(isOpen: isOpen);
        }
        _isLoading = false;
        notifyListeners();
        return;
      }

      // For real accounts, update in database
      await _supabaseService.updateHawkerStatus(hawkerId, isOpen);

      // Update the local hawker data
      final hawkerIndex = _hawkers.indexWhere((h) => h.id == hawkerId);
      if (hawkerIndex != -1) {
        _hawkers[hawkerIndex] = _hawkers[hawkerIndex].copyWith(isOpen: isOpen);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating hawker status: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Rethrow to handle in UI
    }
  }
} 