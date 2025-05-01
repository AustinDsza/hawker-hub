import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/hawker_provider.dart';
import 'providers/order_provider.dart';
import 'providers/inventory_provider.dart';
import 'services/supabase_service.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request location permissions
  await Geolocator.requestPermission();

  // Initialize Supabase - IMPORTANT: Replace with your actual values
  await Supabase.initialize(
    url: 'https://zbounzqavtqgvvcmxkwv.supabase.co',    // TODO: Replace with your actual URL (e.g., https://xyz.supabase.co)
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpib3VuenFhdnRxZ3Z2Y214a3d2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDM1MzMxNzUsImV4cCI6MjA1OTEwOTE3NX0.RaguF4sTn6HaAC9iIPnW54VfxV0rNYZD4CQeVbNklU0',    // TODO: Replace with your actual anon key from Supabase project settings
    debug: true,
  );

  debugPrint('Supabase initialized with URL: ${Supabase.instance.client.supabaseUrl}');
  debugPrint('Current user: ${Supabase.instance.client.auth.currentUser}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a single instance of SupabaseService to use with all providers
    final supabaseService = SupabaseService();
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(supabaseService),
        ),
        ChangeNotifierProvider<HawkerProvider>(
          create: (_) => HawkerProvider(supabaseService),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(supabaseService),
        ),
        ChangeNotifierProvider<InventoryProvider>(
          create: (_) => InventoryProvider(supabaseService),
        ),
      ],
      child: MaterialApp(
        title: 'Hawker Hub',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: Routes.splash,
        onGenerateRoute: (settings) {
          // Add debug print to track navigation
          debugPrint('Navigating to: ${settings.name}');
          
          // Get the route builder
          final routeBuilder = Routes.getRoutes()[settings.name];
          if (routeBuilder != null) {
            return MaterialPageRoute(
              builder: routeBuilder,
              settings: settings,
            );
          }
          return null;
        },
        routes: Routes.getRoutes(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
} 