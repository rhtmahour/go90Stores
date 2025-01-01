import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go90stores/adminlogin.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Do you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                        builder: (context) => const AdminLogin()),
                    (Route<dynamic> route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error logging out: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => _showLogoutConfirmation(context),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Dashboard Summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Adapt the summary cards to the available width
                final isWideScreen = constraints.maxWidth > 600;
                return Flex(
                  direction: isWideScreen ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: isWideScreen
                      ? MainAxisAlignment.spaceEvenly
                      : MainAxisAlignment.center,
                  children: <Widget>[
                    _buildSummaryCard("Total Stores", Icons.store, Colors.blue),
                    _buildSummaryCard("Pending", Icons.pending, Colors.orange),
                    _buildSummaryCard("Rejected", Icons.close, Colors.red),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 20, thickness: 2),
          // Split the UI into two sections (Stores and Activities)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 800;

                return Row(
                  children: [
                    // Left side - Stores List
                    Flexible(
                      flex: 2,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('stores')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error loading store data.'));
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                                child: Text('No stores available.'));
                          }

                          final storeDocs = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: storeDocs.length,
                            itemBuilder: (context, index) {
                              final store = storeDocs[index];
                              final data = store.data() as Map<String, dynamic>;

                              final imageUrl = data['storeImage'];
                              final email = data['email'] ?? 'N/A';
                              final gstNumber = data['gstNumber'] ?? 'N/A';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 5.0),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      // Navigate to store details page
                                    },
                                    contentPadding: const EdgeInsets.all(15),
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: imageUrl != null
                                          ? NetworkImage(imageUrl)
                                          : const AssetImage(
                                                  'assets/placeholder.png')
                                              as ImageProvider,
                                      child: imageUrl == null
                                          ? const Icon(Icons.store,
                                              size: 30, color: Colors.white)
                                          : null,
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (data['approved'] == true)
                                          const Icon(
                                            Icons.verified,
                                            color: Colors.blue,
                                            size: 18,
                                          )
                                        else if (data['pending'] == true)
                                          const Icon(
                                            Icons.pending,
                                            color: Colors.orange,
                                            size: 18,
                                          )
                                        else if (data['rejected'] == true)
                                          const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 18,
                                          )
                                        else
                                          const SizedBox.shrink(),
                                      ],
                                    ),
                                    subtitle: Text('GST Number: $gstNumber'),
                                    trailing: PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.grey,
                                      ),
                                      onSelected: (String value) async {
                                        // Handle Approval, Pending, Rejected logic
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'Approved',
                                          child: Text('Approved'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'Pending',
                                          child: Text('Pending'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'Rejected',
                                          child: Text('Rejected'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    // Right side - Activities
                    if (isWideScreen)
                      Flexible(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildActivityCard(
                                title: "Total Sales",
                                value: "\$12,345",
                                icon: Icons.attach_money,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 16),
                              _buildActivityCard(
                                title: "Total Products",
                                value: "235",
                                icon: Icons.inventory,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              _buildActivityCard(
                                title: "Total Revenue",
                                value: "\$50,000",
                                icon: Icons.bar_chart,
                                color: Colors.purple,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildActivityCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildSummaryCard(String title, IconData icon, Color color) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
