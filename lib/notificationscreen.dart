import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go90stores/orderdetailscreen.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  final String storeId;
  final List<Map<String, dynamic>> lowStockProducts;
  final List<Map<String, dynamic>> orderNotifications;
  final Function(int, bool) onNotificationDeleted;

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
    widget.onNotificationDeleted(0, true); // Reset order count
    widget.onNotificationDeleted(0, false); // Reset stock count
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        actions: [
          if (_localStockAlerts.isNotEmpty || _localOrderAlerts.isNotEmpty)
            TextButton(
              onPressed: _clearAllLocalNotifications,
              child: const Text(
                "Clear All",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('store_notifications')
            .doc(widget.storeId)
            .collection('notifications')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final firestoreNotifications = snapshot.data?.docs ?? [];

          if (_localStockAlerts.isEmpty &&
              _localOrderAlerts.isEmpty &&
              firestoreNotifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No new notifications",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          final combinedNotifications = [
            ..._localStockAlerts.map((product) => {
                  'type': 'localStockAlert',
                  'name': product['name'],
                  'quantity': product['quantity'],
                  'image': product['image'],
                  'time': 'Just now',
                }),
            ..._localOrderAlerts.map((order) => {
                  'type': 'localOrderAlert',
                  'order_id': order['order_id'],
                  'total_amount': order['total_amount'],
                  'customer_address': order['customer_address'],
                  'timestamp': order['timestamp'],
                  'time': DateFormat('MMM d, h:mm a')
                      .format(order['timestamp']?.toDate() ?? DateTime.now()),
                }),
            ...firestoreNotifications.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              data['time'] = DateFormat('MMM d, h:mm a').format(
                  (data['timeStamp'] as Timestamp?)?.toDate() ??
                      DateTime.now());
              return data;
            }),
          ]..sort((a, b) => (b['timestamp'] ?? DateTime.now())
              .compareTo(a['timestamp'] ?? DateTime.now()));

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: combinedNotifications.length,
            itemBuilder: (context, index) {
              final notification = combinedNotifications[index];
              final type = notification['type'];

              if (type == 'localStockAlert') {
                return _buildLocalStockTile(notification);
              } else if (type == 'localOrderAlert' || type == 'orderAlert') {
                return _buildOrderTile(notification);
              } else if (type == 'stockAlert') {
                return _buildRemoteStockTile(notification);
              }

              return const SizedBox();
            },
          );
        },
      ),
    );
  }

  Widget _buildLocalStockTile(Map<String, dynamic> product) {
    return Container(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: product['image'] != null
              ? Image.network(
                  product['image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.red,
                      size: 50),
                )
              : const Icon(Icons.inventory_2, color: Colors.orange, size: 50),
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
              product['time'],
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> data) {
    final orderId = data['order_id'] ?? data['orderId'] ?? '';
    final customerAddress = data['customer_address'] ?? 'Unknown address';
    final totalAmount = data['total_amount'] ?? data['total'] ?? 0.0;
    final time = data['time'] ?? '';

    return Container(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: const Icon(Icons.shopping_cart, color: Colors.green, size: 40),
        title: Text(
          'New Order #$orderId',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '₹${totalAmount.toStringAsFixed(2)} - $customerAddress',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
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
    );
  }

  Widget _buildRemoteStockTile(Map<String, dynamic> data) {
    final productName = data['productName'] ?? '';
    final message = data['message'] ?? '';
    final time = data['time'] ?? '';

    return Container(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: const Icon(Icons.warning, color: Colors.orange, size: 40),
        title: Text(
          'Stock Alert: $productName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
