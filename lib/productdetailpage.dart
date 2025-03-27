import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final dynamic product; // Pass the product data

  ProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    var imageUrl = product['images'] != null && product['images'].isNotEmpty
        ? product['images'][0]['src']
        : 'https://via.placeholder.com/150'; // Fallback image
    var price = product['price'] ?? 'N/A'; // Product price
    var description = product['description'] ?? 'No description available';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product['name'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              // Product Name
              Text(
                product['name'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              // Product Price
              Text(
                'Price: RS $price',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              // Product Description
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
