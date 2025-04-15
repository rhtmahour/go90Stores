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
    final isWideScreen = screenWidth > 800;
    final isMediumScreen = screenWidth > 600;
    final fontSize = screenWidth < 600 ? 16.0 : 22.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      _buildSummaryCard(
                          "Total Stores", Icons.store, Colors.green),
                      _buildSummaryCard(
                          "Pending", Icons.pending, Colors.orange),
                      _buildSummaryCard("Rejected", Icons.close, Colors.red),
                      _buildSummaryCard(
                          "Approved", Icons.verified, Colors.blue),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 20, thickness: 2),
            LayoutBuilder(
              builder: (context, constraints) {
                return Flex(
                  direction: isWideScreen ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store List Section
                    SizedBox(
                      width: isWideScreen
                          ? screenWidth * 0.65
                          : screenWidth, // Full width for mobile
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
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
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
                                      showStoreDetailsDialog(context, store.id);
                                    },
                                    contentPadding: const EdgeInsets.all(15),
                                    leading: CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.grey[300],
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(35),
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
                                        Flexible(
                                          child: Text(
                                            storename,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatusIcon(data['status']),
                                      ],
                                    ),
                                    subtitle: Text(
                                      'GST Number: $gstNumber',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    trailing: _buildPopupMenu(store.id),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const Divider(height: 20, thickness: 2),
                    // Right Panel
                    SizedBox(
                      width: isWideScreen ? screenWidth * 0.35 : screenWidth,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LowestPurchasePriceReport(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 24),
                                backgroundColor: Colors.purple,
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
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, IconData icon, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double iconSize = isMobile ? 30 : 40;
    final double textSize = isMobile ? 14 : 18;
    final double padding = isMobile ? 10 : 12;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 200),
      child: Card(
        color: Colors.purple,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: color, size: iconSize),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: textSize,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildStatusIcon(String? status) {
    switch (status) {
      case 'Approved':
        return const Icon(Icons.verified, color: Colors.blue, size: 18);
      case 'Pending':
        return const Icon(Icons.pending, color: Colors.orange, size: 18);
      case 'Rejected':
        return const Icon(Icons.close, color: Colors.red, size: 18);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPopupMenu(String storeId) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (String value) async {
        try {
          await FirebaseFirestore.instance
              .collection('stores')
              .doc(storeId)
              .update({'status': value});
        } catch (e) {
          print('Error updating status: $e');
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(value: 'Approved', child: Text('Approved')),
        const PopupMenuItem<String>(value: 'Pending', child: Text('Pending')),
        const PopupMenuItem<String>(value: 'Rejected', child: Text('Rejected')),
      ],
    );
  }
}
