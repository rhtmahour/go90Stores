import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function() onUpdate;
  final Function()
      onStockUpdated; // ✅ Added function to update stock in MyStore
  final String storeId;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onUpdate,
    required this.onStockUpdated, // ✅ Pass from MyStore
    required this.storeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = product['productImage']?.trim() ?? '';
    String shortDescription = product['description'] != null
        ? product['description'].length > 50
            ? '${product['description'].substring(0, 50)}...'
            : product['description']
        : 'No Description';

    String salePrice = product['salePrice']?.toString() ?? 'N/A';
    String purchasePrice = product['purchasePrice']?.toString() ?? 'N/A';
    String quantity = product['Quantity']?.toString() ??
        product['quantity']?.toString() ??
        'N/A';
    String expiryDate = product['expiryDate']?.toString() ??
        product['expiryDate']?.toString() ??
        'N/A';
    String expiryDateString = product['expiryDate']?.toString() ?? 'N/A';

    // ✅ Calculate days remaining
    int daysRemaining = _calculateDaysRemaining(expiryDateString);

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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
                        "Buy Price: ₹$purchasePrice\n"
                        "Sale Price: ₹$salePrice\n",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          const Text(
                            "Stock: ",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            quantity,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: int.tryParse(quantity) != null &&
                                      int.parse(quantity) < 10
                                  ? Colors.red // 🔴 Stock < 10 → Red color
                                  : Colors
                                      .black, // ⚫ Normal stock → Black color
                            ),
                          ),
                        ],
                      ),
                      Text("Expiry Date: $expiryDate",
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      // ✅ Display Days Remaining
                      Text(
                        daysRemaining >= 0
                            ? "Days Remaining: $daysRemaining"
                            : "Expired (${-daysRemaining} days ago)",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: daysRemaining >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      Text(
                        "Description: $shortDescription",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Edit Sale Price') {
                      _showEditDialog(context, 'Sale Price', salePrice,
                          (newValue) {
                        _updateProductField(
                            context, product['key'], 'salePrice', newValue);
                      });
                    } else if (value == 'Edit Purchase Price') {
                      _showEditDialog(context, 'Purchase Price', purchasePrice,
                          (newValue) {
                        _updateProductField(
                            context, product['key'], 'purchasePrice', newValue);
                      });
                    } else if (value == 'Edit stock') {
                      // ✅ Fix: Correctly handle stock updates
                      _showEditDialog(context, 'Stock', quantity, (newValue) {
                        _updateProductField(
                            context, product['key'], 'Quantity', newValue);
                      });
                    } else if (value == 'Edit expiryDate') {
                      // ✅ Fix: correctly handle expiry date updates
                      _showDatePickerDialog(context, expiryDate, (newDate) {
                        _updateProductField(
                            context, product['key'], 'expiryDate', newDate);
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Edit Sale Price',
                      child: Text('Update Sale Price'),
                    ),
                    const PopupMenuItem(
                      value: 'Edit Purchase Price',
                      child: Text('Update Buy Price'),
                    ),
                    const PopupMenuItem(
                      // ✅ Fix: Properly update stock
                      value: 'Edit stock',
                      child: Text('Update Stock'),
                    ),
                    const PopupMenuItem(
                      value:
                          'Edit expiryDate', // ✅ Fixed: Matches the `onSelected` check
                      child: Text('Update Expiry Date'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String priceType,
      String currentValue, Function(String) onSubmit) {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $priceType'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: '$priceType'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onSubmit(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _updateProductField(
      BuildContext context, String key, String field, String newValue) async {
    final databaseRef = FirebaseDatabase.instance.ref('products/$storeId/$key');

    try {
      if (field.toLowerCase() == 'quantity') {
        field = 'quantity'; // ✅ Fix: Always use lowercase "quantity"
      }

      await databaseRef.update({field: int.tryParse(newValue) ?? newValue});

      onUpdate(); // Refresh UI
      onStockUpdated(); // ✅ Notify MyStore dynamically about stock change

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product $field updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  }
}

void _showDatePickerDialog(BuildContext context, String currentValue,
    Function(String) onSubmit) async {
  DateTime initialDate = DateTime.tryParse(currentValue) ?? DateTime.now();

  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2020),
    lastDate: DateTime(2035),
  );

  if (pickedDate != null) {
    String formattedDate =
        DateFormat('dd/MM/yyyy').format(pickedDate); // ✅ Correct format
    onSubmit(formattedDate);
  }
}

/// ✅ Function to calculate days remaining from expiry date
int _calculateDaysRemaining(String expiryDate) {
  try {
    // ✅ Convert expiryDate String to DateTime (Format: dd/MM/yyyy)
    DateTime expiry = DateFormat('dd/MM/yyyy').parse(expiryDate);
    DateTime today = DateTime.now();

    return expiry.difference(today).inDays; // ✅ Days remaining
  } catch (e) {
    return 0; // If error occurs (invalid date format), assume 0 days remaining
  }
}
