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
  final DatabaseReference databaseRef = FirebaseDatabase.instance
      .refFromURL("https://go90store-default-rtdb.firebaseio.com/products");

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
          decoration: BoxDecoration(
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
                  const Divider(
                    color: Colors.purpleAccent,
                    thickness: 2,
                    endIndent: 50,
                  ),
                  if (reportData.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Store Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Product Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'LowestPP',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: reportData.map((item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item['storeName'] ?? 'N/A')),
                                DataCell(Text(item['productName'] ?? 'N/A')),
                                DataCell(Text(
                                    '₹${item['lowestPurchasePrice'] ?? 'N/A'}')),
                              ],
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
