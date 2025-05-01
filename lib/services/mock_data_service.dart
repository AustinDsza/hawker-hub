import 'package:uuid/uuid.dart';
import '../models/hawker.dart';
import '../models/order.dart';
import '../models/location.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Mock users
  final Map<String, Map<String, dynamic>> _users = {
    'user1': {
      'id': 'user1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '+1234567890',
      'role': 'user',
      'address': '123 Main St, City',
    },
    'hawker1': {
      'id': 'hawker1',
      'name': 'Raj Kumar',
      'email': 'raj@example.com',
      'phone': '+9876543210',
      'role': 'hawker',
      'address': '456 Market St, City',
      'isVerified': true,
      'rating': 4.5,
      'totalRatings': 100,
    },
    'admin1': {
      'id': 'admin1',
      'name': 'Admin User',
      'email': 'admin@example.com',
      'phone': '+1111111111',
      'role': 'admin',
    },
  };

  // Getter for users to allow checking by email
  List<Map<String, dynamic>> get users => _users.values.toList();

  // Mock hawkers
  final List<Map<String, dynamic>> _hawkers = [
    {
      'id': 'hawker1',
      'name': 'Raj Kumar',
      'email': 'raj@example.com',
      'phone': '+9876543210',
      'address': '456 Market St, City',
      'location': {'lat': 12.9716, 'lng': 77.5946},
      'isVerified': true,
      'isOpen': true,
      'rating': 4.5,
      'totalRatings': 100,
      'profileImage': 'https://randomuser.me/api/portraits/men/1.jpg',
      'inventory': [
        {'name': 'Apples', 'quantity': 10, 'price': 2.5, 'unit': 'kg'},
        {'name': 'Bananas', 'quantity': 15, 'price': 1.5, 'unit': 'kg'},
        {'name': 'Oranges', 'quantity': 8, 'price': 3.0, 'unit': 'kg'},
        {'name': 'Grapes', 'quantity': 5, 'price': 4.0, 'unit': 'kg'},
        {'name': 'Watermelon', 'quantity': 12, 'price': 3.5, 'unit': 'piece'},
        {'name': 'Pineapple', 'quantity': 7, 'price': 4.5, 'unit': 'piece'},
      ],
    },
    {
      'id': 'hawker2',
      'name': 'Priya Sharma',
      'email': 'priya@example.com',
      'phone': '+9876543211',
      'address': '789 Street St, City',
      'location': {'lat': 12.9746, 'lng': 77.5996},
      'isVerified': true,
      'isOpen': false,
      'rating': 4.2,
      'totalRatings': 50,
      'profileImage': 'https://randomuser.me/api/portraits/women/1.jpg',
      'inventory': [
        {'name': 'Tomatoes', 'quantity': 20, 'price': 1.0, 'unit': 'kg'},
        {'name': 'Onions', 'quantity': 25, 'price': 0.8, 'unit': 'kg'},
        {'name': 'Potatoes', 'quantity': 30, 'price': 1.2, 'unit': 'kg'},
        {'name': 'Carrots', 'quantity': 15, 'price': 1.5, 'unit': 'kg'},
        {'name': 'Cauliflower', 'quantity': 10, 'price': 2.0, 'unit': 'piece'},
        {'name': 'Cabbage', 'quantity': 12, 'price': 1.8, 'unit': 'piece'},
        {'name': 'Beans', 'quantity': 8, 'price': 2.2, 'unit': 'kg'},
      ],
    },
    {
      'id': 'hawker3',
      'name': 'Amir Khan',
      'email': 'amir@example.com',
      'phone': '+9876543212',
      'address': '101 Park Avenue, City',
      'location': {'lat': 12.9718, 'lng': 77.5940},
      'isVerified': false,
      'isOpen': false,
      'rating': 0.0,
      'totalRatings': 0,
      'profileImage': 'https://randomuser.me/api/portraits/men/2.jpg',
      'inventory': [
        {'name': 'Mangoes', 'quantity': 15, 'price': 5.0, 'unit': 'kg'},
        {'name': 'Grapes', 'quantity': 10, 'price': 3.5, 'unit': 'kg'},
        {'name': 'Strawberries', 'quantity': 5, 'price': 7.0, 'unit': 'box'},
        {'name': 'Blueberries', 'quantity': 4, 'price': 8.0, 'unit': 'box'},
        {'name': 'Kiwi', 'quantity': 20, 'price': 2.5, 'unit': 'piece'},
      ],
    },
    {
      'id': 'hawker4',
      'name': 'Sarah Johnson',
      'email': 'sarah@example.com',
      'phone': '+9876543213',
      'address': '202 Lake View, City',
      'location': {'lat': 12.9736, 'lng': 77.5926},
      'isVerified': true,
      'isOpen': true,
      'rating': 4.7,
      'totalRatings': 120,
      'profileImage': 'https://randomuser.me/api/portraits/women/2.jpg',
      'inventory': [
        {'name': 'Fresh Eggs', 'quantity': 50, 'price': 0.5, 'unit': 'piece'},
        {'name': 'Milk', 'quantity': 20, 'price': 1.2, 'unit': 'liter'},
        {'name': 'Cheese', 'quantity': 10, 'price': 3.5, 'unit': '100g'},
        {'name': 'Butter', 'quantity': 15, 'price': 2.0, 'unit': '100g'},
        {'name': 'Yogurt', 'quantity': 20, 'price': 1.8, 'unit': 'cup'},
        {'name': 'Cream', 'quantity': 10, 'price': 2.5, 'unit': '200ml'},
        {'name': 'Paneer', 'quantity': 8, 'price': 4.0, 'unit': '250g'},
      ],
    },
    {
      'id': 'hawker5',
      'name': 'Miguel Rodriguez',
      'email': 'miguel@example.com',
      'phone': '+9876543214',
      'address': '303 Mountain View, City',
      'location': {'lat': 12.9756, 'lng': 77.5976},
      'isVerified': true,
      'isOpen': true,
      'rating': 4.3,
      'totalRatings': 85,
      'profileImage': 'https://randomuser.me/api/portraits/men/3.jpg',
      'inventory': [
        {'name': 'Corn', 'quantity': 30, 'price': 0.7, 'unit': 'piece'},
        {'name': 'Bell Peppers', 'quantity': 15, 'price': 1.8, 'unit': 'kg'},
        {'name': 'Chili', 'quantity': 10, 'price': 2.0, 'unit': 'kg'},
        {'name': 'Cilantro', 'quantity': 20, 'price': 0.5, 'unit': 'bunch'},
        {'name': 'Avocado', 'quantity': 15, 'price': 3.0, 'unit': 'piece'},
        {'name': 'Lime', 'quantity': 25, 'price': 0.4, 'unit': 'piece'},
        {'name': 'Tortillas', 'quantity': 50, 'price': 0.2, 'unit': 'piece'},
      ],
    },
    {
      'id': 'hawker6',
      'name': 'Li Wei',
      'email': 'liwei@example.com',
      'phone': '+9876543215',
      'address': '404 River Road, City',
      'location': {'lat': 12.9776, 'lng': 77.5916},
      'isVerified': true,
      'isOpen': false,
      'rating': 4.6,
      'totalRatings': 110,
      'profileImage': 'https://randomuser.me/api/portraits/men/4.jpg',
      'inventory': [
        {'name': 'Noodles', 'quantity': 50, 'price': 1.5, 'unit': 'pack'},
        {'name': 'Tofu', 'quantity': 20, 'price': 2.0, 'unit': 'kg'},
        {'name': 'Bean Sprouts', 'quantity': 15, 'price': 1.2, 'unit': 'kg'},
        {'name': 'Bok Choy', 'quantity': 12, 'price': 1.8, 'unit': 'kg'},
        {'name': 'Shiitake Mushrooms', 'quantity': 10, 'price': 4.0, 'unit': 'kg'},
        {'name': 'Rice', 'quantity': 25, 'price': 1.2, 'unit': 'kg'},
        {'name': 'Soy Sauce', 'quantity': 15, 'price': 2.5, 'unit': 'bottle'},
        {'name': 'Ginger', 'quantity': 8, 'price': 2.0, 'unit': 'kg'},
      ],
    },
    {
      'id': 'hawker7',
      'name': 'Anna Smith',
      'email': 'anna@example.com',
      'phone': '+9876543216',
      'address': '505 Valley Road, City',
      'location': {'lat': 12.9726, 'lng': 77.5936},
      'isVerified': false,
      'isOpen': false,
      'rating': 0.0,
      'totalRatings': 0,
      'profileImage': 'https://randomuser.me/api/portraits/women/5.jpg',
      'inventory': [
        {'name': 'Bread', 'quantity': 20, 'price': 1.0, 'unit': 'loaf'},
        {'name': 'Pastries', 'quantity': 30, 'price': 1.5, 'unit': 'piece'},
        {'name': 'Cookies', 'quantity': 50, 'price': 0.5, 'unit': 'piece'},
        {'name': 'Cakes', 'quantity': 10, 'price': 8.0, 'unit': 'piece'},
        {'name': 'Muffins', 'quantity': 25, 'price': 1.2, 'unit': 'piece'},
        {'name': 'Donuts', 'quantity': 30, 'price': 1.0, 'unit': 'piece'},
        {'name': 'Croissants', 'quantity': 15, 'price': 1.8, 'unit': 'piece'},
      ],
    },
    {
      'id': 'hawker8',
      'name': 'David Chen',
      'email': 'david@example.com',
      'phone': '+9876543217',
      'address': '606 Sunset Boulevard, City',
      'location': {'lat': 12.9766, 'lng': 77.5966},
      'isVerified': true,
      'isOpen': true,
      'rating': 4.8,
      'totalRatings': 150,
      'profileImage': 'https://randomuser.me/api/portraits/men/5.jpg',
      'inventory': [
        {'name': 'Fresh Fish', 'quantity': 20, 'price': 8.0, 'unit': 'kg'},
        {'name': 'Prawns', 'quantity': 15, 'price': 12.0, 'unit': 'kg'},
        {'name': 'Crab', 'quantity': 10, 'price': 15.0, 'unit': 'kg'},
        {'name': 'Squid', 'quantity': 12, 'price': 10.0, 'unit': 'kg'},
        {'name': 'Mussels', 'quantity': 8, 'price': 7.0, 'unit': 'kg'},
        {'name': 'Oysters', 'quantity': 24, 'price': 1.5, 'unit': 'piece'},
      ],
    },
    {
      'id': 'hawker9',
      'name': 'Maria Garcia',
      'email': 'maria@example.com',
      'phone': '+9876543218',
      'address': '707 Pine Street, City',
      'location': {'lat': 12.9731, 'lng': 77.5959},
      'isVerified': true,
      'isOpen': true,
      'rating': 4.4,
      'totalRatings': 90,
      'profileImage': 'https://randomuser.me/api/portraits/women/6.jpg',
      'inventory': [
        {'name': 'Tacos', 'quantity': 40, 'price': 2.0, 'unit': 'piece'},
        {'name': 'Burritos', 'quantity': 30, 'price': 3.5, 'unit': 'piece'},
        {'name': 'Enchiladas', 'quantity': 25, 'price': 4.0, 'unit': 'piece'},
        {'name': 'Nachos', 'quantity': 20, 'price': 5.0, 'unit': 'plate'},
        {'name': 'Quesadillas', 'quantity': 25, 'price': 3.0, 'unit': 'piece'},
        {'name': 'Guacamole', 'quantity': 15, 'price': 2.5, 'unit': 'cup'},
        {'name': 'Salsa', 'quantity': 20, 'price': 2.0, 'unit': 'cup'},
      ],
    },
    {
      'id': 'hawker10',
      'name': 'Ahmed Ali',
      'email': 'ahmed@example.com',
      'phone': '+9876543219',
      'address': '808 Oak Avenue, City',
      'location': {'lat': 12.9741, 'lng': 77.5969},
      'isVerified': true,
      'isOpen': false,
      'rating': 4.5,
      'totalRatings': 75,
      'profileImage': 'https://randomuser.me/api/portraits/men/6.jpg',
      'inventory': [
        {'name': 'Falafel', 'quantity': 50, 'price': 0.8, 'unit': 'piece'},
        {'name': 'Hummus', 'quantity': 20, 'price': 3.0, 'unit': 'cup'},
        {'name': 'Pita Bread', 'quantity': 40, 'price': 0.5, 'unit': 'piece'},
        {'name': 'Shawarma', 'quantity': 30, 'price': 4.5, 'unit': 'roll'},
        {'name': 'Baklava', 'quantity': 35, 'price': 1.2, 'unit': 'piece'},
        {'name': 'Dates', 'quantity': 25, 'price': 5.0, 'unit': 'kg'},
        {'name': 'Olives', 'quantity': 15, 'price': 4.0, 'unit': 'kg'},
      ],
    },
  ];

  // Mock orders
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'order1',
      'userId': 'user1',
      'hawkerId': 'hawker1',
      'items': [
        {'name': 'Apples', 'quantity': 2, 'price': 2.5, 'unit': 'kg'},
        {'name': 'Bananas', 'quantity': 3, 'price': 1.5, 'unit': 'kg'},
      ],
      'totalAmount': 9.5,
      'status': 'pending',
      'createdAt': DateTime.now().subtract(Duration(hours: 1)),
      'deliveryAddress': '123 Main St, City',
      'notes': 'Please deliver in the evening',
    },
    {
      'id': 'order2',
      'userId': 'user1',
      'hawkerId': 'hawker1',
      'items': [
        {'name': 'Oranges', 'quantity': 2, 'price': 3.0, 'unit': 'kg'},
      ],
      'totalAmount': 6.0,
      'status': 'delivered',
      'createdAt': DateTime.now().subtract(Duration(days: 1)),
      'updatedAt': DateTime.now().subtract(Duration(hours: 10)),
      'deliveryAddress': '123 Main St, City',
      'notes': null,
      'rating': 4.5,
      'isRated': true,
    },
    {
      'id': 'order3',
      'userId': 'user1',
      'hawkerId': 'hawker2',
      'items': [
        {'name': 'Tomatoes', 'quantity': 3, 'price': 1.0, 'unit': 'kg'},
        {'name': 'Onions', 'quantity': 2, 'price': 0.8, 'unit': 'kg'},
      ],
      'totalAmount': 4.6,
      'status': 'confirmed',
      'createdAt': DateTime.now().subtract(Duration(hours: 3)),
      'updatedAt': DateTime.now().subtract(Duration(hours: 2)),
      'deliveryAddress': '123 Main St, City',
      'notes': 'Please call before delivery',
    },
    {
      'id': 'order4',
      'userId': 'user1',
      'hawkerId': 'hawker4',
      'items': [
        {'name': 'Fresh Eggs', 'quantity': 10, 'price': 0.5, 'unit': 'piece'},
        {'name': 'Milk', 'quantity': 2, 'price': 1.2, 'unit': 'liter'},
      ],
      'totalAmount': 7.4,
      'status': 'dispatched',
      'createdAt': DateTime.now().subtract(Duration(hours: 5)),
      'updatedAt': DateTime.now().subtract(Duration(hours: 1)),
      'deliveryAddress': '123 Main St, City',
      'notes': null,
    },
  ];

  // Authentication methods
  Future<Map<String, dynamic>> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    
    // In a real app, we would validate the password
    // For demo purposes, we'll just check if the email exists
    final user = _users.values.firstWhere(
      (user) => user['email'] == email,
      orElse: () => throw Exception('User not found with this email'),
    );
    
    return user;
  }

  Future<Map<String, dynamic>> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
    String phone,
    String role,
  ) async {
    await Future.delayed(Duration(seconds: 1));
    final id = Uuid().v4();
    final user = {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
    _users[id] = user;
    return user;
  }

  // Hawker methods
  Future<List<Hawker>> getNearbyHawkers(double lat, double lng, double radius) async {
    await Future.delayed(Duration(seconds: 1));
    
    final userLocation = Location(latitude: lat, longitude: lng);
    
    return _hawkers
        .where((hawker) => hawker['isVerified'] == true)
        .map((hawker) {
          final hawkerLoc = Location.fromJson(Map<String, dynamic>.from(hawker['location']));
          final distance = Location.calculateDistance(userLocation, hawkerLoc);
          
          if (distance <= radius) {
            return Hawker.fromJson({
              ...hawker,
              'distance': distance,
            });
          }
          return null;
        })
        .where((hawker) => hawker != null)
        .cast<Hawker>()
        .toList();
  }

  Future<List<Hawker>> getUnverifiedHawkers() async {
    await Future.delayed(Duration(seconds: 1));
    return _hawkers
        .where((hawker) => hawker['isVerified'] == false)
        .map((hawker) => Hawker.fromJson(hawker))
        .toList();
  }

  Future<void> verifyHawker(String hawkerId) async {
    await Future.delayed(Duration(seconds: 1));
    final hawker = _hawkers.firstWhere((h) => h['id'] == hawkerId);
    hawker['isVerified'] = true;
  }

  Future<void> rejectHawker(String hawkerId) async {
    await Future.delayed(Duration(seconds: 1));
    _hawkers.removeWhere((h) => h['id'] == hawkerId);
  }

  Future<void> updateHawkerStatus(String hawkerId, bool isOpen) async {
    await Future.delayed(Duration(seconds: 1));
    final hawker = _hawkers.firstWhere((h) => h['id'] == hawkerId);
    hawker['isOpen'] = isOpen;
  }

  Future<void> updateHawkerInventory(String hawkerId, List<Map<String, dynamic>> inventory) async {
    await Future.delayed(Duration(seconds: 1));
    final hawker = _hawkers.firstWhere((h) => h['id'] == hawkerId);
    hawker['inventory'] = inventory;
  }

  // Order methods
  Future<Order> placeOrder({
    required String userId,
    required String hawkerId,
    required List<OrderItem> items,
    required double totalAmount,
    required String deliveryAddress,
    String? notes,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    
    final orderId = Uuid().v4();
    final newOrder = {
      'id': orderId,
      'userId': userId,
      'hawkerId': hawkerId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': 'pending',
      'createdAt': DateTime.now(),
      'deliveryAddress': deliveryAddress,
      'notes': notes,
    };
    
    _orders.add(newOrder);
    return Order.fromJson(newOrder);
  }

  Future<List<Order>> getUserOrders(String userId) async {
    await Future.delayed(Duration(seconds: 1));
    return _orders
        .where((order) => order['userId'] == userId)
        .map((order) => Order.fromJson(order))
        .toList();
  }

  Future<List<Order>> getHawkerOrders(String hawkerId) async {
    await Future.delayed(Duration(seconds: 1));
    return _orders
        .where((order) => order['hawkerId'] == hawkerId)
        .map((order) => Order.fromJson(order))
        .toList();
  }

  Future<List<Order>> getAllOrders() async {
    await Future.delayed(Duration(seconds: 1));
    return _orders.map((order) => Order.fromJson(order)).toList();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await Future.delayed(Duration(seconds: 1));
    final order = _orders.firstWhere((o) => o['id'] == orderId);
    order['status'] = status.toString().split('.').last;
    order['updatedAt'] = DateTime.now();
  }

  Future<void> rateOrder(String orderId, double rating) async {
    await Future.delayed(Duration(seconds: 1));
    final order = _orders.firstWhere((o) => o['id'] == orderId);
    order['rating'] = rating;
    order['isRated'] = true;
  }
} 