import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required String storeId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "All Products",
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.8, // ✅ Restricts height
                child: _buildProductGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('products').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final List<Map<String, dynamic>> products = [];

          final Map<dynamic, dynamic> stores =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          stores.forEach((storeId, storeProducts) {
            if (storeProducts is Map<dynamic, dynamic>) {
              storeProducts.forEach((key, value) {
                if (value is Map<dynamic, dynamic>) {
                  products.add({
                    'key': key.toString(),
                    'name': value['name']?.toString() ?? 'No Name',
                    'salePrice': value['salePrice']?.toString() ?? '0',
                    'productImage': value['productImage']?.toString() ?? '',
                  });
                }
              });
            }
          });

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: products[index],
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
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = product['productImage']?.trim() ?? '';
    String salePrice = product['salePrice']?.toString() ?? 'N/A';

    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Unknown Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "₹$salePrice",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
