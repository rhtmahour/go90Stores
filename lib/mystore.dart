import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
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
  String _uploadMessage = '';

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
        print(fields);

        if (fields.isNotEmpty) {
          setState(() {
            // Skip header row, map data, and handle missing fields
            _products = fields.skip(1).map((row) {
              return {
                'Name of item': row.length > 1 ? row[1]?.toString() ?? '' : '',
                'Purchase Price':
                    row.length > 2 ? row[2]?.toString() ?? '' : '',
                'Sale Price': row.length > 3 ? row[3]?.toString() ?? '' : '',
                'Description': row.length > 6 ? row[6]?.toString() ?? '' : '',
                'Product Image': row.length > 7 ? row[7]?.toString() ?? '' : '',
              };
            }).toList();
            _uploadMessage = "File uploaded successfully!";
          });
        } else {
          setState(() {
            _uploadMessage = "CSV file is empty or invalid!";
          });
        }
      } catch (e) {
        print('Error parsing CSV: $e');
        setState(() {
          _uploadMessage = "Error processing file: $e";
        });
      }
    } else {
      setState(() {
        _uploadMessage = "No file selected.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Store',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            if (_uploadMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _uploadMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: product['Product Image']!.isNotEmpty
                          ? Image.network(
                              product['Product Image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            )
                          : const Icon(Icons.image),
                      title: Text(product['Name of item']!),
                      subtitle: Text(
                        "Purchase Price: \$${product['Purchase Price']}\n"
                        "Sale Price: \$${product['Sale Price']}\n"
                        "Description: ${product['Description']}",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
