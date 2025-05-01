import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/hawker_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/hawker.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../widgets/hawker_verification_card.dart';
import '../../widgets/order_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../../services/demo_data_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Random _random = Random();
  final DemoDataService _demoService = DemoDataService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Analytics'),
            Tab(text: 'Hawkers'),
            Tab(text: 'Verifications'),
            Tab(text: 'Add Hawker'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalyticsTab(),
          _buildHawkersTab(),
          _buildVerificationsTab(),
          _buildAddHawkerTab(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final analytics = _demoService.getAnalytics();
    final List<double> dailyRevenue = List.generate(7, (i) => _random.nextDouble() * 10000);
    final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, double> categoryData = {
      'Food': 45.0,
      'Beverages': 25.0,
      'Snacks': 20.0,
      'Others': 10.0,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Platform Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildOverviewCard(
                title: 'Total Hawkers',
                value: analytics['totalHawkers'].toString(),
                icon: Icons.store,
                color: Colors.blue,
              ),
              _buildOverviewCard(
                title: 'Active Orders',
                value: analytics['activeOrders'].toString(),
                icon: Icons.shopping_cart,
                color: Colors.green,
              ),
              _buildOverviewCard(
                title: 'Today\'s Revenue',
                value: '₹${analytics['todayRevenue'].toStringAsFixed(2)}',
                icon: Icons.monetization_on,
                color: Colors.orange,
              ),
              _buildOverviewCard(
                title: 'Pending Verifications',
                value: analytics['pendingVerifications'].toString(),
                icon: Icons.verified_user,
                color: Colors.purple,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Revenue Trend (Last 7 Days)', 
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 2000,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  weekDays[value.toInt() % weekDays.length],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 2000,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '₹${value.toInt()}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: dailyRevenue.asMap().entries.map((e) => 
                              FlSpot(e.key.toDouble(), e.value)
                            ).toList(),
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: [Colors.blue.shade300, Colors.blue.shade700],
                            ),
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: Colors.blue.shade700,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade200.withOpacity(0.3),
                                  Colors.blue.shade50.withOpacity(0.1),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text('Category Distribution', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: categoryData.entries.map((e) => 
                  PieChartSectionData(
                    value: e.value,
                    title: '${e.key}\n${e.value}%',
                    color: Colors.primaries[categoryData.keys.toList().indexOf(e.key)],
                    radius: 100,
                  ),
                ).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildHawkersTab() {
    final hawkers = _demoService.hawkers;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search hawkers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: hawkers.length,
            itemBuilder: (context, index) {
              final hawker = hawkers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(hawker['name'][0]),
                  ),
                  title: Text(hawker['name']),
                  subtitle: Text('${hawker['type']} • Rating: ${hawker['rating']}⭐'),
                  trailing: Switch(
                    value: hawker['isActive'],
                    onChanged: (value) {
                      setState(() {
                        hawker['isActive'] = value;
                      });
                    },
                  ),
                  onTap: () => _showHawkerDetails(hawker),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationsTab() {
    final pendingHawkers = _demoService.pendingHawkers;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingHawkers.length,
      itemBuilder: (context, index) {
        final verification = pendingHawkers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      verification['name'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Applied ${verification['appliedDate'].difference(DateTime.now()).inDays.abs()} days ago',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Type: ${verification['type']}'),
                const SizedBox(height: 8),
                const Text('Documents Submitted:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: verification['documents'].entries.map<Widget>((doc) {
                    return Chip(
                      label: Text(doc.key.split('_').join(' ').toUpperCase()),
                      backgroundColor: doc.value['status'] == 'Verified' ? Colors.green[100] : Colors.orange[100],
                      avatar: Icon(
                        doc.value['status'] == 'Verified' ? Icons.check_circle : Icons.pending,
                        color: doc.value['status'] == 'Verified' ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _showDocuments(verification),
                      child: const Text('View Documents'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _demoService.approveHawker(verification['id']);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _demoService.rejectHawker(verification['id']);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddHawkerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add New Hawker',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              labelText: 'Business Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Owner Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Business Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: ['Food', 'Beverages', 'Snacks', 'Others']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {},
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Required Documents',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDocumentUploadCard(
            'ID Proof',
            'Upload Aadhar Card/PAN Card/Voter ID',
            Icons.person,
          ),
          const SizedBox(height: 12),
          _buildDocumentUploadCard(
            'Address Proof',
            'Upload Utility Bill/Rent Agreement',
            Icons.home,
          ),
          const SizedBox(height: 12),
          _buildDocumentUploadCard(
            'Business License',
            'Upload FSSAI License/Shop Act License',
            Icons.business,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _addHawker,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add Hawker'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard(String title, String subtitle, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: TextButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload'),
          onPressed: () => _uploadDocument(title),
        ),
      ),
    );
  }

  void _showHawkerDetails(Map<String, dynamic> hawker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(hawker['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${hawker['type']}'),
            Text('Rating: ${hawker['rating']}⭐'),
            Text('Total Orders: ${hawker['orders']}'),
            Text('Revenue: ₹${hawker['revenue']}'),
            const SizedBox(height: 16),
            const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...List.generate(3, (i) => ListTile(
              dense: true,
              title: Text('Order #${1000 + i}'),
              subtitle: Text('₹${_random.nextInt(500)} • ${DateTime.now().subtract(Duration(hours: i))}'),
            )),
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

  void _showDocuments(Map<String, dynamic> verification) {
    final List<Map<String, String>> dummyDocs = [
      {
        'type': 'ID Proof',
        'url': 'https://via.placeholder.com/400x300?text=Sample+Aadhar+Card',
        'status': 'Verified',
        'number': 'XXXX-XXXX-${_random.nextInt(9999)}',
      },
      {
        'type': 'Address Proof',
        'url': 'https://via.placeholder.com/400x300?text=Sample+Utility+Bill',
        'status': 'Pending',
        'number': 'BILL-${_random.nextInt(999999)}',
      },
      {
        'type': 'Food License',
        'url': 'https://via.placeholder.com/400x300?text=FSSAI+License',
        'status': 'Verified',
        'number': 'FSSAI-${_random.nextInt(99999)}',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('${verification['name']} Documents'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: dummyDocs.length,
            itemBuilder: (context, index) {
              final doc = dummyDocs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(doc['type']!),
                      subtitle: Text('Document No: ${doc['number']}'),
                      trailing: Chip(
                        label: Text(doc['status']!),
                        backgroundColor: doc['status'] == 'Verified' 
                          ? Colors.green.shade100 
                          : Colors.orange.shade100,
                      ),
                    ),
                    Image.network(doc['url']!),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Downloading ${doc['type']}')),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.verified_user),
                            label: const Text('Verify'),
                            onPressed: doc['status'] == 'Pending' ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${doc['type']} verified successfully')),
                              );
                              Navigator.pop(context);
                            } : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _uploadDocument(String documentType) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload $documentType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // Simulate camera capture
                Future.delayed(const Duration(seconds: 1), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$documentType photo captured successfully')),
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // Simulate gallery pick
                Future.delayed(const Duration(seconds: 1), () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$documentType selected from gallery')),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addHawker() {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New hawker added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signOut();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _showNotifications(BuildContext context) {
    final notifications = _demoService.getNotificationsForUser('admin', 'admin1');
    
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
} 