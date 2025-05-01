import 'dart:async';
import 'package:flutter/material.dart';

class DemoDataService extends ChangeNotifier {
  static final DemoDataService _instance = DemoDataService._internal();
  factory DemoDataService() => _instance;
  DemoDataService._internal() {
    // Initialize with some dummy orders
    _initializeDummyData();
  }

  // Demo data storage
  final List<Map<String, dynamic>> _hawkers = [
    {
      'id': 'h1',
      'name': 'Mumbai Street Bites',
      'ownerName': 'Rajesh Sharma',
      'type': 'Food',
      'speciality': 'Vada Pav, Pav Bhaji',
      'rating': 4.8,
      'orders': 856,
      'revenue': 42500,
      'isActive': true,
      'isVerified': true,
      'location': {'lat': 19.0760, 'lng': 72.8777},
      'inventory': [
        {
          'id': 'i1',
          'name': 'Vada Pav',
          'price': 20.0,
          'quantity': 100,
          'unit': 'pieces',
          'description': 'Mumbai\'s favorite street food',
          'category': 'Snacks',
          'image': 'https://via.placeholder.com/150?text=Vada+Pav',
        },
        {
          'id': 'i2',
          'name': 'Pav Bhaji',
          'price': 60.0,
          'quantity': 50,
          'unit': 'plates',
          'description': 'Spicy vegetable curry with butter-toasted buns',
          'category': 'Main Course',
          'image': 'https://via.placeholder.com/150?text=Pav+Bhaji',
        },
        {
          'id': 'i3',
          'name': 'Masala Chai',
          'price': 15.0,
          'quantity': 200,
          'unit': 'cups',
          'description': 'Indian spiced tea with milk',
          'category': 'Beverages',
          'image': 'https://via.placeholder.com/150?text=Masala+Chai',
        },
        {
          'id': 'i4',
          'name': 'Samosa',
          'price': 15.0,
          'quantity': 80,
          'unit': 'pieces',
          'description': 'Crispy pastry with spiced potato filling',
          'category': 'Snacks',
          'image': 'https://via.placeholder.com/150?text=Samosa',
        },
      ],
    },
    {
      'id': 'h2',
      'name': 'Chennai Express',
      'ownerName': 'Muthu Kumar',
      'type': 'Food',
      'speciality': 'Dosa, Idli',
      'rating': 4.6,
      'orders': 723,
      'revenue': 38000,
      'isActive': true,
      'isVerified': true,
      'location': {'lat': 13.0827, 'lng': 80.2707},
      'inventory': [
        {
          'id': 'i5',
          'name': 'Masala Dosa',
          'price': 40.0,
          'quantity': 80,
          'unit': 'pieces',
          'description': 'Crispy dosa with spicy potato filling',
          'category': 'Main Course',
          'image': 'https://via.placeholder.com/150?text=Masala+Dosa',
        },
        {
          'id': 'i6',
          'name': 'Idli Sambar',
          'price': 30.0,
          'quantity': 100,
          'unit': 'plates',
          'description': 'Steamed rice cakes with lentil soup',
          'category': 'Main Course',
          'image': 'https://via.placeholder.com/150?text=Idli+Sambar',
        },
      ],
    },
  ];

