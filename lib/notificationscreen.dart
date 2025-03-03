import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  final List<Map<String, dynamic>> lowStockProducts;
  final Function(int) onNotificationDeleted; // Callback function

  const NotificationScreen({
    Key? key,
    required this.lowStockProducts,
    required this.onNotificationDeleted,
  }) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(widget.lowStockProducts);
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });

    // Call the function in MyStore to update badge count
    widget.onNotificationDeleted(1); // Decrease badge count by 1
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                    title: RichText(
                      text: TextSpan(
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
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
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (value) {
                        if (value == "delete") {
                          _deleteNotification(index);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          height: 20,
                          value: "delete",
                          child: Text("Delete"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
