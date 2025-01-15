import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  final Map<String, String> product;
  final Function() onUpdate;
  final String storeId;

  const ProductCard({
    super.key,
    required this.product,
    required this.onUpdate,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    String imageUrl = product['productImage']?.trim() ?? '';
    String shortDescription = product['description'] != null
        ? product['description']!.length > 50
            ? '${product['description']!.substring(0, 50)}...'
            : product['description']!
        : 'No Description';

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
                        "Purchase Price: \RS.${product['purchasePrice'] ?? 'N/A'}\n"
                        "Sale Price: \RS.${product['salePrice'] ?? 'N/A'}\n"
                        "Description: $shortDescription",
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Edit Sales Price') {
                      _showEditDialog(
                          context, 'Sale Price', product['salePrice'],
                          (newValue) {
                        _updateProductPrice(context, product['key']!,
                            'salePrice', newValue, storeId);
                      });
                    } else if (value == 'Edit Purchase Price') {
                      _showEditDialog(
                          context, 'Purchase Price', product['purchasePrice'],
                          (newValue) {
                        _updateProductPrice(context, product['key']!,
                            'purchasePrice', newValue, storeId);
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Edit Sales Price',
                      child: Text('Edit Sales Price'),
                    ),
                    const PopupMenuItem(
                      value: 'Edit Purchase Price',
                      child: Text('Edit Purchase Price'),
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
      String? currentValue, Function(String) onSubmit) {
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

  void _updateProductPrice(BuildContext context, String key, String field,
      String newValue, String storeId) async {
    final databaseRef = FirebaseDatabase.instance.ref('products/$storeId/$key');

    try {
      await databaseRef.update({field: newValue});
      onUpdate(); // Refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product price updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  }
}
