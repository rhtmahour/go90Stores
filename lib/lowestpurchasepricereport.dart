import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LowestPurchasePriceReport extends StatefulWidget {
  const LowestPurchasePriceReport({super.key});

  @override
  State<LowestPurchasePriceReport> createState() =>
      _LowestPurchasePriceReportState();
}

class _LowestPurchasePriceReportState extends State<LowestPurchasePriceReport> {
  final DatabaseReference databaseRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://go90stores-6583a-default-rtdb.firebaseio.com/",
  ).ref("products");

  bool _isLoading = false;
  String _statusMessage = '';
  List<Map<String, dynamic>> reportData = [];

  /// **Function to Calculate the Lowest Purchase Price Across Stores**
  Future<void> calculateLowestPurchasePrice() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Fetching and processing data...';
    });

    try {
      final snapshot = await databaseRef.get();

      if (snapshot.exists) {
        final data = snapshot.value;

        if (data is Map<dynamic, dynamic>) {
          final Map<String, Map<String, dynamic>> lowestPrices = {};

          // Iterate through each store in the database
          data.forEach((storeId, storeProducts) {
            if (storeProducts is Map<dynamic, dynamic>) {
              // Iterate through products in the store
              storeProducts.forEach((productId, productDetails) {
                if (productDetails is Map<dynamic, dynamic>) {
                  final String? productName = productDetails["name"];

                  // Convert purchasePrice to double safely
                  final dynamic rawPurchasePrice =
                      productDetails["purchasePrice"];
                  final double? purchasePrice = rawPurchasePrice is num
                      ? rawPurchasePrice.toDouble()
                      : double.tryParse(rawPurchasePrice.toString());

                  if (productName != null && purchasePrice != null) {
                    if (!lowestPrices.containsKey(productName) ||
                        purchasePrice <
                            lowestPrices[productName]!["lowestPrice"]) {
                      lowestPrices[productName] = {
                        "lowestPrice": purchasePrice,
                        "storeName": storeId,
                        "productId": productId,
                      };
                    }
                  }
                }
              });
            }
          });

          // Convert map to list for UI display
          reportData = lowestPrices.entries.map((entry) {
            return {
              "productName": entry.key,
              "lowestPurchasePrice": entry.value["lowestPrice"],
              "storeName": entry.value["storeName"],
              "productId": entry.value["productId"],
            };
          }).toList();

          setState(() {
            _statusMessage = reportData.isEmpty
                ? 'No products found with a valid purchase price.'
                : 'Report generated successfully!';
          });
        } else {
          _statusMessage = 'Unexpected data format!';
        }
      } else {
        _statusMessage = 'No data found in the database.';
      }
    } catch (error) {
      _statusMessage = 'Error fetching data: $error';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// **Function to Generate and Download CSV Report**
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
    csvBuffer.writeln("Store Name,Product Name,Lowest Purchase Price");

    for (var entry in reportData) {
      csvBuffer.writeln(
          "${entry['storeName']},${entry['productName']},${entry['lowestPurchasePrice']}");
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
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return SingleChildScrollView(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  maxWidth: isWideScreen ? 1000 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed:
                          _isLoading ? null : calculateLowestPurchasePrice,
                      icon: const Icon(Icons.analytics, color: Colors.white),
                      label: const Text(
                        'Generate Report',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF6A1B9A), // Rich purple
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Show loading spinner
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),

                    const SizedBox(height: 16),

                    if (reportData.isNotEmpty) ...[
                      const Text(
                        "Results",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 30,
                            columns: const [
                              DataColumn(
                                  label: Text('Store ID',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Product Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Lowest Price',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: reportData.map((item) {
                              return DataRow(cells: [
                                DataCell(Text(item['storeName'] ?? 'N/A')),
                                DataCell(Text(item['productName'] ?? 'N/A')),
                                DataCell(Text(
                                    '₹${item['lowestPurchasePrice'] ?? 'N/A'}')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    ElevatedButton.icon(
                      onPressed: _isLoading || reportData.isEmpty
                          ? null
                          : generateAndDownloadReport,
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        'Download CSV Report',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF6A1B9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    if (_statusMessage.isNotEmpty)
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: _statusMessage.contains('successfully')
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