  final List<Map<String, dynamic>> _pendingHawkers = [
    {
      'id': 'ph1',
      'name': 'Delhi Chaat Corner',
      'ownerName': 'Amit Verma',
      'type': 'Food',
      'speciality': 'Gol Gappe, Bhel Puri',
      'documents': {
        'id_proof': {
          'status': 'Pending',
          'url': 'https://via.placeholder.com/400x300?text=Sample+Aadhar+Card',
          'number': 'XXXX-XXXX-1234',
        },
        'address_proof': {
          'status': 'Pending',
          'url': 'https://via.placeholder.com/400x300?text=Sample+Utility+Bill',
          'number': 'BILL-123456',
        },
        'food_license': {
          'status': 'Pending',
          'url': 'https://via.placeholder.com/400x300?text=FSSAI+License',
          'number': 'FSSAI-12345',
        },
      },
      'appliedDate': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  final List<Map<String, dynamic>> _orders = [];
  final List<Map<String, dynamic>> _notifications = [];

  void _initializeDummyData() {
    // Add existing dummy orders
    final now = DateTime.now();

    // Add orders for the past month with varying patterns
    for (int i = 30; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final isWeekend = date.weekday >= 6;
      final orderCount = isWeekend ? 5 : 3; // More orders on weekends

      for (int j = 0; j < orderCount; j++) {
        final hour = 8 + (j * 3); // Spread orders throughout the day
        final orderTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          date.minute,
        );

        // Create orders with random items
        String status;
        if (i == 0) {
          // Today's orders should be mostly pending
          status = j % 3 == 0 ? 'accepted' : 'pending';
        } else if (i == 1) {
          // Yesterday's orders mix of accepted and rejected
          status = j % 2 == 0 ? 'accepted' : 'rejected';
        } else {
          // Past orders mostly accepted with some rejected
          status = j % 5 == 0 ? 'rejected' : 'accepted';
        }

        _addDummyOrder(
          'h1',
          'user-demo',
          [
            {
              'id': 'i${1 + (j % 4)}',
              'name': _hawkers[0]['inventory'][j % 4]['name'],
              'price': _hawkers[0]['inventory'][j % 4]['price'],
              'quantity': 2 + (j % 3),
              'unit': _hawkers[0]['inventory'][j % 4]['unit'],
            },
          ],
          orderTime,
          status,
        );
      }
    }

    // Add today's orders with hourly pattern
    for (int hour = 8; hour < 20; hour += 2) {
      final orderTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
      );

      // Add some orders with bids
      final hasBid = hour % 4 == 0;
      final order = _addDummyOrder(
        'h1',
        'user-demo',
        [
          {
            'id': 'i1',
            'name': 'Vada Pav',
            'price': 20.0,
            'quantity': 3,
            'unit': 'pieces',
          },
          {
            'id': 'i3',
            'name': 'Masala Chai',
            'price': 15.0,
            'quantity': 2,
            'unit': 'cups',
          },
        ],
        orderTime,
        'pending', // All recent orders start as pending
      );

      // Add bids to some orders
      if (hasBid) {
        final originalAmount = order['totalAmount'];
        order['bid'] = {
          'amount': originalAmount * 0.9, // 10% lower bid
          'timestamp': orderTime,
          'isHawkerBid': false,
        };
      }
    }

    // Add notifications
    _addNotification(
      'hawker',
      'h1',
      'New Feature Available',
      'You can now track your sales analytics in real-time!',
    );

    _addNotification(
      'hawker',
      'h1',
      'Weekend Special Reminder',
      'Don\'t forget to update your weekend special menu items.',
    );
  }

  Map<String, dynamic> _addDummyOrder(String hawkerId, String userId,
      List<Map<String, dynamic>> items, DateTime timestamp, String status) {
    final totalAmount = items.fold(
        0.0, (sum, item) => sum + (item['price'] * item['quantity']));

    final order = {
      'id': 'order-${timestamp.millisecondsSinceEpoch}-$hawkerId',
      'hawkerId': hawkerId,
      'userId': userId,
      'items': items,
      'totalAmount': totalAmount,
      'status': status,
      'timestamp': timestamp,
    };

    _orders.add(order);

    // Update hawker stats
    final hawkerIndex = _hawkers.indexWhere((h) => h['id'] == hawkerId);
    if (hawkerIndex != -1) {
      _hawkers[hawkerIndex]['orders']++;
      _hawkers[hawkerIndex]['revenue'] += totalAmount;

      // Update inventory quantities
      for (final item in items) {
        final inventoryItem = _hawkers[hawkerIndex]['inventory']
            .firstWhere((i) => i['id'] == item['id']);
        inventoryItem['quantity'] -= item['quantity'];
      }
    }

    return order;
  }

  // Getters
  List<Map<String, dynamic>> get hawkers => _hawkers;
  List<Map<String, dynamic>> get pendingHawkers => _pendingHawkers;
  List<Map<String, dynamic>> get orders => _orders;
  List<Map<String, dynamic>> get notifications => _notifications;

