import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go90stores/adminlogin.dart';
import 'package:go90stores/bestprice.dart';
import 'package:go90stores/notificationscreen.dart';
import 'package:go90stores/productcard.dart';
import 'package:go90stores/storedrawerheader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyStore extends StatefulWidget {
  final String storeId;

  const MyStore({Key? key, required this.storeId}) : super(key: key);

  @override
  State<MyStore> createState() => _MyStoreState();
}

class _MyStoreState extends State<MyStore> {
  Future<void> _signOut(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Do you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AdminLogin()),
        (route) => false,
      );
    }
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  int lowStockCount = 0;
  List<Map<String, String>> _products = [];

  void _listenForStockUpdates() {
    DatabaseReference storeRef =
        FirebaseDatabase.instance.ref('products/${widget.storeId}');

    storeRef.onValue.listen((event) {
      if (!mounted) return;

      final data = event.snapshot.value;
      if (data == null || data is! Map<dynamic, dynamic>) {
        setState(() {
          lowStockCount = 0;
          _products = []; // ✅ Fix: Reset products list when data is null
        });
        return;
      }

      List<Map<String, String>> lowStockProducts =
          []; // ✅ Fix: Explicitly use <String, String>
      int count = 0;

      (data as Map<dynamic, dynamic>).forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          int stock = int.tryParse(value['quantity']?.toString() ?? '0') ??
              0; // ✅ Always use lowercase "quantity"

          if (stock < 10) {
            lowStockProducts.add({
              'name': value['name']?.toString() ?? 'Unknown Product',
              'quantity': stock.toString(), // ✅ Convert quantity to String
            });
            count++;
          }
        }
      });

      if (mounted) {
        setState(() {
          lowStockCount = count;
          _products =
              lowStockProducts; // ✅ Fix: Now matches List<Map<String, String>>
        });

        if (lowStockProducts.isNotEmpty) {
          _showLowStockNotification(lowStockProducts);
        }
      }
    });
  }

  Future<void> _showLowStockNotification(
      List<Map<String, dynamic>> lowStockProducts) async {
    for (var product in lowStockProducts) {
      final String productName = product['name'] ?? 'Unknown Product';
      final String stockQuantity = product['quantity'] ?? 'N/A';

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'low_stock_channel',
        'Low Stock Alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/
            1000, // ✅ Unique ID for each notification
        'Low Stock Alert',
        '$productName is running low! Only $stockQuantity left.',
        notificationDetails,
      );
    }
  }

  Future<void> _uploadCsvFile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final input = File(path).openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(CsvToListConverter(eol: '\n'))
            .toList();

        if (fields.isNotEmpty) {
          final storeRef =
              FirebaseDatabase.instance.ref('products/${widget.storeId}');
          final existingProducts = await storeRef.get();

          if (existingProducts.exists) {
            final bool? overwrite = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Overwrite Products"),
                  content: const Text(
                      "Products already exist. Do you want to overwrite them?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Yes"),
                    ),
                  ],
                );
              },
            );

            if (overwrite == true) {
              await _saveProducts(fields, storeRef);
            }
          } else {
            await _saveProducts(fields, storeRef);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("CSV file is empty or invalid!")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No file selected.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProducts(
      List<List<dynamic>> fields, DatabaseReference storeRef) async {
    await storeRef.remove(); // Remove old data before saving new
    final products = fields.skip(1).map((row) async {
      final product = {
        'id': row.length > 0 ? row[0]?.toString() ?? '' : '',
        'name': row.length > 1 ? row[1]?.toString() ?? '' : '',
        'salePrice': row.length > 2 ? row[2]?.toString() ?? '' : '',
        'purchasePrice': row.length > 3 ? row[3]?.toString() ?? '' : '',
        'quantity': row.length > 4
            ? row[4]?.toString() ?? '0'
            : '0', // ✅ Fix: Store as lowercase
        'description': row.length > 6 ? row[6]?.toString() ?? '' : '',
        'productImage': row.length > 7 ? row[7]?.toString().trim() ?? '' : '',
      };

      final newProductRef = storeRef.push();
      await newProductRef.set(product);
      product['key'] = newProductRef.key!;
      return product;
    }).toList();

    final resolvedProducts = await Future.wait(products);
    setState(() {
      _products = resolvedProducts;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("File uploaded successfully!")),
    );
  }

  @override
  void initState() {
    super.initState();
    _listenForStockUpdates(); // ✅ Fix: Start listening for stock updates on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Store',
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NotificationScreen(lowStockProducts: _products),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications,
                    color: Colors.white, size: 30),
              ),
              if (lowStockCount > 0)
                Positioned(
                  right: 4,
                  top: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        lowStockCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            StoreDrawerHeader(storeId: widget.storeId),
            const ListTile(
              iconColor: Colors.purple,
              textColor: Colors.purple,
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            _buildButtonsRow(),
            const SizedBox(height: 16),
            Expanded(child: _buildProductList()),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildButton(
                text: "Upload CSV",
                icon: Icons.upload_file,
                onPressed: _isLoading ? null : _uploadCsvFile,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildButton(
                text: "Best Price",
                icon: Icons.monetization_on,
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BestPriceCalulate()),
                        );
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<DatabaseEvent>(
      stream:
          FirebaseDatabase.instance.ref('products/${widget.storeId}').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final List<Map<String, String>> products = [];
          Map<String, dynamic> data =
              (snapshot.data!.snapshot.value as Map<dynamic, dynamic>)
                  .cast<String, dynamic>();
          data.forEach((key, value) {
            products.add({
              'key': key,
              'name': value['name']?.toString() ?? '',
              'salePrice': value['salePrice']?.toString() ?? '',
              'purchasePrice': value['purchasePrice']?.toString() ?? '',
              'quantity': value['quantity']?.toString() ??
                  value['quantity']?.toString() ??
                  'N/A',
              // ✅ Fix: Ensure 'Quantity' matches the saved field
              'description': value['description']?.toString() ?? '',
              'productImage': value['productImage']?.toString() ?? '',
            });
          });

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
                onUpdate: () {}, // Keep as is
                onStockUpdated:
                    _listenForStockUpdates, // ✅ Fix: Use the correct function
                storeId: widget.storeId,
              );
            },
          );
        } else {
          return const Center(
            child: Text(
              'No products available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }
      },
    );
  }

  Widget _buildButton(
      {required String text,
      required IconData icon,
      required VoidCallback? onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 1,
      ),
    );
  }
}
