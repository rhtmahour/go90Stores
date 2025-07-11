import 'package:flutter/material.dart';
import 'package:go90stores/orderdetailscreen.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  final String storeId;
  final List<Map<String, dynamic>> lowStockProducts;
  final List<Map<String, dynamic>> orderNotifications;
  final Function(String, bool) onNotificationDeleted;

  const NotificationScreen({
    Key? key,
    required this.storeId,
    required this.lowStockProducts,
    required this.orderNotifications,
    required this.onNotificationDeleted,
  }) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<Map<String, dynamic>> _localStockAlerts;
  late List<Map<String, dynamic>> _localOrderAlerts;

  @override
  void initState() {
    super.initState();
    _localStockAlerts = List.from(widget.lowStockProducts);
    _localOrderAlerts = List.from(widget.orderNotifications);
  }

  void _clearAllLocalNotifications() {
    setState(() {
      _localStockAlerts.clear();
      _localOrderAlerts.clear();
    });
    widget.onNotificationDeleted('all', true); // Reset order count
    widget.onNotificationDeleted('all', false); // Reset stock count
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Notifications",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Orders (${_localOrderAlerts.length})',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  'Stock (${_localStockAlerts.length})',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actions: [
            if (_localStockAlerts.isNotEmpty || _localOrderAlerts.isNotEmpty)
              TextButton(
                onPressed: _clearAllLocalNotifications,
                child: const Text(
                  "Clear All",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildOrderNotifications(),
            _buildStockNotifications(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderNotifications() {
    if (_localOrderAlerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No order notifications",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _localOrderAlerts.length,
      itemBuilder: (context, index) {
        final notification = _localOrderAlerts[index];
        final orderId =
            notification['order_id'] ?? notification['orderId'] ?? '';
        final customerAddress =
            notification['customer_address'] ?? 'Unknown address';
        final totalAmount =
            notification['total_amount'] ?? notification['total'] ?? 0.0;
        final distance = notification['distance'] as double?;
        final time = DateFormat('MMM dd, yyyy - hh:mm a')
            .format(notification['timestamp']?.toDate() ?? DateTime.now());

        return Dismissible(
          key: Key(orderId),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            setState(() {
              _localOrderAlerts.removeAt(index);
            });
            widget.onNotificationDeleted(orderId, true);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: const Icon(Icons.shopping_cart,
                  color: Colors.green, size: 40),
              title: Text(
                'New Order #$orderId',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${totalAmount.toStringAsFixed(2)} - $customerAddress'),
                  if (distance != null)
                    Text('Distance: ${distance.toStringAsFixed(0)}m'),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.directions),
                onPressed: () {
                  // Open map with directions
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Orderdetailscreen(orderId: orderId),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockNotifications() {
    if (_localStockAlerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "No stock notifications",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _localStockAlerts.length,
      itemBuilder: (context, index) {
        final product = _localStockAlerts[index];
        return Dismissible(
          key: Key(product['key'] ?? index.toString()),
          background: Container(color: Colors.red),
          onDismissed: (direction) {
            setState(() {
              _localStockAlerts.removeAt(index);
            });
            widget.onNotificationDeleted(product['key'], false);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product['image'] != null
                    ? Image.network(
                        product['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported,
                                color: Colors.red, size: 50),
                      )
                    : const Icon(Icons.inventory_2,
                        color: Colors.orange, size: 50),
              ),
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: "${product['name']} ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: "is running low on stock."),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⚠️ Only ${product['quantity']} left in inventory!",
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Just now',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
