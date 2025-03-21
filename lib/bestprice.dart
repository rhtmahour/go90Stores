import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BestPriceCalulate extends StatefulWidget {
  const BestPriceCalulate({super.key});

  @override
  State<BestPriceCalulate> createState() => _BestPriceCalulateState();
}

class _BestPriceCalulateState extends State<BestPriceCalulate> {
  final DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref("products");

  bool _isLoading = false;
  String _statusMessage = '';
  List<Map<String, dynamic>> reportData = [];

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

          data.forEach((storeId, storeProducts) {
            if (storeProducts is Map<dynamic, dynamic>) {
              storeProducts.forEach((productId, productDetails) {
                if (productDetails is Map<dynamic, dynamic>) {
                  final String? productName = productDetails["name"];
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
          'Lowest Buy Price',
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

          return Center(
            child: Container(
              padding: EdgeInsets.all(isWideScreen ? 24 : 16),
              constraints: BoxConstraints(
                maxWidth: isWideScreen ? 800 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : calculateLowestPurchasePrice,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Generate Report',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const Divider(
                      color: Colors.purpleAccent, thickness: 2, endIndent: 2),
                  Expanded(
                    child: reportData.isEmpty
                        ? const Center(child: Text('No data available'))
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columnSpacing: isWideScreen ? 40 : 20,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'Store Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 20),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Product Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 20),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Lowest BuyPrice',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 20),
                                    ),
                                  ),
                                ],
                                rows: reportData.map((item) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                          Text(item['storeName'] ?? 'N/A')),
                                      DataCell(
                                          Text(item['productName'] ?? 'N/A')),
                                      DataCell(Text(
                                          '₹${item['lowestPurchasePrice'] ?? 'N/A'}')),
                                    ],
                                  );
                                }).toList(),
                              ),
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
                          color: Colors.white),
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
                    textAlign: TextAlign.center,
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
