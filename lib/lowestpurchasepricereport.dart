import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Lowestpurchasepricereport extends StatefulWidget {
  const Lowestpurchasepricereport({super.key});

  @override
  State<Lowestpurchasepricereport> createState() =>
      _LowestpurchasepricereportState();
}

class _LowestpurchasepricereportState extends State<Lowestpurchasepricereport> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance
      .refFromURL("https://go90store-default-rtdb.firebaseio.com/products");

  bool _isLoading = false;
  String _statusMessage = '';
  List<Map<String, dynamic>> reportData = [];
  Future<void> calculateLowestPurchasePrice() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching and processing data...';
    });

    try {
      // Fetch all products from Firebase
      final snapshot = await databaseRef.get();

      if (snapshot.exists) {
        final data = snapshot.value;

        // Validate that the root data is a Map
        if (data is Map<dynamic, dynamic>) {
          final Map<String, Map<String, dynamic>> lowestPrices = {};

          // Iterate through each storeId and its products
          data.forEach((storeId, storeProducts) {
            if (storeProducts is Map<dynamic, dynamic>) {
              storeProducts.forEach((productId, product) {
                if (product is Map<dynamic, dynamic>) {
                  final productName = product["name"];
                  final purchasePrice = product["purchasePrice"];

                  // Ensure productName and purchasePrice are valid
                  if (productName != null && purchasePrice is num) {
                    // Compare and find the lowest price for each product
                    if (lowestPrices.containsKey(productName)) {
                      if (purchasePrice <
                          lowestPrices[productName]!["lowestPrice"]) {
                        lowestPrices[productName] = {
                          "lowestPrice": purchasePrice,
                          "storeName": storeId,
                        };
                      }
                    } else {
                      print("This is else part of the code ");
                      lowestPrices[productName] = {
                        "lowestPrice": purchasePrice,
                        "storeName": storeId,
                      };
                    }
                  }
                }
              });
            }
          });

          // Prepare the report data
          reportData = lowestPrices.entries
              .map((entry) => {
                    "productname": entry.key,
                    "lowestpurchaseprice": entry.value["lowestPrice"],
                    "storename": entry.value["storeName"],
                  })
              .toList();

          setState(() {
            _statusMessage = reportData.isEmpty
                ? 'No products with a valid purchase price were found.'
                : 'Report generated successfully!';
          });
        } else {
          _statusMessage = 'Unexpected data format: Root data is not a Map.';
          print("Root data is not a Map: $data");
        }
      } else {
        _statusMessage = 'No data found in the database.';
      }
    } catch (error) {
      _statusMessage = 'Error fetching data: $error';
      print("Error fetching data: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> generateAndDownloadReport() async {
    if (reportData.isEmpty) {
      setState(() {
        _statusMessage = 'No data available to generate a report.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Generating CSV report...';
    });

    final StringBuffer csvBuffer = StringBuffer();
    csvBuffer.writeln("storename,productname,lowestpurchaseprice");
    for (var entry in reportData) {
      csvBuffer.writeln(
          "${entry['storename']},${entry['productname']},${entry['lowestpurchaseprice']}");
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/lowest_purchase_price_report.csv';
    final file = File(filePath);

    await file.writeAsString(csvBuffer.toString());

    setState(() {
      _isLoading = false;
      _statusMessage = 'Report generated successfully!';
    });

    Share.shareXFiles([XFile(filePath)], text: 'Lowest Purchase Price Report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Lowest Purchase Price Report',
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
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: isWideScreen ? 800 : double.infinity,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : calculateLowestPurchasePrice,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Generate Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.purpleAccent,
                    thickness: 2,
                    endIndent: 50,
                  ),
                  if (reportData.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: reportData.map<Widget>((item) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "StoreId: ${item['storename']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 100),
                                  Text(
                                    "${item['productname']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 100),
                                  Text(
                                    "\Rs.${item['lowestpurchaseprice']}",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : generateAndDownloadReport,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Download CSV Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: _statusMessage.contains('successfully')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
