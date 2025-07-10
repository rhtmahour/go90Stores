import 'package:flutter/material.dart';

class Customernotification extends StatelessWidget {
  const Customernotification({super.key});

  // Dummy notification data
  final List<Map<String, dynamic>> notifications = const [
    {
      'title': 'New Feature Available',
      'message': 'Check out our latest update with exciting new features!',
      'time': '2 hours ago',
      'isRead': false,
    },
    {
      'title': 'Maintenance Scheduled',
      'message': 'We\'ll be performing maintenance on July 15 from 2-4 AM.',
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'title': 'Special Offer',
      'message': 'Get 20% off on your next purchase with code SUMMER20.',
      'time': '3 days ago',
      'isRead': true,
    },
    {
      'title': 'Welcome to Our App!',
      'message': 'Thank you for joining us. Start exploring now!',
      'time': '1 week ago',
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notification',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('No new notifications'),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notification['isRead']
                          ? Colors.grey[300]
                          : Theme.of(context).primaryColor,
                      child: Icon(
                        Icons.notifications,
                        color:
                            notification['isRead'] ? Colors.grey : Colors.white,
                      ),
                    ),
                    title: Text(
                      notification['title'],
                      style: TextStyle(
                        fontWeight: notification['isRead']
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['message']),
                        const SizedBox(height: 4),
                        Text(
                          notification['time'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: notification['isRead']
                        ? null
                        : const Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 12,
                          ),
                    onTap: () {
                      // Handle notification tap
                    },
                  ),
                );
              },
            ),
    );
  }
}
