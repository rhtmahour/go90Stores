import 'package:flutter/material.dart';

class Customersettings extends StatelessWidget {
  const Customersettings({super.key});

  // Dummy customer data
  final Map<String, dynamic> customerData = const {
    'name': 'ROHIT',
    'email': 'rohit@gmail.com',
    'phone': '+1 (555) 123-4567',
    'joinedDate': 'Member since June 2022',
    'profileImage': 'assets/images/profile.png', // Replace with your asset path
  };

  // Dummy settings options
  final List<Map<String, dynamic>> settingsOptions = const [
    {
      'icon': Icons.person,
      'title': 'Account Information',
      'subtitle': 'Update your personal details',
    },
    {
      'icon': Icons.lock,
      'title': 'Privacy & Security',
      'subtitle': 'Change password and security settings',
    },
    {
      'icon': Icons.notifications,
      'title': 'Notification Settings',
      'subtitle': 'Manage your notification preferences',
    },
    {
      'icon': Icons.payment,
      'title': 'Payment Methods',
      'subtitle': 'Add or update payment options',
    },
    {
      'icon': Icons.help_center,
      'title': 'Help & Support',
      'subtitle': 'FAQs and contact support',
    },
    {
      'icon': Icons.logout,
      'title': 'Logout',
      'subtitle': 'Sign out of your account',
      'isAction': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Settings',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: AssetImage(customerData['profileImage']),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerData['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customerData['email'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customerData['joinedDate'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings Options
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: settingsOptions.length,
              itemBuilder: (context, index) {
                final option = settingsOptions[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      option['icon'],
                      color: option['isAction'] == true
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      option['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: option['isAction'] == true
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                    subtitle: Text(option['subtitle']),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Handle settings option tap
                    },
                  ),
                );
              },
            ),

            // App Version Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'App Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
