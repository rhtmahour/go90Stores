import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'adminlogin.dart';

class MyStore extends StatefulWidget {
  const MyStore({super.key});

  @override
  State<MyStore> createState() => _MyStoreState();
}

class _MyStoreState extends State<MyStore> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, String>> _products = [];

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

  Future<void> _uploadCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.single.path != null) {
      try {
        final path = result.files.single.path!;
        final input = File(path).openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(CsvToListConverter(eol: '\n'))
            .toList();

        if (fields.isNotEmpty) {
          final products = fields.skip(1).map((row) {
            return {
              'name': row.length > 1 ? row[1]?.toString() ?? '' : '',
              'salePrice': row.length > 2 ? row[2]?.toString() ?? '' : '',
              'purchasePrice': row.length > 3 ? row[3]?.toString() ?? '' : '',
              'description': row.length > 6 ? row[6]?.toString() ?? '' : '',
              'productImage':
                  row.length > 7 ? row[7]?.toString().trim() ?? '' : '',
            };
          }).toList();

          // Upload to Firebase Realtime Database
          final databaseRef = FirebaseDatabase.instance.ref('products');
          await databaseRef.set(products);

          setState(() {
            _products = products;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("File uploaded successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("CSV file is empty or invalid!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error processing file: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected.")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProductsFromFirebase();
  }

  Future<void> _fetchProductsFromFirebase() async {
    final databaseRef = FirebaseDatabase.instance.ref('products');
    final snapshot = await databaseRef.get();

    if (snapshot.exists && snapshot.value != null) {
      final List<Map<String, String>> products = List<Map<String, String>>.from(
        (snapshot.value as List).map((item) => Map<String, String>.from(item)),
      );
      setState(() {
        _products = products;
      });
    } else {
      setState(() {
        _products = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Store',
            style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _signOut(context),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _uploadCsvFile,
              child: const Text('Upload CSV File'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _products.isEmpty
                  ? const Center(child: Text('No products to display'))
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: _products[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, String> product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String imageUrl = product['productImage']?.trim() ?? '';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 150,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.broken_image, size: 150, color: Colors.grey),
                        Text('Image Not Found'),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image_not_supported,
                          size: 150, color: Colors.grey),
                      Text('No Image Available'),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Unknown Product',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Purchase Price: \RS.${product['purchasePrice'] ?? 'N/A'}\n"
                  "Sale Price: \RS.${product['salePrice'] ?? 'N/A'}\n"
                  "Description: ${product['description'] ?? 'No Description'}",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