  // Methods for hawker management
  void approveHawker(String hawkerId) {
    final hawkerIndex = _pendingHawkers.indexWhere((h) => h['id'] == hawkerId);
    if (hawkerIndex != -1) {
      final hawker = _pendingHawkers[hawkerIndex];
      _hawkers.add({
        'id': hawker['id'],
        'name': hawker['name'],
        'ownerName': hawker['ownerName'],
        'type': hawker['type'],
        'speciality': hawker['speciality'],
        'rating': 0.0,
        'orders': 0,
        'revenue': 0,
        'isActive': true,
        'isVerified': true,
        'location': {'lat': 0.0, 'lng': 0.0},
        'inventory': [],
      });
      _pendingHawkers.removeAt(hawkerIndex);
      _addNotification(
        'Hawker Application Approved',
        'Your application for ${hawker['name']} has been approved.',
        'hawker',
        hawkerId,
      );
      notifyListeners();
    }
  }

  void rejectHawker(String hawkerId) {
    final hawkerIndex = _pendingHawkers.indexWhere((h) => h['id'] == hawkerId);
    if (hawkerIndex != -1) {
      final hawker = _pendingHawkers[hawkerIndex];
      _pendingHawkers.removeAt(hawkerIndex);
      _addNotification(
        'Hawker Application Rejected',
        'Your application for ${hawker['name']} has been rejected.',
        'hawker',
        hawkerId,
      );
      notifyListeners();
    }
  }

  // Methods for order management
  void placeOrder(Map<String, dynamic> order) {
    _orders.add(order);

    // Update hawker stats
    final hawkerIndex =
        _hawkers.indexWhere((h) => h['id'] == order['hawkerId']);
    if (hawkerIndex != -1) {
      _hawkers[hawkerIndex]['orders']++;
      _hawkers[hawkerIndex]['revenue'] += order['totalAmount'];

      // Update inventory quantities
      for (final item in order['items'] as List) {
        final inventoryItem = _hawkers[hawkerIndex]['inventory']
            .firstWhere((i) => i['id'] == item['id']);
        inventoryItem['quantity'] -= item['quantity'];
      }
    }

    // Add notifications
    _addNotification(
      'New Order Received',
      'Order #${order['id']} has been placed for ₹${order['totalAmount']}',
      'hawker',
      order['hawkerId'],
    );

    _addNotification(
      'Order Placed Successfully',
      'Your order #${order['id']} has been placed',
      'user',
      order['userId'],
    );

    notifyListeners();
  }

  void updateOrderStatus(String orderId, String status) {
    final orderIndex = orders.indexWhere((o) => o['id'] == orderId);
    if (orderIndex != -1) {
      final order = orders[orderIndex];
      order['status'] = status;
      order['updatedAt'] = DateTime.now().toIso8601String();

      // Get rejection reason if available
      final rejectionReason = order['rejectionReason'];
      final reasonText = rejectionReason != null && rejectionReason.isNotEmpty
          ? '\nReason: $rejectionReason'
          : '';

      // Add notifications with appropriate message
      String message;
      String title;

      if (status == 'accepted') {
        title = 'Order Accepted';
        message =
            'Your order #$orderId has been accepted! It will be ready soon.';

        // If order had a bid, include that information
        if (order['bid'] != null) {
          final bidAmount = order['bid']['amount'];
          message += '\nAccepted amount: ₹${bidAmount.toStringAsFixed(2)}';
        }

        // If order is accepted, update hawker's stats
        final hawkerIndex =
            _hawkers.indexWhere((h) => h['id'] == order['hawkerId']);
        if (hawkerIndex != -1) {
          final bidAmount = order['bid']?['amount'];
          final finalAmount = bidAmount ?? order['totalAmount'];
          order['finalAmount'] = finalAmount;
          _hawkers[hawkerIndex]['revenue'] += finalAmount;
        }
      } else {
        title = 'Order Rejected';
        message = 'Your order #$orderId has been rejected.$reasonText';
      }

      _addNotification(
        'user',
        order['userId'],
        title,
        message,
      );

      notifyListeners();
    }
  }

