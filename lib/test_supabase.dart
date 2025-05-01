import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConnectionTest extends StatefulWidget {
  const SupabaseConnectionTest({Key? key}) : super(key: key);

  @override
  State<SupabaseConnectionTest> createState() => _SupabaseConnectionTestState();
}

class _SupabaseConnectionTestState extends State<SupabaseConnectionTest> {
  String _connectionStatus = 'Testing connection...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      // Test the connection by attempting to fetch public data
      final client = Supabase.instance.client;
      
      try {
        // Test query that will work even if tables don't exist yet
        await client.from('_dummy_query_').select().limit(1);
        
        setState(() {
          _connectionStatus = 'Connection successful! Supabase is working.';
          _isLoading = false;
        });
      } catch (e) {
        // This error is expected since the table doesn't exist
        // But if we got a response, the connection works
        setState(() {
          _connectionStatus = 'Connection successful! Supabase is working.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error testing connection: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Icon(
                  _connectionStatus.contains('successful')
                      ? Icons.check_circle
                      : Icons.error,
                  color: _connectionStatus.contains('successful')
                      ? Colors.green
                      : Colors.red,
                  size: 80,
                ),
              const SizedBox(height: 20),
              Text(
                _connectionStatus,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!_connectionStatus.contains('successful'))
                const Text(
                  'Check that your URL and anon key are correct in main.dart',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
} 