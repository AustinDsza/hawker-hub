import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/location.dart';
import 'package:uuid/uuid.dart';

/// This is a utility script to populate your Supabase database with sample data
/// for testing purposes. Run this once after setting up your Supabase tables.
///
/// To use:
/// 1. Update the Supabase credentials in main.dart
/// 2. Run the app in debug mode
/// 3. Tap the purple cloud button
/// 4. Tap "Load Sample Data" button
class SampleDataLoader extends StatefulWidget {
  const SampleDataLoader({Key? key}) : super(key: key);

  @override
  State<SampleDataLoader> createState() => _SampleDataLoaderState();
}

class _SampleDataLoaderState extends State<SampleDataLoader> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  String _status = '';
  int _completedSteps = 0;
  int _totalSteps = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample Data Loader'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hawker Hub - Data Loader',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                'This utility will populate your Supabase database with sample data for testing.',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: _completedSteps / _totalSteps,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$_status ($_completedSteps/$_totalSteps)',
                      style: TextStyle(color: Colors.purple[700]),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _loadSampleData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Load Sample Data'),
                ),
              const SizedBox(height: 24),
              if (!_isLoading && _completedSteps > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Sample data loaded successfully!',
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadSampleData() async {
    setState(() {
      _isLoading = true;
      _status = 'Starting...';
      _completedSteps = 0;
    });

    try {
      // Step 1: Create sample users
      setState(() {
        _status = 'Creating sample users';
      });
      await _createSampleUsers();
      setState(() {
        _completedSteps++;
      });

      // Step 2: Create sample hawkers
      setState(() {
        _status = 'Creating sample hawkers';
      });
      await _createSampleHawkers();
      setState(() {
        _completedSteps++;
      });

      // Step 3: Add inventory to hawkers
      setState(() {
        _status = 'Adding inventory to hawkers';
      });
      await _addSampleInventory();
      setState(() {
        _completedSteps++;
      });

      // Step 4: Create sample orders
      setState(() {
        _status = 'Creating sample orders';
      });
      await _createSampleOrders();
      setState(() {
        _completedSteps++;
      });

      setState(() {
        _status = 'Completed!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createSampleUsers() async {
    try {
      // Create admin user directly in the database
      final adminEmail = 'admin@example.com';
      final adminPassword = 'admin123';
      
      // Check if admin exists in users table
      final adminData = await supabase
          .from('users')
          .select()
          .eq('email', adminEmail)
          .maybeSingle();
          
      if (adminData == null) {
        debugPrint('Creating admin user directly in database');
        // Create admin in auth
        try {
          // Try to sign up
          final response = await supabase.auth.signUp(
            email: adminEmail,
            password: adminPassword,
          );
          
          if (response.user != null) {
            // Insert into users table
            await supabase.from('users').insert({
              'id': response.user!.id,
              'name': 'Admin User',
              'email': adminEmail,
              'phone': '+919876543210',
              'role': 'admin',
            });
            debugPrint('Created admin user: ${response.user!.id}');
          } else {
            // If sign up fails, try direct insert with UUID
            final uuid = const Uuid().v4();
            await supabase.from('users').insert({
              'id': uuid,
              'name': 'Admin User',
              'email': adminEmail,
              'phone': '+919876543210',
              'role': 'admin',
            });
            debugPrint('Created admin user with generated UUID: $uuid');
          }
        } catch (e) {
          debugPrint('Error creating admin user: $e');
          // Try logging in instead
          try {
            final signInResult = await supabase.auth.signInWithPassword(
              email: adminEmail,
              password: adminPassword,
            );
            if (signInResult.user != null) {
              debugPrint('Admin login successful: ${signInResult.user!.id}');
            }
          } catch (loginError) {
            debugPrint('Admin login error: $loginError');
          }
        }
      } else {
        debugPrint('Admin user already exists: ${adminData['id']}');
      }
      
      // Create regular user directly in the database
      final userEmail = 'user@example.com';
      final userPassword = 'user123';
      
      // Check if user exists in users table
      final userData = await supabase
          .from('users')
          .select()
          .eq('email', userEmail)
          .maybeSingle();
          
      if (userData == null) {
        debugPrint('Creating regular user directly in database');
        try {
          // Try to sign up
          final response = await supabase.auth.signUp(
            email: userEmail,
            password: userPassword,
          );
          
          if (response.user != null) {
            // Insert into users table
            await supabase.from('users').insert({
              'id': response.user!.id,
              'name': 'Test User',
              'email': userEmail,
              'phone': '+919876543211',
              'role': 'user',
            });
            debugPrint('Created test user: ${response.user!.id}');
          } else {
            // If sign up fails, try direct insert with UUID
            final uuid = const Uuid().v4();
            await supabase.from('users').insert({
              'id': uuid,
              'name': 'Test User',
              'email': userEmail,
              'phone': '+919876543211',
              'role': 'user',
            });
            debugPrint('Created test user with generated UUID: $uuid');
          }
        } catch (e) {
          debugPrint('Error creating test user: $e');
          // Try logging in instead
          try {
            final signInResult = await supabase.auth.signInWithPassword(
              email: userEmail,
              password: userPassword,
            );
            if (signInResult.user != null) {
              debugPrint('Test user login successful: ${signInResult.user!.id}');
            }
          } catch (loginError) {
            debugPrint('Test user login error: $loginError');
          }
        }
      } else {
        debugPrint('Test user already exists: ${userData['id']}');
      }
      
      // Display test account details
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Test Account Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin: $adminEmail / $adminPassword'),
              const SizedBox(height: 8),
              Text('User: $userEmail / $userPassword'),
              const SizedBox(height: 8),
              const Text('Hawker: hawker0@example.com / hawker123'),
              const SizedBox(height: 16),
              const Text('Use these to log in to the app.', style: TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 16),
              const Text('Note: If login fails, you may need to manually create these users in Supabase Auth.',
                style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
    } catch (error) {
      debugPrint('_createSampleUsers error: $error');
      throw Exception('Failed to create sample users: $error');
    }
  }

  Future<void> _createSampleHawkers() async {
    // Sample hawker locations (in Delhi, India)
    final locations = [
      {'name': 'Karol Bagh', 'lat': 28.6512, 'lng': 77.1910},
      {'name': 'Connaught Place', 'lat': 28.6314, 'lng': 77.2167},
      {'name': 'Chandni Chowk', 'lat': 28.6505, 'lng': 77.2303},
      {'name': 'Lajpat Nagar', 'lat': 28.5700, 'lng': 77.2400},
      {'name': 'Saket', 'lat': 28.5244, 'lng': 77.2167},
    ];

    for (var i = 0; i < locations.length; i++) {
      final location = locations[i];
      final hawkerEmail = 'hawker$i@example.com';
      
      // Check if hawker already exists
      final hawkerData = await supabase
          .from('users')
          .select()
          .eq('email', hawkerEmail)
          .maybeSingle();

      if (hawkerData == null) {
        try {
          // Create auth user
          final AuthResponse res = await supabase.auth.signUp(
            email: hawkerEmail,
            password: 'hawker123',
          );

          if (res.user != null) {
            // Add to users table
            await supabase.from('users').insert({
              'id': res.user!.id,
              'name': 'Delhi ${location['name']} Hawker',
              'email': hawkerEmail,
              'phone': '+91987654321$i',
              'role': 'hawker',
            });

            // Add to hawkers table
            await supabase.from('hawkers').insert({
              'id': res.user!.id,
              'name': 'Delhi ${location['name']} Food',
              'email': hawkerEmail,
              'phone': '+91987654321$i',
              'address': '${location['name']}, Delhi, India',
              'location': {
                'latitude': location['lat'],
                'longitude': location['lng'],
              },
              'is_verified': true,
              'is_open': i % 2 == 0, // Alternate open/closed status
              'rating': (3 + i % 3).toDouble(), // Ratings between 3-5
              'total_ratings': 10 + (i * 5), // Different number of ratings
              'profile_image': null, // No profile image initially
            });
          }
        } catch (e) {
          // Handle existing auth user
          try {
            final res = await supabase.auth.signInWithPassword(
              email: hawkerEmail,
              password: 'hawker123',
            );
            
            if (res.user != null) {
              // Add to users table
              await supabase.from('users').insert({
                'id': res.user!.id,
                'name': 'Delhi ${location['name']} Hawker',
                'email': hawkerEmail,
                'phone': '+91987654321$i',
                'role': 'hawker',
              });

              // Add to hawkers table
              await supabase.from('hawkers').insert({
                'id': res.user!.id,
                'name': 'Delhi ${location['name']} Food',
                'email': hawkerEmail,
                'phone': '+91987654321$i',
                'address': '${location['name']}, Delhi, India',
                'location': {
                  'latitude': location['lat'],
                  'longitude': location['lng'],
                },
                'is_verified': true,
                'is_open': i % 2 == 0, // Alternate open/closed status
                'rating': (3 + i % 3).toDouble(), // Ratings between 3-5
                'total_ratings': 10 + (i * 5), // Different number of ratings
                'profile_image': null, // No profile image initially
              });
            }
          } catch (e) {
            debugPrint('Error creating hawker $i: $e');
          }
        }
      }
    }

    // Create one unverified hawker for admin testing
    final unverifiedHawkerEmail = 'new_hawker@example.com';
    final unverifiedData = await supabase
        .from('users')
        .select()
        .eq('email', unverifiedHawkerEmail)
        .maybeSingle();

    if (unverifiedData == null) {
      try {
        final AuthResponse res = await supabase.auth.signUp(
          email: unverifiedHawkerEmail,
          password: 'hawker123',
        );

        if (res.user != null) {
          await supabase.from('users').insert({
            'id': res.user!.id,
            'name': 'New Hawker',
            'email': unverifiedHawkerEmail,
            'phone': '+919876543299',
            'role': 'hawker',
          });

          await supabase.from('hawkers').insert({
            'id': res.user!.id,
            'name': 'New Delhi Food Stall',
            'email': unverifiedHawkerEmail,
            'phone': '+919876543299',
            'address': 'Rajouri Garden, Delhi, India',
            'location': {
              'latitude': 28.6384,
              'longitude': 77.1185,
            },
            'is_verified': false,
            'is_open': false,
          });
        }
      } catch (e) {
        // Handle existing auth user
        try {
          final res = await supabase.auth.signInWithPassword(
            email: unverifiedHawkerEmail,
            password: 'hawker123',
          );
          
          if (res.user != null) {
            await supabase.from('users').insert({
              'id': res.user!.id,
              'name': 'New Hawker',
              'email': unverifiedHawkerEmail,
              'phone': '+919876543299',
              'role': 'hawker',
            });

            await supabase.from('hawkers').insert({
              'id': res.user!.id,
              'name': 'New Delhi Food Stall',
              'email': unverifiedHawkerEmail,
              'phone': '+919876543299',
              'address': 'Rajouri Garden, Delhi, India',
              'location': {
                'latitude': 28.6384,
                'longitude': 77.1185,
              },
              'is_verified': false,
              'is_open': false,
            });
          }
        } catch (e) {
          debugPrint('Error creating unverified hawker: $e');
        }
      }
    }
  }

  Future<void> _addSampleInventory() async {
    // Load sample inventory items
    final String inventoryJson = await rootBundle.loadString('sample_inventory.json');
    final List<dynamic> inventoryItems = json.decode(inventoryJson);
    
    // Get all hawkers
    final hawkersData = await supabase
        .from('hawkers')
        .select('id')
        .eq('is_verified', true);
    
    for (var hawker in hawkersData) {
      final hawkerId = hawker['id'];
      
      // Check if hawker already has inventory
      final existingItems = await supabase
          .from('inventory')
          .select('id')
          .eq('hawker_id', hawkerId);
      
      if (existingItems.isEmpty) {
        // Add a random selection of 5-10 items to each hawker
        final itemCount = 5 + (hawkerId.hashCode % 6); // 5-10 items
        final shuffledItems = List.from(inventoryItems)..shuffle();
        final selectedItems = shuffledItems.take(itemCount).toList();
        
        for (var item in selectedItems) {
          await supabase.from('inventory').insert({
            'hawker_id': hawkerId,
            'name': item['name'],
            'price': item['price'],
            'quantity': item['quantity'],
            'unit': item['unit'],
          });
        }
      }
    }
  }

  Future<void> _createSampleOrders() async {
    // Get a regular user
    final userData = await supabase
        .from('users')
        .select('id')
        .eq('role', 'user')
        .limit(1)
        .single();
    
    final userId = userData['id'];
    
    // Get verified hawkers
    final hawkersData = await supabase
        .from('hawkers')
        .select('id, inventory(*)')
        .eq('is_verified', true);
    
    // Create 1-2 orders for each hawker
    for (var hawker in hawkersData) {
      final hawkerId = hawker['id'];
      final inventory = hawker['inventory'];
      
      if (inventory.isEmpty) continue;
      
      // Check existing orders count
      final existingOrders = await supabase
          .from('orders')
          .select('id')
          .eq('hawker_id', hawkerId)
          .eq('user_id', userId);
      
      // Only create sample orders if none exist
      if (existingOrders.isEmpty) {
        // Create 1-2 orders
        final orderCount = 1 + (hawkerId.hashCode % 2);
        
        for (var i = 0; i < orderCount; i++) {
          // Select 1-3 random items from inventory
          final itemCount = 1 + (i % 3);
          final shuffledItems = List.from(inventory)..shuffle();
          final selectedItems = shuffledItems.take(itemCount).toList();
          
          // Calculate total amount
          double totalAmount = 0;
          for (var item in selectedItems) {
            final price = item['price'] is double 
                ? item['price'] 
                : double.parse(item['price'].toString());
            final quantity = 1 + (item['id'].hashCode % 3); // 1-3 quantity
            totalAmount += price * quantity;
          }
          
          // Create order
          final orderStatus = i == 0 ? 'completed' : 'pending';
          final orderRes = await supabase.from('orders').insert({
            'user_id': userId,
            'hawker_id': hawkerId,
            'status': orderStatus,
            'total_amount': totalAmount,
            'delivery_address': 'Test Address, Delhi, India',
            'notes': 'This is a sample order for testing',
            'rating': orderStatus == 'completed' ? 4 + (hawkerId.hashCode % 2) : null, // 4-5 rating
            'review': orderStatus == 'completed' ? 'Great food, quick delivery!' : null,
          }).select('id');
          
          final orderId = orderRes[0]['id'];
          
          // Add order items
          for (var item in selectedItems) {
            final price = item['price'] is double 
                ? item['price'] 
                : double.parse(item['price'].toString());
            final quantity = 1 + (item['id'].hashCode % 3); // 1-3 quantity
            
            await supabase.from('order_items').insert({
              'order_id': orderId,
              'name': item['name'],
              'price': price,
              'quantity': quantity,
              'unit': item['unit'],
            });
          }
        }
      }
    }
  }
} 