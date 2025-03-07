import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Adminnotificationscreen extends StatefulWidget {
  final List<Map<String, dynamic>> lowStockProducts;
  final Function(int) onNotificationDeleted; // Callback function

  const Adminnotificationscreen({
    Key? key,
    required this.lowStockProducts,
    required this.onNotificationDeleted,
  }) : super(key: key);

  @override
  State<Adminnotificationscreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<Adminnotificationscreen> {
  late List<Map<String, dynamic>> _notifications;
  final Map<String, String> _storeNames = {}; // Cache store names

  @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.lowStockProducts);
    _fetchStoreNames();
  }

  /// ✅ Fetch Store Names from Firestore
  Future<void> _fetchStoreNames() async {
    for (var product in _notifications) {
      String storeId =
          product['storeName']; // `storeName` actually contains `storeId`

      if (!_storeNames.containsKey(storeId)) {
        try {
          DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance
              .collection('stores')
              .doc(storeId)
              .get();

          if (storeSnapshot.exists) {
            String storeName =
                storeSnapshot.get('storename') ?? 'Unknown Store';
            setState(() {
              _storeNames[storeId] = storeName; // Store name mapping
            });
          }
        } catch (e) {
          print("Error fetching store name: $e");
        }
      }
    }
  }

  /// ✅ Function to Clear All Notifications
  void _clearAllNotifications() {
    setState(() {
      _notifications.clear();
    });

    // Notify MyStore to reset the badge count
    widget.onNotificationDeleted(_notifications.length);
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
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: _clearAllNotifications,
              child: const Text(
                "Clear All",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.notifications_off, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No new notifications",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final product = _notifications[index];
                final storeId = product['storeName']; // storeId
                final storeName = _storeNames[storeId] ?? 'Fetching...';

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
                              color: Colors.blue, size: 50),
                    ),
                    title: Text(
                      storeName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      product['name'] ?? 'Unknown Product',
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                    trailing: Text(
                      "Only ${product['quantity']} left in inventory!",
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
