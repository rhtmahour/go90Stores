import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go90stores/adminlogin.dart';
import 'package:go90stores/adminnotificationscreen.dart';
import 'package:go90stores/lowestpurchasepricereport.dart';
import 'package:go90stores/storedetailpage.dart';
import 'package:shimmer/shimmer.dart';

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
                      width: isWideScreen ? screenWidth * 0.65 : screenWidth,
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
                                    horizontal: 12.0, vertical: 8.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    //color: Colors.grey,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.purpleAccent,
                                        Colors.deepPurple,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 10,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    onTap: () => showStoreDetailsDialog(
                                        context, store.id),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    leading: CircleAvatar(
                                      radius: 35,
                                      backgroundColor: Colors.purple,
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
                                            : _buildShimmerAvatar(),
                                      ),
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            storename,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        _buildStatusIcon(data['status']),
                                      ],
                                    ),
                                    subtitle: Text(
                                      'GST: $gstNumber',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
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
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LowestPurchasePriceReport(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.purpleAccent,
                                      Colors.deepPurple
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18, horizontal: 26),
                                  child: const Text(
                                    'Lowest Purchase Price Report',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
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
    final double padding = isMobile ? 12 : 16;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 120, maxWidth: 160),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                Colors.black.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.white24,
              onTap: () {},
              child: Padding(
                padding: EdgeInsets.all(padding), // Internal padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: textSize,
                        color: Colors.white,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                    //color: Colors.purple,
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

// Helper function for shimmer avatar
  Widget _buildShimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 70,
        height: 70,
        color: Colors.white,
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
