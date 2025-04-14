import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go90stores/adminlogin.dart';
import 'package:go90stores/adminnotificationscreen.dart';
import 'package:go90stores/lowestpurchasepricereport.dart';
import 'package:go90stores/storedetailpage.dart';

class AdminDashboard extends StatefulWidget {
  final String storeId;

  const AdminDashboard({super.key, required this.storeId});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int lowStockCount = 0;
  List<Map<String, dynamic>> lowStockProducts = [];

  @override
  void initState() {
    super.initState();
    _listenForStockUpdates(); // ✅ Fix: Listen to ALL store stock updates
  }

  /// 🔥 Listen for Low Stock Updates from ALL Stores in Firebase RTDB
  void _listenForStockUpdates() {
    DatabaseReference storesRef = FirebaseDatabase.instance.ref('products');

    storesRef.onValue.listen((event) {
      if (!mounted) return;

      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        setState(() {
          lowStockProducts = [];
          lowStockCount = 0;
        });
        return;
      }

      List<Map<String, dynamic>> allLowStockProducts = [];
      int newLowStockCount = 0;

      data.forEach((storeId, storeProducts) {
        if (storeProducts is Map<dynamic, dynamic>) {
          storeProducts.forEach((productId, productData) {
            int stock =
                int.tryParse(productData['quantity']?.toString() ?? '0') ?? 0;
            int alertLevel = int.tryParse(
                    productData['stockAlertLevel']?.toString() ?? '0') ??
                0;

            if (stock < alertLevel) {
              allLowStockProducts.add({
                'storeName': storeId, // ✅ Store ID acts as store name
                'name': productData['name'] ?? 'Unknown Product',
                'quantity': stock.toString(),
              });
              newLowStockCount++;
            }
          });
        }
      });

      if (mounted) {
        setState(() {
          lowStockProducts = allLowStockProducts;
          lowStockCount = newLowStockCount;
        });
      }
    });
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Do you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("No"),
            ),
            ElevatedButton(
              //style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLogin()),
                  (route) => false,
                );
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Adminnotificationscreen(
                        lowStockProducts: lowStockProducts,
                        onNotificationDeleted: (deletedCount) {
                          setState(() {
                            lowStockCount = 0;
                          });
                        },
                      ),
                    ),
                  );
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications,
                        color: Colors.white, size: 28),
                    if (lowStockCount > 0)
                      Positioned(
                        right: -7,
                        top: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            lowStockCount.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
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
                    _buildSummaryCard(
                        "Total Stores", Icons.store, Colors.green),
                    _buildSummaryCard("Pending", Icons.pending, Colors.orange),
                    _buildSummaryCard("Rejected", Icons.close, Colors.red),
                    _buildSummaryCard("Approved", Icons.verified, Colors.blue),
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
                          print(
                              'Store data: ${storeDocs.map((doc) => doc.data()).toList()}'); // Debugging line

                          return ListView.builder(
                            itemCount: storeDocs.length,
                            itemBuilder: (context, index) {
                              final store = storeDocs[index];
                              final data = store.data() as Map<String, dynamic>;

                              final imageUrl = data['storeImage'];
                              final storename = data['storename'] ?? 'N/A';
                              final gstNumber = data['gstNumber'] ?? 'N/A';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 5.0),
                                child: Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    tileColor: Colors.purple,
                                    onTap: () {
                                      // Navigate to store details page
                                      showStoreDetailsDialog(context, store.id);
                                    },
                                    contentPadding: const EdgeInsets.all(15),
                                    leading: CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.grey[
                                          300], // Light grey background for better UI
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            35), // Ensures perfect circular clipping
                                        child: imageUrl.isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    _buildPlaceholder(),
                                              )
                                            : _buildPlaceholder(),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(
                                          storename,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        if (data['status'] == 'Approved')
                                          const Icon(
                                            Icons.verified,
                                            color: Colors.blue,
                                            size: 18,
                                          )
                                        else if (data['status'] == 'Pending')
                                          const Icon(
                                            Icons.pending,
                                            color: Colors.orange,
                                            size: 18,
                                          )
                                        else if (data['status'] == 'Rejected')
                                          const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                            size: 18,
                                          )
                                        else
                                          const SizedBox.shrink(),
                                      ],
                                    ),
                                    subtitle: Text(
                                      'GST Number: $gstNumber',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        color: Colors.white,
                                      ),
                                      onSelected: (String value) async {
                                        final storeId = store.id;
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('stores')
                                              .doc(storeId)
                                              .update({'status': value});
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Status updated to $value')),
                                          );
                                        } catch (e) {
                                          print('Error updating status: $e');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Error updating status: $e')),
                                          );
                                        }
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
                          child: SingleChildScrollView(
                            // Added to make the content scrollable
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // Navigate to Lowest Purchase Price Report using MaterialPageRoute
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LowestPurchasePriceReport(), // Target Page
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                      horizontal: 24,
                                    ),
                                    backgroundColor: Colors
                                        .purple, // Transparent to show gradient
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Lowest Purchase Price Report',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildActivityCard(
                                  title: "Total Sales",
                                  value: "\$.12,345",
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
                                  color: Colors.red,
                                ),
                              ],
                            ),
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
    color: Colors.white,
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
                  color: Colors.purple,
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
    color: Colors.purple,
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

// Helper function for placeholder
Widget _buildPlaceholder() {
  return Container(
    width: 70,
    height: 70,
    decoration: BoxDecoration(
      color: Colors.white, // Slightly darker grey for contrast
      borderRadius: BorderRadius.circular(35),
    ),
    child: const Icon(Icons.store, size: 40, color: Colors.green),
  );
}
