import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import '../../models/location.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hawker_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/hawker.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/inventory_item.dart';
import '../../widgets/hawker_card.dart';
import 'dart:math';
import '../../services/demo_data_service.dart';

// Add this enum before the UserDashboard class
enum OrderStatus {
  pending,
  accepted,
  counterOffer,
  declined
}

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final MapController _mapController = MapController();
  Position? _userPosition;
  Position? _currentPosition;
  LatLng? _userLocation;
  List<Hawker> _nearbyHawkers = [];
  bool _isLoading = true;
  bool _isLoadingHawkers = true;
  final List<Marker> _markers = [];
  
  // Selected hawker for order
  Hawker? _selectedHawker;
  // Order items map to track quantity
  final Map<String, int> _orderItems = {};
  final Map<String, List<double>> _proposedPrices = {}; // Track proposed prices for each item
  final Map<String, InventoryItem> _cartItems = {}; // Track items in cart
  bool _showCart = false; // Control cart visibility

  // Add these variables at the top of _UserDashboardState class
  final Map<String, OrderStatus> _orderStatuses = {};
  final Map<String, double> _hawkerCounterOffers = {};

  // Add this variable at the top with other state variables
  final Map<String, TextEditingController> _priceControllers = {};

  final DemoDataService _demoService = DemoDataService();
  final Map<String, List<Map<String, dynamic>>> _cart = {};
  final String _userId = 'user1'; // Demo user ID

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return null;
      }
      
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        _currentPosition = position;
      });
      
      return position;
    } catch (e) {
      debugPrint("Error getting location: $e");
      return null;
    }
  }

  Future<void> _loadNearbyHawkers(Position position) async {
    if (!mounted) return;

    debugPrint('Loading nearby hawkers at ${position.latitude}, ${position.longitude}');
    setState(() => _isLoadingHawkers = true);

    try {
      final provider = Provider.of<HawkerProvider>(context, listen: false);
      final userLocation = Location(position.latitude, position.longitude);

      await provider.loadNearbyHawkers(userLocation);

      if (!mounted) return;

      // Get the hawkers from the provider
      List<Hawker> hawkers = provider.hawkers;
      debugPrint('Loaded ${hawkers.length} hawkers from provider');

      // If no hawkers found, add dummy data
      if (hawkers.isEmpty) {
        hawkers = _getDummyHawkers(position);
        debugPrint('Added ${hawkers.length} dummy hawkers');
      }

      setState(() {
        _nearbyHawkers = hawkers;
        _isLoadingHawkers = false;
      });

      // Add markers for hawkers on the map
      _addHawkerMarkers();
    } catch (e) {
      debugPrint('Error loading nearby hawkers: $e');
      if (mounted) {
        setState(() {
          _isLoadingHawkers = false;
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load nearby hawkers: $e')),
          );
        });
      }
    }
  }

  List<Hawker> _getDummyHawkers(Position userPosition) {
    // Create dummy hawkers around the user's location
    final random = Random();
    final List<Hawker> dummyHawkers = [];

    final hawkerNames = [
      'Street Food Express',
      'Tasty Corner',
      'Food on Wheels',
      'Spice Cart',
      'Fresh Delights',
      'Local Flavors',
      'Quick Bites',
      'Foodie\'s Stop',
      'Snack Hub',
      'Meal Master'
    ];

    final categories = ['Street Food', 'Snacks', 'Beverages', 'Meals', 'Desserts'];
    
    // Generate 10 dummy hawkers
    for (int i = 0; i < 10; i++) {
      // Generate random location within 2km radius
      final radius = 2000; // meters
      final y0 = userPosition.latitude;
      final x0 = userPosition.longitude;
      final rd = radius / 111300; // about 111300 meters in one degree

      final u = random.nextDouble();
      final v = random.nextDouble();
      final w = rd * sqrt(u);
      final t = 2 * pi * v;
      final x = w * cos(t);
      final y = w * sin(t);

      final newLat = y0 + y;
      final newLng = x0 + x;

      final inventory = _generateDummyInventory(random.nextInt(5) + 5); // 5-10 items

      dummyHawkers.add(
        Hawker(
          id: 'dummy-${i + 1}',
          name: hawkerNames[i],
          email: 'dummy$i@example.com',
          phone: '+91${900000000 + i}',
          address: 'Near ${hawkerNames[i]}, Local Area',
          isOpen: random.nextBool(),
          rating: 3.5 + random.nextDouble() * 1.5, // Rating between 3.5 and 5.0
          totalRatings: random.nextInt(100) + 50, // 50-150 ratings
          location: LatLng(newLat, newLng),
          inventory: inventory,
          distanceFromUser: 0, // Will be calculated by the Hawker model
        ),
      );
    }

    return dummyHawkers;
  }

  List<InventoryItem> _generateDummyInventory(int count) {
    final random = Random();
    final List<InventoryItem> inventory = [];

    final items = [
      {'name': 'Samosa', 'category': 'Snacks', 'basePrice': 15},
      {'name': 'Vada Pav', 'category': 'Street Food', 'basePrice': 20},
      {'name': 'Pani Puri', 'category': 'Street Food', 'basePrice': 30},
      {'name': 'Masala Dosa', 'category': 'Meals', 'basePrice': 60},
      {'name': 'Chai', 'category': 'Beverages', 'basePrice': 15},
      {'name': 'Cold Coffee', 'category': 'Beverages', 'basePrice': 40},
      {'name': 'Bhel Puri', 'category': 'Snacks', 'basePrice': 30},
      {'name': 'Pav Bhaji', 'category': 'Meals', 'basePrice': 70},
      {'name': 'Gulab Jamun', 'category': 'Desserts', 'basePrice': 20},
      {'name': 'Lassi', 'category': 'Beverages', 'basePrice': 35},
      {'name': 'Idli', 'category': 'Meals', 'basePrice': 40},
      {'name': 'Poha', 'category': 'Breakfast', 'basePrice': 30},
      {'name': 'Chole Bhature', 'category': 'Meals', 'basePrice': 60},
      {'name': 'Mango Lassi', 'category': 'Beverages', 'basePrice': 45},
      {'name': 'Jalebi', 'category': 'Desserts', 'basePrice': 40}
    ];

    final descriptions = [
      'Fresh and hot',
      'Made with special masala',
      'Customer favorite',
      'Must try!',
      'Chef\'s special',
      'Bestseller',
      'Traditional recipe',
      'Homemade style',
      'Premium quality',
      'Limited stock'
    ];

    // Shuffle items to get random selection
    final shuffledItems = List.from(items)..shuffle();
    
    for (int i = 0; i < count; i++) {
      final item = shuffledItems[i];
      final basePrice = item['basePrice'] as int;
      // Vary price by ±20%
      final price = basePrice + (random.nextInt(basePrice ~/ 2) - basePrice ~/ 4);
      
      inventory.add(
        InventoryItem(
          id: 'item-${random.nextInt(1000000)}',
          name: item['name'] as String,
          description: descriptions[random.nextInt(descriptions.length)],
          category: item['category'] as String,
          price: price.toDouble(),
          available: random.nextDouble() > 0.2, // 80% chance of being available
          unit: 'piece',
          imageUrl: null, // You could add dummy images here if needed
        ),
      );
    }

    return inventory;
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);
    
    try {
      // Get current position first
      final position = await _getCurrentPosition();
      
      if (position != null) {
        setState(() {
          _userPosition = position;
          _currentPosition = position;
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        
        // Load nearby hawkers with actual position
        await _loadNearbyHawkers(position);
        
        // Move map to user location
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0
        );
      } else {
        // Use default position (Mumbai) if location access denied
        final defaultPosition = Position(
          latitude: 18.9220, 
          longitude: 72.8347,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        
        setState(() {
          _userPosition = defaultPosition;
          _currentPosition = defaultPosition;
          _userLocation = LatLng(defaultPosition.latitude, defaultPosition.longitude);
        });
        
        // Load nearby hawkers with default position
        await _loadNearbyHawkers(defaultPosition);
      }
    } catch (e) {
      debugPrint('Error initializing map: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading map: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addHawkerMarkers() {
    if (_mapController == null || _nearbyHawkers == null) return;

    // Clear existing markers
    _markers.clear();

    // Add marker for user's location
    if (_userPosition != null) {
      _markers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
          builder: (ctx) => const Icon(
            Icons.person_pin_circle,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    }

    // Add markers for hawkers
    if (_nearbyHawkers != null) {
      for (final hawker in _nearbyHawkers!) {
        if (hawker.location != null) {
          _markers.add(
            Marker(
              width: 40,
              height: 40,
              point: LatLng(hawker.location.latitude, hawker.location.longitude),
              builder: (ctx) => GestureDetector(
                onTap: () => _showHawkerDetails(hawker),
                child: Icon(
                  Icons.store,
                  color: hawker.isOpen ? Colors.green : Colors.red,
                  size: 40,
                ),
              ),
            ),
          );
        }
      }
    }

    // Force rebuild to update markers
    if (mounted) setState(() {});
  }

  void _showHawkerDetails(Hawker hawker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: hawker.isOpen
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                            radius: 24,
                            child: Icon(
                              Icons.store,
                              color: hawker.isOpen
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hawker.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${hawker.rating.toStringAsFixed(1)} (${hawker.totalRatings})',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: hawker.isOpen
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        hawker.isOpen ? 'Open' : 'Closed',
                                        style: TextStyle(
                                          color: hawker.isOpen
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              hawker.address,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_walk,
                            size: 16,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hawker.formattedDistance,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Menu Items
                Expanded(
                  child: hawker.inventory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.no_food,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items available',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: hawker.inventory.length,
                        itemBuilder: (context, index) {
                          final item = hawker.inventory[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Item Image
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: item.imageUrl != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(
                                                  item.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  width: 80,
                                                  height: 80,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                    const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                                                ),
                                              )
                                            : const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Item Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (item.description.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                item.description,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    item.category,
                                                    style: TextStyle(
                                                      color: Colors.grey.shade700,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: item.available
                                                      ? Colors.green.shade100
                                                      : Colors.red.shade100,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    item.available ? 'Available' : 'Sold out',
                                                    style: TextStyle(
                                                      color: item.available
                                                        ? Colors.green.shade700
                                                        : Colors.red.shade700,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Price and Negotiation
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Price',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '₹${item.price.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          controller: _priceControllers.putIfAbsent(
                                            item.id,
                                            () => TextEditingController(text: item.price.toStringAsFixed(0))
                                          ),
                                          onSubmitted: (value) {
                                            if (value.isNotEmpty) {
                                              final proposedPrice = double.tryParse(value);
                                              if (proposedPrice != null) {
                                                _handlePriceProposal(item, proposedPrice);
                                              }
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Propose a price',
                                            hintText: 'Enter your price',
                                            border: const OutlineInputBorder(),
                                            suffixIcon: IconButton(
                                              icon: const Icon(Icons.send),
                                              onPressed: () {
                                                final controller = _priceControllers[item.id];
                                                if (controller != null) {
                                                  final proposedPrice = double.tryParse(controller.text);
                                                  if (proposedPrice != null) {
                                                    _handlePriceProposal(item, proposedPrice);
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text('Please enter a valid price'),
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                ),
                
                // Place Order Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close hawker details
                        _showCartSheet(); // Show cart sheet
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
  
  void _updateItemQuantity(String itemId, int change) {
    setState(() {
      final currentQuantity = _orderItems[itemId] ?? 0;
      final newQuantity = currentQuantity + change;
      
      if (newQuantity <= 0) {
        _orderItems.remove(itemId);
      } else {
        _orderItems[itemId] = newQuantity;
      }
    });
  }
  
  void _placeOrder() async {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    // Calculate total
    double total = 0;
    for (var item in _cartItems.values) {
      final proposedPrice = _proposedPrices[item.id]?.last;
      final counterOffer = _hawkerCounterOffers[item.id];
      final price = counterOffer ?? proposedPrice ?? item.price;
      total += price;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...(_cartItems.values.map((item) {
              final proposedPrice = _proposedPrices[item.id]?.last;
              final counterOffer = _hawkerCounterOffers[item.id];
              final finalPrice = counterOffer ?? proposedPrice ?? item.price;
              final status = _orderStatuses[item.id];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name),
                          if (status == OrderStatus.accepted)
                            Text(
                              'Price accepted',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${finalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            })),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing your order...'),
          ],
        ),
      ),
    );

    // Simulate order processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context); // Close processing dialog

    try {
      // TODO: Implement actual order placement with your backend
      // For demo, show success message
      if (mounted) {
        // Show order success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Order Placed Successfully!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade700,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your order has been placed successfully!',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Amount: ₹${total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'The hawker will prepare your order soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to orders screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You can track your order in the Orders tab'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                },
                child: const Text('Track Order'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        );

        // Clear cart
        setState(() {
          _cartItems.clear();
          _proposedPrices.clear();
          _orderStatuses.clear();
          _hawkerCounterOffers.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hawker Hub',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            if (user != null)
              Text(
                'Welcome, ${user['name'] ?? 'User'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _cartItems.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showCartSheet,
          ),
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.green.shade700,
            ),
            onPressed: () => _initializeMap(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.red.shade700,
            ),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map View
          _buildMapView(),
          
          // Hawker List View
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: _isLoadingHawkers
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Nearby Hawkers (${_nearbyHawkers.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _nearbyHawkers.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.store,
                                      size: 48,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No hawkers found nearby',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: _initializeMap,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Refresh'),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: _nearbyHawkers.length,
                                itemBuilder: (context, index) {
                                  final hawker = _nearbyHawkers[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      onTap: () => _showHawkerDetails(hawker),
                                      leading: CircleAvatar(
                                        backgroundColor: hawker.isOpen
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                        child: Icon(
                                          Icons.store,
                                          color: hawker.isOpen
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        ),
                                      ),
                                      title: Text(
                                        hawker.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${hawker.formattedDistance} • ${hawker.inventory.length} items',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: hawker.isOpen
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          hawker.isOpen ? 'Open' : 'Closed',
                                          style: TextStyle(
                                            color: hawker.isOpen
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        // Map
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _userLocation ?? LatLng(18.9220, 72.8347),
            zoom: 14.0,
            onTap: (_, __) {
              // Close any open info windows
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(markers: _markers),
          ],
        ),
        
        // Loading indicator
        if (_isLoading)
          Container(
            color: Colors.white.withOpacity(0.7),
            child: const Center(child: CircularProgressIndicator()),
          ),
          
        // Recenter button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'recenterButton',
            onPressed: () {
              if (_userLocation != null) {
                _mapController.move(_userLocation!, 15.0);
              }
            },
            mini: true,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  // Add items to the order
  void _addItemToOrder(Map<String, dynamic> item, int quantity) {
    if (quantity <= 0) return;
    
    _orderItems[item['name']] = quantity;
  }

  // Add _switchTab method to handle tab navigation
  void _switchTab(int index) {
    // For now, just handle navigation to the orders tab
    if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Orders tab will be implemented in a future update'),
        ),
      );
    }
  }

  // Update the _handlePriceProposal method
  void _handlePriceProposal(InventoryItem item, double proposedPrice) {
    if (!mounted) return;

    // Validate proposed price
    if (proposedPrice <= 0 || proposedPrice >= item.price * 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reasonable price')),
      );
      return;
    }

    setState(() {
      if (!_proposedPrices.containsKey(item.id)) {
        _proposedPrices[item.id] = [];
      }
      _proposedPrices[item.id]!.add(proposedPrice);
      _orderStatuses[item.id] = OrderStatus.pending;
    });

    // Show waiting dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sending Proposal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Item: ${item.name}'),
            Text('Original Price: ₹${item.price.toStringAsFixed(0)}'),
            Text('Your Proposal: ₹${proposedPrice.toStringAsFixed(0)}'),
          ],
        ),
      ),
    );

    // Simulate hawker response after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Close waiting dialog

      // Generate random hawker response
      final random = Random();
      final responseType = random.nextDouble();
      
      setState(() {
        if (responseType < 0.4) { // 40% chance of acceptance
          _orderStatuses[item.id] = OrderStatus.accepted;
          _showHawkerResponse(item, true);
          _addToCart(item, proposedPrice);
        } else if (responseType < 0.7) { // 30% chance of counter offer
          _orderStatuses[item.id] = OrderStatus.counterOffer;
          // Generate counter offer between original and proposed price
          final counterOffer = (item.price + proposedPrice) / 2;
          _hawkerCounterOffers[item.id] = counterOffer;
          _showCounterOffer(item, counterOffer);
        } else { // 30% chance of rejection
          _orderStatuses[item.id] = OrderStatus.declined;
          _showHawkerResponse(item, false);
        }
      });
    });
  }

  // Add method to show hawker's counter offer
  void _showCounterOffer(InventoryItem item, double counterOffer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Counter Offer Received'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${item.name}'),
            const SizedBox(height: 8),
            Text('Original Price: ₹${item.price.toStringAsFixed(0)}'),
            Text('Your Proposal: ₹${_proposedPrices[item.id]?.last.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Text(
              'Hawker Counter Offer: ₹${counterOffer.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addToCart(item, counterOffer);
              setState(() {
                _orderStatuses[item.id] = OrderStatus.accepted;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${item.name} to cart at ₹${counterOffer.toStringAsFixed(0)}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Accept Counter Offer'),
          ),
        ],
      ),
    );
  }

  // Add method to show hawker's response
  void _showHawkerResponse(InventoryItem item, bool accepted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(accepted ? 'Price Accepted!' : 'Price Declined'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${item.name}'),
            const SizedBox(height: 8),
            Text('Original Price: ₹${item.price.toStringAsFixed(0)}'),
            Text('Your Proposal: ₹${_proposedPrices[item.id]?.last.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            Text(
              accepted 
                ? 'The hawker has accepted your proposed price!'
                : 'The hawker has declined your proposed price. You can try proposing a different price.',
              style: TextStyle(
                color: accepted ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Add this method to handle adding items to cart
  void _addToCart(InventoryItem item, [double? proposedPrice]) {
    setState(() {
      _cartItems[item.id] = item;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () => setState(() => _showCart = true),
        ),
      ),
    );
  }

  // Add this method to show the cart
  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Shopping Cart (${_cartItems.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: _cartItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your cart is empty',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems.values.elementAt(index);
                          final proposedPrice = _proposedPrices[item.id]?.last;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Original Price: ₹${item.price.toStringAsFixed(0)}'),
                                  if (proposedPrice != null)
                                    Text(
                                      'Proposed Price: ₹${proposedPrice.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    _cartItems.remove(item.id);
                                  });
                                  if (_cartItems.isEmpty) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                ),
                if (_cartItems.isNotEmpty) ...[
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _placeOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // Add dispose method to clean up controllers
  @override
  void dispose() {
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showNotifications() {
    final notifications = _demoService.getNotificationsForUser('user', _userId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                title: Text(notification['title']),
                subtitle: Text(notification['message']),
                trailing: Text(
                  _formatTimestamp(notification['timestamp']),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onTap: () {
                  _demoService.markNotificationAsRead(notification['id']);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
} 