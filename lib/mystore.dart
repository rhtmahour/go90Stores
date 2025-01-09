import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:go90stores/productcard.dart';
import 'dart:io';
import 'dart:convert';
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
          final databaseRef = FirebaseDatabase.instance.ref('products');
          final products = fields.skip(1).map((row) async {
            String? productId = row.length > 0
                ? row[0]?.toString()
                : null; // Assuming ID is in the first column
            final product = {
              'name': row.length > 1 ? row[1]?.toString() ?? '' : '',
              'salePrice': row.length > 2 ? row[2]?.toString() ?? '' : '',
              'purchasePrice': row.length > 3 ? row[3]?.toString() ?? '' : '',
              'description': row.length > 6 ? row[6]?.toString() ?? '' : '',
              'productImage':
                  row.length > 7 ? row[7]?.toString().trim() ?? '' : '',
            };

            if (productId != null && productId.isNotEmpty) {
              // Update existing product
              await databaseRef.child(productId).update(product);
            } else {
              // Generate a new product ID
              final newProductRef = databaseRef.push();
              await newProductRef.set(product);
              productId = newProductRef.key;
            }

            product['key'] = productId!;
            return product;
          }).toList();

          final resolvedProducts = await Future.wait(products);

          setState(() {
            _products = resolvedProducts;
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
      final List<Map<String, String>> products = [];
      Map<String, dynamic> data = snapshot.value as Map<String, dynamic>;
      data.forEach((key, value) {
        products.add({
          'key': key,
          'name': value['name'] ?? '',
          'salePrice': value['salePrice'] ?? '',
          'purchasePrice': value['purchasePrice'] ?? '',
          'description': value['description'] ?? '',
          'productImage': value['productImage'] ?? '',
        });
      });

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