  void updateOrderBid(String orderId, double amount,
      {bool isHawkerBid = false}) {
    final orderIndex = orders.indexWhere((o) => o['id'] == orderId);
    if (orderIndex != -1) {
      final order = orders[orderIndex];

      // Update bid information
      order['bid'] = {
        'amount': amount,
        'timestamp': DateTime.now(),
        'isHawkerBid': isHawkerBid,
      };

      // Create appropriate notification
      final notificationType = isHawkerBid ? 'user' : 'hawker';
      final recipientId = isHawkerBid ? order['userId'] : order['hawkerId'];
      final originalAmount = order['totalAmount'];
      final percentageDiff =
          ((amount - originalAmount) / originalAmount * 100).toStringAsFixed(1);
      final direction = amount < originalAmount ? 'lower' : 'higher';

      final message = isHawkerBid
          ? 'Hawker has counter offered ₹$amount for order #$orderId ($percentageDiff% $direction)'
          : 'Customer has bid ₹$amount for order #$orderId ($percentageDiff% $direction)';

      _addNotification(
        notificationType,
        recipientId,
        'New Bid',
        message,
      );
    }
  }

  void acceptBid(String orderId) {
    final orderIndex = orders.indexWhere((o) => o['id'] == orderId);
    if (orderIndex != -1) {
      final order = orders[orderIndex];
      if (order['bid'] != null) {
        final bidAmount = order['bid']['amount'];
        order['finalAmount'] = bidAmount;
        updateOrderStatus(orderId, 'accepted');

        _addNotification(
          'user',
          order['userId'],
          'Bid Accepted',
          'Your bid of ₹$bidAmount for order #$orderId has been accepted!',
        );
      }
    }
  }

  void rejectBid(String orderId, {String? reason}) {
    final orderIndex = orders.indexWhere((o) => o['id'] == orderId);
    if (orderIndex != -1) {
      final order = orders[orderIndex];

      // Store the rejection reason if provided
      if (reason != null && reason.isNotEmpty) {
        order['rejectionReason'] = reason;
      }

      if (order['bid'] != null) {
        final bidAmount = order['bid']['amount'];
        updateOrderStatus(orderId, 'rejected');

        // Include reason in notification if available
        final reasonText =
            reason != null && reason.isNotEmpty ? '\nReason: $reason' : '';

        _addNotification(
          'user',
          order['userId'],
          'Bid Rejected',
          'Your bid of ₹$bidAmount for order #$orderId has been rejected.$reasonText',
        );
      } else {
        updateOrderStatus(orderId, 'rejected');

        // Include reason in notification if available
        final reasonText =
            reason != null && reason.isNotEmpty ? '\nReason: $reason' : '';

        _addNotification(
          'user',
          order['userId'],
          'Order Rejected',
          'Your order #$orderId has been rejected.$reasonText',
        );
      }
    }
  }

