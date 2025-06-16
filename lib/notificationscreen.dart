import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go90stores/orderdetailscreen.dart';

class NotificationScreen extends StatefulWidget {
  final String storeId;
  final List<Map<String, dynamic>> lowStockProducts;
  final Function(int) onNotificationDeleted;

  const NotificationScreen({
    Key? key,
    required this.storeId,
    required this.lowStockProducts,
    required this.onNotificationDeleted,
  }) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<Map<String, dynamic>> _localStockAlerts;

  @override
  void initState() {
    super.initState();
    _localStockAlerts = List.from(widget.lowStockProducts);
  }

  void _clearAllLocalNotifications() {
    setState(() {
      _localStockAlerts.clear();
    });
    widget.onNotificationDeleted(0); // Reset count
  }

  String _detectNotificationType(Map<String, dynamic> data) {
    if (data.containsKey('orderId') && data.containsKey('customerName')) {
      return 'orderAlert';
    } else if (data.containsKey('productName') && data.containsKey('message')) {
      return 'stockAlert';
    } else {
      return 'unknown';
    }
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
          if (_localStockAlerts.isNotEmpty)
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

          if (_localStockAlerts.isEmpty && firestoreNotifications.isEmpty) {
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
                }),
            ...firestoreNotifications.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }),
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: combinedNotifications.length,
            itemBuilder: (context, index) {
              final notification = combinedNotifications[index];
              final type =
                  notification['type'] ?? _detectNotificationType(notification);

              if (type == 'localStockAlert') {
                return _buildLocalStockTile(notification);
              } else if (type == 'orderAlert') {
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
              : const Icon(Icons.inventory_2, color: Colors.blue, size: 50),
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
        subtitle: Text(
          "⚠️ Only ${product['quantity']} left in inventory!",
          style: const TextStyle(
              color: Colors.redAccent, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> data) {
    final timestamp =
        (data['timeStamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final orderId = data['orderId'] ?? '';
    final customerName = data['customerName'] ?? '';
    final total = data['total'] ?? 0;
    final message = data['message'] ?? 'New order placed!';

    return ListTile(
      leading: const Icon(Icons.shopping_cart, color: Colors.green),
      title: Text('Order from $customerName'),
      subtitle: Text('$message\nTotal: ₹$total'),
      trailing: Text(
        '${timestamp.hour}:${timestamp.minute}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Orderdetailscreen(orderId: orderId),
          ),
        );
      },
    );
  }

  Widget _buildRemoteStockTile(Map<String, dynamic> data) {
    final timestamp =
        (data['timeStamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final productName = data['productName'] ?? '';
    final message = data['message'] ?? '';

    return ListTile(
      leading: const Icon(Icons.warning, color: Colors.orange),
      title: const Text('Stock Alert'),
      subtitle: Text('$productName\n$message'),
      trailing: Text(
        '${timestamp.hour}:${timestamp.minute}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
