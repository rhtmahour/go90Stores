import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go90stores/adminlogin.dart';
import 'package:go90stores/bestprice.dart';
import 'package:go90stores/notificationscreen.dart';
import 'package:go90stores/productcard.dart';
import 'package:go90stores/storeaddress.dart';
import 'package:go90stores/storedrawerheader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class MyStore extends StatefulWidget {
  final String storeId;

  const MyStore({Key? key, required this.storeId}) : super(key: key);

  @override
  State<MyStore> createState() => MyStoreState();
}

class MyStoreState extends State<MyStore> {
  final TextEditingController _searchController = TextEditingController();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  int lowStockCount = 0;
  List<Map<String, String>> _products = [];

  List<Map<String, dynamic>> _orderNotifications = [];
  int _orderNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _listenForStockUpdates();
    _listenForOrderNotifications();
    _setupFirebaseMessaging();
  }

  Future<void> _signOut(BuildContext context) async {
    final bool? confirmLogout = await showDialog<bool>(
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

  // Add this method to setup Firebase Messaging
  Future<void> _setupFirebaseMessaging() async {
    await FirebaseMessaging.instance.subscribeToTopic(widget.storeId);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'new_order') {
        _handleNewOrderNotification(message.data);
      }
    });
  }

  void _handleNewOrderNotification(Map<String, dynamic> data) {
    final orderId = data['order_id'];
    final customerAddress = data['customer_address'] ?? 'Unknown address';
    final totalAmount = double.tryParse(data['total_amount'].toString()) ?? 0.0;

    setState(() {
      _orderNotificationCount++;
      _orderNotifications.insert(0, {
        'id': 'push_${DateTime.now().millisecondsSinceEpoch}',
        'type': 'new_order',
        'order_id': orderId,
        'customer_address': customerAddress,
        'total_amount': totalAmount,
        'timestamp': DateTime.now(),
      });
    });

    _showOrderNotification(
      orderId: orderId,
      customerAddress: customerAddress,
      totalAmount: totalAmount,
    );
  }

  Future<void> _showOrderNotification({
    required String orderId,
    required String customerAddress,
    required double totalAmount,
  }) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'order_channel',
      'Order Notifications',
      channelDescription: 'Notifications for new orders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      orderId.hashCode,
      'New Order #$orderId',
      'Amount: ₹${totalAmount.toStringAsFixed(2)} - $customerAddress',
      platformChannelSpecifics,
      payload: 'order_$orderId',
    );
  }

  void _listenForStockUpdates() {
    DatabaseReference storeRef =
        FirebaseDatabase.instance.ref('products/${widget.storeId}');

    storeRef.onValue.listen((event) {
      if (!mounted) return;

      final data = event.snapshot.value;
      if (data == null || data is! Map<dynamic, dynamic>) {
        setState(() {
          lowStockCount = 0;
          _products = [];
        });
        return;
      }

      List<Map<String, String>> lowStockProducts = [];
      int newLowStockCount = 0;

      (data as Map<dynamic, dynamic>).forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          int stock = int.tryParse(value['quantity']?.toString() ?? '0') ?? 0;
          int alertLevel =
              int.tryParse(value['stockAlertLevel']?.toString() ?? '0') ?? 0;

          if (stock < alertLevel) {
            lowStockProducts.add({
              'key': key,
              'name': value['name']?.toString() ?? 'Unknown Product',
              'quantity': stock.toString(),
            });
            newLowStockCount++;
          }
        }
      });

      if (mounted) {
        setState(() {
          lowStockCount = newLowStockCount;
          _products = lowStockProducts;
        });

        if (lowStockProducts.isNotEmpty) {
          _showLowStockNotification(lowStockProducts);
        }
      }
    });
  }

  void updateBadgeCount(String productKey, int newStock) {
    setState(() {
      var product = _products.firstWhere(
        (p) => p['key'] == productKey,
        orElse: () => {'stockAlertLevel': '0'},
      );

      int alertLevel = int.tryParse(product['stockAlertLevel'] ?? '0') ?? 0;

      if (newStock >= alertLevel) {
        _products.removeWhere((product) => product['key'] == productKey);
      } else if (newStock < alertLevel &&
          !_products.any((p) => p['key'] == productKey)) {
        _products.add({'key': productKey, 'quantity': newStock.toString()});
      }

      lowStockCount = _products.length;
    });
  }

  Future<void> _showLowStockNotification(
      List<Map<String, dynamic>> lowStockProducts) async {
    for (var product in lowStockProducts) {
      final String productName = product['name'] ?? 'Unknown Product';
      final String stockQuantity = product['quantity'] ?? 'N/A';
      final String imageUrl = product['image'] ?? '';

      String? imagePath;
      if (imageUrl.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            final directory = await getApplicationDocumentsDirectory();
            final filePath = '${directory.path}/product_image.jpg';
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);
            imagePath = filePath;
          }
        } catch (e) {
          print("Error downloading image: $e");
        }
      }

      final BigPictureStyleInformation bigPictureStyle =
          BigPictureStyleInformation(
        imagePath != null
            ? FilePathAndroidBitmap(imagePath)
            : const DrawableResourceAndroidBitmap('app_icon'),
        largeIcon: imagePath != null
            ? FilePathAndroidBitmap(imagePath)
            : const DrawableResourceAndroidBitmap('app_icon'),
        contentTitle: "Low Stock Alert: $productName",
        summaryText: "Only $stockQuantity left!",
      );

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'low_stock_channel',
        'Low Stock Alerts',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: bigPictureStyle,
      );

      final NotificationDetails notificationDetails =
          NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
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
        'expiryDate': row.length > 8 ? row[8]?.toString().trim() ?? '' : '',
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

  // Update _listenForOrderNotifications to include distance calculation
  void _listenForOrderNotifications() {
    final storeId = widget.storeId;

    FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('notifications')
        .where('type', isEqualTo: 'new_order')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      if (!mounted) return;

      // Get store location for distance calculation
      final storeDoc = await FirebaseFirestore.instance
          .collection('stores')
          .doc(storeId)
          .get();
      final storeLocation = storeDoc.data()?['location'] as GeoPoint?;

      final newNotifications = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        double distance = 0;

        if (storeLocation != null &&
            data['customerLat'] != null &&
            data['customerLng'] != null) {
          distance = await Geolocator.distanceBetween(
            storeLocation.latitude,
            storeLocation.longitude,
            (data['customerLat'] as num).toDouble(),
            (data['customerLng'] as num).toDouble(),
          );
        }

        return {
          'id': doc.id,
          ...data,
          'distance': distance,
          'timestamp': data['timestamp']?.toDate() ?? DateTime.now(),
        };
      }));

      // Filter to only show notifications within 500m
      final filteredNotifications = newNotifications.where((n) {
        final distance = n['distance'] as double;
        return distance <= 500;
      }).toList();

      if (mounted) {
        setState(() {
          _orderNotifications = filteredNotifications;
          _orderNotificationCount =
              filteredNotifications.where((n) => n['read'] == false).length;
        });
      }
    });
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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(
                    lowStockProducts: _products,
                    orderNotifications: _orderNotifications,
                    onNotificationDeleted:
                        (String notificationId, bool isOrder) async {
                      if (isOrder) {
                        // Mark order notification as read
                        await FirebaseFirestore.instance
                            .collection('stores')
                            .doc(widget.storeId)
                            .collection('notifications')
                            .doc(notificationId)
                            .update({'read': true});

                        setState(() {
                          _orderNotificationCount--;
                        });
                      }
                    },
                    storeId: widget.storeId,
                  ),
                ),
              );
            },
            icon: Badge(
              label: Text('$_orderNotificationCount'),
              child: Icon(Icons.notifications, color: Colors.white, size: 28),
            ),
          ),
          TextButton(
            onPressed: () => _signOut(context),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            StoreDrawerHeader(storeId: widget.storeId),
            ListTile(
              iconColor: Colors.blue,
              textColor: Colors.purple,
              leading: Icon(
                Icons.home,
                size: 20,
              ),
              title: Text(
                'Home',
                style: TextStyle(fontSize: 20),
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              iconColor: Colors.blue,
              textColor: Colors.purple,
              leading: Icon(Icons.location_on),
              title: const Text(
                'Addresses',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StoreAddress(
                            storeId: widget.storeId,
                            onLocationSelected: (String address) {
                              //Handle the selected address here
                            })));
              },
            ),
            Divider(),
            ListTile(
              iconColor: Colors.blue,
              textColor: Colors.purple,
              leading: Icon(Icons.support_agent),
              title: const Text(
                'Support',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              iconColor: Colors.blue,
              textColor: Colors.purple,
              leading: Icon(Icons.settings),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
              iconColor: Colors.blue,
              textColor: Colors.purple,
              leading: Icon(Icons.notification_add),
              title: const Text(
                'Notifications',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {},
            ),
            Divider(),
            ListTile(
                title: Text(
              "FAQ's",
              style: TextStyle(fontWeight: FontWeight.w500),
            )),
            ListTile(
              title: const Text(
                'Privacy Policy',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                'Send feedback',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true, // Adds background color to the search bar
                      fillColor:
                          Colors.grey[200], // Set a light background color
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20), // Add some padding
                      labelText: 'Search products by name ...',
                      labelStyle: TextStyle(
                          color:
                              Colors.grey[700]), // Customize label text color
                      hintText: 'Find the best deals...',
                      hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14), // Set hint text style
                      prefixIcon: Icon(Icons.search,
                          color:
                              Colors.purple), // Customize the search icon color
                      suffixIcon: IconButton(
                        icon: Icon(Icons.close,
                            color: Colors
                                .red), // Add a clear (close) button to reset search
                        onPressed: () {
                          _searchController.clear(); // Clear the search text
                          FocusScope.of(context)
                              .unfocus(); // Dismiss the keyboard
                        },
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Add rounded corners
                        borderSide: BorderSide(
                            color: Colors.purple,
                            width: 1), // Border color when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(25), // Rounded corners
                        borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2), // Border color when focused
                      ),
                    ),
                    /*onSubmitted: (searchQuery) {
                      searchQuery = _searchController.text.trim();
                      if (searchQuery.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductSearchPage(
                              searchQuery: searchQuery,
                            ),
                          ),
                        );
                      }
                    },*/
                  ),
                ),
              ),
            ),
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
              'expiryDate': value['expiryDate']?.toString() ?? '',
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