  // Notification management
  void _addNotification(
      String title, String message, String userType, String userId) {
    _notifications.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'userType': userType,
      'userId': userId,
      'timestamp': DateTime.now(),
      'isRead': false,
    });
    notifyListeners();
  }

  List<Map<String, dynamic>> getNotificationsForUser(
      String userType, String userId) {
    return _notifications
        .where((n) => n['userType'] == userType && n['userId'] == userId)
        .toList();
  }

  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      notifyListeners();
    }
  }

  // Inventory management
  void updateInventory(String hawkerId, String itemId, int newQuantity) {
    final hawkerIndex = _hawkers.indexWhere((h) => h['id'] == hawkerId);
    if (hawkerIndex != -1) {
      final itemIndex = _hawkers[hawkerIndex]['inventory']
          .indexWhere((i) => i['id'] == itemId);
      if (itemIndex != -1) {
        if (newQuantity <= 0) {
          _hawkers[hawkerIndex]['inventory'].removeAt(itemIndex);
        } else {
          _hawkers[hawkerIndex]['inventory'][itemIndex]['quantity'] =
              newQuantity;
        }
        notifyListeners();
      }
    }
  }

  void addInventoryItem(String hawkerId, Map<String, dynamic> item) {
    final hawkerIndex = _hawkers.indexWhere((h) => h['id'] == hawkerId);
    if (hawkerIndex != -1) {
      _hawkers[hawkerIndex]['inventory'].add(item);
      notifyListeners();
    }
  }

  // Analytics data
  Map<String, dynamic> getAnalytics() {
    final now = DateTime.now();
    final todayOrders = _orders.where((o) {
      final orderDate = o['timestamp'] as DateTime;
      return orderDate.day == now.day &&
          orderDate.month == now.month &&
          orderDate.year == now.year;
    }).toList();

    return {
      'totalHawkers': _hawkers.length,
      'activeOrders': _orders.where((o) => o['status'] == 'pending').length,
      'todayRevenue': todayOrders.fold(
        0.0,
        (sum, order) => sum + order['totalAmount'],
      ),
      'pendingVerifications': _pendingHawkers.length,
      'weeklyRevenue': _getWeeklyRevenue(),
      'monthlyRevenue': _getMonthlyRevenue(),
      'dailyRevenue': _getDailyRevenue(),
      'topSellingItems': _getTopSellingItems(),
      'revenueByCategory': _getRevenueByCategory(),
    };
  }

  Map<String, double> _getWeeklyRevenue() {
    final now = DateTime.now();
    final weeklyData = <String, double>{};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayOrders = _orders.where((o) {
        final orderDate = o['timestamp'] as DateTime;
        return orderDate.day == date.day &&
            orderDate.month == date.month &&
            orderDate.year == date.year;
      });

      final dayRevenue = dayOrders.fold(
        0.0,
        (sum, order) => sum + order['totalAmount'],
      );

      weeklyData[_formatDate(date)] = dayRevenue;
    }

    return weeklyData;
  }

  Map<String, double> _getMonthlyRevenue() {
    final now = DateTime.now();
    final monthlyData = <String, double>{};

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayOrders = _orders.where((o) {
        final orderDate = o['timestamp'] as DateTime;
        return orderDate.day == date.day &&
            orderDate.month == date.month &&
            orderDate.year == date.year;
      });

      final dayRevenue = dayOrders.fold(
        0.0,
        (sum, order) => sum + order['totalAmount'],
      );

      monthlyData[_formatDate(date)] = dayRevenue;
    }

    return monthlyData;
  }

  Map<String, double> _getDailyRevenue() {
    final now = DateTime.now();
    final dailyData = <String, double>{};

    for (int hour = 0; hour < 24; hour++) {
      final hourOrders = _orders.where((o) {
        final orderDate = o['timestamp'] as DateTime;
        return orderDate.day == now.day &&
            orderDate.month == now.month &&
            orderDate.year == now.year &&
            orderDate.hour == hour;
      });

      final hourRevenue = hourOrders.fold(
        0.0,
        (sum, order) => sum + order['totalAmount'],
      );

      dailyData['${hour.toString().padLeft(2, '0')}:00'] = hourRevenue;
    }

    return dailyData;
  }

  List<Map<String, dynamic>> _getTopSellingItems() {
    final itemSales = <String, Map<String, dynamic>>{};

    for (final order in _orders) {
      for (final item in (order['items'] as List)) {
        final itemName = item['name'];
        if (!itemSales.containsKey(itemName)) {
          itemSales[itemName] = {
            'name': itemName,
            'quantity': 0,
            'revenue': 0.0,
          };
        }
        itemSales[itemName]!['quantity'] += item['quantity'] as int;
        itemSales[itemName]!['revenue'] +=
            (item['price'] * item['quantity']) as double;
      }
    }

    final sortedItems = itemSales.values.toList()
      ..sort(
          (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

    return sortedItems;
  }

  Map<String, double> _getRevenueByCategory() {
    final categoryRevenue = <String, double>{};

    for (final order in _orders) {
      for (final item in (order['items'] as List)) {
        final hawker = _hawkers.firstWhere(
          (h) => h['id'] == order['hawkerId'],
        );
        final itemData = hawker['inventory'].firstWhere(
          (i) => i['id'] == item['id'],
        );
        final category = itemData['category'];

        categoryRevenue[category] = (categoryRevenue[category] ?? 0.0) +
            (item['price'] * item['quantity']) as double;
      }
    }

    return categoryRevenue;
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
